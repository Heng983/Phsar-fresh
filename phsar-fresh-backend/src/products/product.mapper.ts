import { Category, Product } from "@prisma/client";

type ProductRow = Product & { category: Category };

/** The product as the app sees it. Stock numbers stay private; the app only needs inStock. */
export function toPublicProduct(p: ProductRow) {
  return {
    id: p.id,
    name: p.name,
    nameKm: p.nameKm,
    description: p.description,
    origin: p.origin,
    unit: p.unit,
    priceCents: p.priceCents,
    currency: "USD" as const,
    imageUrl: p.imageUrl,
    inStock: p.stock > 0,
    category: {
      id: p.category.id,
      name: p.category.name,
      nameKm: p.category.nameKm,
    },
  };
}

export type PublicProduct = ReturnType<typeof toPublicProduct>;
