import { Injectable, Logger } from "@nestjs/common";
import { Content, FunctionCall, Part } from "@google/genai";
import {
  ProductsService,
  ProductWithCategory,
} from "../products/products.service";
import {
  ChatReply,
  ChatTurn,
  ProductCard,
  RecipeItem,
  RecipeResult,
} from "./chat.types";
import { GeminiService } from "./gemini/gemini.service";
import {
  FIND_INGREDIENTS_TOOL,
  SEARCH_PRODUCTS_TOOL,
} from "./gemini/gemini.tools";
import { toProductCard, toToolProduct } from "./product-card.mapper";

const MAX_STEPS = 4;
const MAX_CARDS = 6;
const MAX_HISTORY_TURNS = 10;
const TOOL_RESULT_LIMIT = 4;
const MAX_RECIPE_ITEMS = 12;

const FALLBACK_REPLY =
  "Sorry, I could not find an answer for that. Try asking about a product, or a dish you want to cook.";

interface TurnResult {
  cards: Map<string, ProductCard>;
  recipe: RecipeResult | null;
}

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(
    private readonly gemini: GeminiService,
    private readonly products: ProductsService,
  ) {}

  async reply(message: string, history: ChatTurn[] = []): Promise<ChatReply> {
    const contents: Content[] = [
      ...normalizeHistory(history).map((t) => ({
        role: t.role,
        parts: [{ text: t.text }],
      })),
      { role: "user", parts: [{ text: message }] },
    ];

    // Cards and recipe items come from the database, so the AI can never show a wrong price.
    const result: TurnResult = { cards: new Map(), recipe: null };

    for (let step = 0; step < MAX_STEPS; step++) {
      const response = await this.gemini.generate(contents);
      const calls = response.functionCalls ?? [];
      const modelContent = response.candidates?.[0]?.content;

      // No tool needed: this is the final answer.
      if (calls.length === 0 || !modelContent) {
        return this.finish(response.text?.trim() || FALLBACK_REPLY, result);
      }

      // Send the model's message back unchanged (Gemini 3 needs its hidden "thought signature").
      contents.push(modelContent);

      const parts: Part[] = [];
      for (const call of calls) {
        const output = await this.runTool(call, result);
        // The id must be the exact id Gemini gave us.
        parts.push({
          functionResponse: {
            id: call.id,
            name: call.name,
            response: { result: output },
          },
        });
      }
      contents.push({ role: "user", parts });
    }

    return this.finish(FALLBACK_REPLY, result);
  }

  private finish(reply: string, result: TurnResult): ChatReply {
    return {
      reply,
      products: mentionedCards(reply, [...result.cards.values()]),
      recipe: result.recipe,
    };
  }

  private async runTool(
    call: FunctionCall,
    result: TurnResult,
  ): Promise<Record<string, unknown>> {
    const args = (call.args ?? {}) as Record<string, unknown>;

    switch (call.name) {
      case SEARCH_PRODUCTS_TOOL.name:
        return this.searchProducts(args, result);
      case FIND_INGREDIENTS_TOOL.name:
        return this.findIngredients(args, result);
      default:
        return { error: `Unknown tool: ${call.name}` };
    }
  }

  // ------------------------------------------------------------ search_products
  private async searchProducts(
    args: Record<string, unknown>,
    result: TurnResult,
  ): Promise<Record<string, unknown>> {
    const query = cleanText(args.query, 80);
    if (!query) return { error: "query is required" };

    try {
      const rows = await this.products.search({
        query,
        inStockOnly: args.in_stock_only === true,
        limit: TOOL_RESULT_LIMIT,
      });

      for (const row of rows) {
        if (result.cards.size < MAX_CARDS)
          result.cards.set(row.id, toProductCard(row));
      }
      return { found: rows.length, products: rows.map(toToolProduct) };
    } catch (err) {
      this.logger.error(`search_products failed: ${(err as Error).message}`);
      return { error: "Product search is temporarily unavailable" };
    }
  }

  // ----------------------------------------------------------- find_ingredients
  private async findIngredients(
    args: Record<string, unknown>,
    result: TurnResult,
  ): Promise<Record<string, unknown>> {
    const dish = cleanText(args.dish, 80);
    const wanted = parseIngredients(args.ingredients);
    if (!dish || wanted.length === 0) {
      return {
        error: "dish and at least one ingredient (name + search) are required",
      };
    }

    try {
      // One small search per ingredient, all at the same time. Every word
      // must match, so "black pepper" never becomes "chili peppers".
      const matches = await Promise.all(
        wanted.map((i) =>
          this.products
            .search({ query: i.search, limit: 3, anyWordFallback: false })
            .then(pickBest),
        ),
      );

      const items: RecipeItem[] = wanted.map((i, idx) => ({
        ingredient: i.name,
        quantity: i.quantity,
        product: matches[idx] ? toProductCard(matches[idx]!) : null,
      }));

      result.recipe = { dish, servings: parseServings(args.servings), items };

      return {
        dish,
        available: items
          .filter((i) => i.product?.inStock)
          .map((i) => ({
            ingredient: i.ingredient,
            product: i.product!.name,
            price_usd: (i.product!.priceCents / 100).toFixed(2),
            unit: i.product!.unit,
          })),
        sold_out: items
          .filter((i) => i.product && !i.product.inStock)
          .map((i) => i.ingredient),
        not_sold_here: items.filter((i) => !i.product).map((i) => i.ingredient),
      };
    } catch (err) {
      this.logger.error(`find_ingredients failed: ${(err as Error).message}`);
      return { error: "Product search is temporarily unavailable" };
    }
  }
}

