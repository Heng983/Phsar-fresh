import { ProductWithCategory } from "../products/products.service";
import { ProductCard } from "./chat.types";

/** The card the app shows under the chat message, with an Add button. */
export function toProductCard(p: ProductWithCategory): ProductCard {
  return {
    id: p.id,
    name: p.name,
    nameKm: p.nameKm,
    origin: p.origin,
    category: p.category.name,
    unit: p.unit,
    priceCents: p.priceCents,
    currency: "USD",
    imageUrl: p.imageUrl,
    inStock: p.stock > 0,
  };
}

/** What the AI reads from search_products. Stock numbers stay private; it only needs in_stock. */
export function toToolProduct(p: ProductWithCategory) {
  return {
    name: p.name,
    name_km: p.nameKm,
    category: p.category.name,
    origin: p.origin,
    description: p.description,
    price_usd: (p.priceCents / 100).toFixed(2),
    unit: p.unit,
    in_stock: p.stock > 0,
  };
}
