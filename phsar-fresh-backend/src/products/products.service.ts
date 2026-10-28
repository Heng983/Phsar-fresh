import { Injectable, NotFoundException } from "@nestjs/common";
import { Prisma } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { ListProductsDto } from "./dto/list-product.dto";
import { PopularProductsDto } from "./dto/popular-products.dto";
import { toPublicProduct } from "./product.mapper";
import { toSearchWords } from "./search-words";

/** "Popular this week" in the app. */
const POPULAR_WINDOW_MS = 7 * 24 * 60 * 60 * 1000;

export type ProductWithCategory = Prisma.ProductGetPayload<{
  include: { category: true };
}>;

export interface SearchProductsParams {
  query: string;
  inStockOnly?: boolean;
  limit?: number;
  /** False = every word must match (no single-word fallback). */
  anyWordFallback?: boolean;
}

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  /** Cached 30 s per filter/page (stock is re-checked when an order is placed). */
  list(dto: ListProductsDto) {
    const params = { q: dto.q?.trim().toLowerCase(), c: dto.categoryId, s: dto.inStock, p: dto.page, l: dto.limit };
    return this.cache.remember("catalog", `list:${CacheService.key(params)}`, 30, () => this.loadList(dto));
  }

  private async loadList(dto: ListProductsDto) {
    const where: Prisma.ProductWhereInput = {
      isActive: true,
      ...(dto.categoryId && { categoryId: dto.categoryId }),
      ...(dto.inStock && { stock: { gt: 0 } }),
      ...(dto.q && { AND: toSearchWords(dto.q).map(wordFilter) }),
    };

    const [rows, total] = await this.prisma.$transaction([
      this.prisma.product.findMany({
        where,
        include: { category: true },
        // in-stock first, then A to Z
        orderBy: [{ stock: "desc" }, { name: "asc" }],
        skip: (dto.page - 1) * dto.limit,
        take: dto.limit,
      }),
      this.prisma.product.count({ where }),
    ]);

    return {
      items: rows.map(toPublicProduct),
      page: dto.page,
      limit: dto.limit,
      total,
      hasMore: dto.page * dto.limit < total,
    };
  }

  /**
   * Best sellers of the last 7 days (quantity sold, cancelled orders left
   * out), then the usual list order to fill up while there are few sales.
   */
  popular(dto: PopularProductsDto) {
    // A groupBy over a week of orders: worth caching, the ranking moves slowly.
    return this.cache.remember("catalog", `popular:${dto.limit}`, 120, () => this.loadPopular(dto));
  }

  private async loadPopular(dto: PopularProductsDto) {
    const since = new Date(Date.now() - POPULAR_WINDOW_MS);
    const sales = await this.prisma.orderItem.groupBy({
      by: ["productId"],
      where: {
        order: { status: { not: "CANCELLED" }, createdAt: { gte: since } },
        product: { isActive: true },
      },
      _sum: { qty: true },
      orderBy: [{ _sum: { qty: "desc" } }, { productId: "asc" }],
      take: dto.limit,
    });
    const ids = sales.map((sale) => sale.productId);

    const sold = await this.prisma.product.findMany({
      where: { id: { in: ids }, isActive: true },
      include: { category: true },
    });
    const byId = new Map(sold.map((product) => [product.id, product]));
    const ranked = ids.flatMap((id) => byId.get(id) ?? []);

    const rest =
      ranked.length < dto.limit
        ? await this.prisma.product.findMany({
            where: { isActive: true, id: { notIn: ids } },
            include: { category: true },
            orderBy: [{ stock: "desc" }, { name: "asc" }],
            take: dto.limit - ranked.length,
          })
        : [];

    return [...ranked, ...rest].map(toPublicProduct);
  }

  findOne(id: string) {
    return this.cache.remember("catalog", `product:${id}`, 60, () => this.loadOne(id));
  }

  private async loadOne(id: string) {
    const product = await this.prisma.product.findFirst({
      where: { id, isActive: true },
      include: { category: true },
    });
    if (!product) throw new NotFoundException("Product not found");
    return toPublicProduct(product);
  }

  // ------------------------------------------------------------- chat assistant

  /**
   * Looks in name, Khmer name, description, origin and category.
   * First every word must match ("kampot pepper"), and if nothing is found,
   * any single word may match.
   */
  async search({
    query,
    inStockOnly = false,
    limit = 5,
    anyWordFallback = true,
  }: SearchProductsParams): Promise<ProductWithCategory[]> {
    const take = Math.min(Math.max(limit, 1), 10);
    const words = toSearchWords(query);

    const base: Prisma.ProductWhereInput = {
      isActive: true,
      ...(inStockOnly && { stock: { gt: 0 } }),
    };

    // Look at more rows than needed, then keep the best matches.
    let rows = await this.find({ ...base, AND: words.map(wordFilter) });

    if (anyWordFallback && rows.length === 0 && words.length > 1) {
      rows = await this.find({ ...base, OR: words.map(wordFilter) });
    }
    return rankByName(rows, words).slice(0, take);
  }

  private find(where: Prisma.ProductWhereInput) {
    return this.prisma.product.findMany({
      where,
      take: SEARCH_CANDIDATES,
      orderBy: { name: "asc" },
      include: { category: true },
    });
  }
}

const SEARCH_CANDIDATES = 30;

/**
 * Products named after the words first ("water" → "Cambodia Water"), then
 * names that only contain them ("Watermelon"), then description, origin or
 * category matches. A-Z within each group.
 */
function rankByName(
  rows: ProductWithCategory[],
  words: string[],
): ProductWithCategory[] {
  const score = (p: ProductWithCategory) => {
    const names = [p.name, p.nameKm ?? ""];
    const has = (test: (name: string, word: string) => boolean) =>
      words.every((word) => names.some((name) => test(name, word)));
    if (has(isWholeWord)) return 2;
    if (has((name, word) => name.toLowerCase().includes(word.toLowerCase())))
      return 1;
    return 0;
  };
  return rows
    .map((row) => ({ row, score: score(row) }))
    .sort((a, b) => b.score - a.score) // stable: keeps A-Z order
    .map(({ row }) => row);
}

/** "water" matches "Cambodia Water" but not "Watermelon"; plurals count. */
function isWholeWord(name: string, word: string): boolean {
  // Khmer has no spaces between words, so a contained word is enough.
  if (!/^[a-z0-9]+$/i.test(word)) return name.includes(word);
  return new RegExp(`\\b${word}(e?s)?\\b`, "i").test(name);
}

function wordFilter(word: string): Prisma.ProductWhereInput {
  const like = { contains: word, mode: "insensitive" as const };
  return {
    OR: [
      { name: like },
      { nameKm: like },
      { description: like },
      { origin: like },
      { category: { name: like } },
      { category: { nameKm: like } },
    ],
  };
}