// ---------------------------------------------------------------------- helpers

interface WantedIngredient {
  name: string;
  quantity: string | null;
  search: string;
}

function cleanText(value: unknown, max: number): string {
  return typeof value === "string" ? value.trim().slice(0, max) : "";
}

/** Keeps only valid items, max 12, without repeating the same search word. */
export function parseIngredients(value: unknown): WantedIngredient[] {
  if (!Array.isArray(value)) return [];

  const seen = new Set<string>();
  const out: WantedIngredient[] = [];

  for (const raw of value) {
    if (!raw || typeof raw !== "object") continue;
    const item = raw as Record<string, unknown>;

    const name = cleanText(item.name, 60);
    const search = cleanText(item.search, 40);
    if (!name || !search || seen.has(search.toLowerCase())) continue;

    seen.add(search.toLowerCase());
    out.push({ name, search, quantity: cleanText(item.quantity, 30) || null });
    if (out.length === MAX_RECIPE_ITEMS) break;
  }
  return out;
}

function parseServings(value: unknown): number | null {
  const n = typeof value === "number" ? Math.round(value) : NaN;
  return n >= 1 && n <= 50 ? n : null;
}

/**
 * Only the cards for products the reply talks about, so "Cambodia water from
 * where?" does not also show coconut water and watermelon. When the reply
 * names none of them (e.g. "here are some fruits"), every card is kept.
 */
export function mentionedCards(
  reply: string,
  cards: ProductCard[],
): ProductCard[] {
  const text = reply.toLowerCase();
  const named = cards.filter((card) =>
    [card.name, card.nameKm].some(
      (name) => !!name?.trim() && text.includes(name.trim().toLowerCase()),
    ),
  );
  return named.length > 0 ? named : cards;
}

/** Prefer a product that is in stock. */
function pickBest(rows: ProductWithCategory[]): ProductWithCategory | null {
  return rows.find((r) => r.stock > 0) ?? rows[0] ?? null;
}

/** Gemini wants turns to start with "user" and alternate user / model. */
export function normalizeHistory(history: ChatTurn[]): ChatTurn[] {
  const out: ChatTurn[] = [];

  for (const turn of history.slice(-MAX_HISTORY_TURNS)) {
    const text = turn.text.trim();
    if (!text) continue;
    if (out.length === 0 && turn.role !== "user") continue;

    const last = out[out.length - 1];
    if (last && last.role === turn.role) {
      out[out.length - 1] = { role: turn.role, text }; // keep only the newest of repeated roles
    } else {
      out.push({ role: turn.role, text });
    }
  }

  // The new message is a "user" turn, so history must end with "model".
  if (out.length > 0 && out[out.length - 1].role === "user") out.pop();
  return out;
}
