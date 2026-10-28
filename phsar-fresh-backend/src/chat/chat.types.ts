export interface ChatTurn {
  role: "user" | "model";
  text: string;
}

export interface ProductCard {
  id: string;
  name: string;
  nameKm: string | null;
  origin: string | null;
  category: string;
  unit: string;
  priceCents: number;
  currency: "USD";
  imageUrl: string | null;
  inStock: boolean;
}

export interface RecipeItem {
  ingredient: string;
  quantity: string | null;
  product: ProductCard | null;
}

export interface RecipeResult {
  dish: string;
  servings: number | null;
  items: RecipeItem[];
}

export interface ChatReply {
  reply: string;
  products: ProductCard[];
  recipe: RecipeResult | null;
}
