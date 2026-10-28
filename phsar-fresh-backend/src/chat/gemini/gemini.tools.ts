import { FunctionDeclaration, Type } from "@google/genai";

export const SEARCH_PRODUCTS_TOOL: FunctionDeclaration = {
  name: "search_products",
  description:
    "Searches the Phsar Fresh grocery catalog. Use it whenever the customer asks about a product, " +
    "where it comes from, its price, whether it is in stock, or wants a recommendation. " +
    "Returns matching products with origin, price in USD, unit and stock.",
  parameters: {
    type: Type.OBJECT,
    properties: {
      query: {
        type: Type.STRING,
        description:
          'Product keywords in English, singular, 1 to 3 words. Examples: "pepper", "palm sugar", "mango", "fruit". ' +
          "If the customer wrote Khmer, translate it to English first.",
      },
      in_stock_only: {
        type: Type.BOOLEAN,
        description:
          "Set true only if the customer asks for products that are available now.",
      },
    },
    required: ["query"],
  },
};

export const FIND_INGREDIENTS_TOOL: FunctionDeclaration = {
  name: "find_ingredients",
  description:
    "Use when the customer wants to cook a dish or asks what ingredients a dish needs. " +
    "Send the full list of main ingredients for the dish. The tool checks which ones Phsar Fresh sells " +
    "and returns the matching product (or none) for each ingredient.",
  parameters: {
    type: Type.OBJECT,
    properties: {
      dish: {
        type: Type.STRING,
        description:
          'The dish name as the customer said it, e.g. "Beef Lok Lak" or "សម្លកកូរ".',
      },
      servings: {
        type: Type.INTEGER,
        description: "Number of people, only if the customer said it.",
      },
      ingredients: {
        type: Type.ARRAY,
        description:
          "All main ingredients of the dish, 3 to 12 items. Do not include water.",
        items: {
          type: Type.OBJECT,
          properties: {
            name: {
              type: Type.STRING,
              description:
                'Ingredient name in the customer\'s language, e.g. "Garlic" or "ខ្ទឹមស". ' +
                "In Khmer, use only Khmer script (never Thai letters).",
            },
            quantity: {
              type: Type.STRING,
              description:
                'Amount for the dish, e.g. "300 g" or "3 cloves". Optional.',
            },
            search: {
              type: Type.STRING,
              description:
                'English search keyword, singular, 1 to 2 words, e.g. "garlic", "beef", "black pepper".',
            },
          },
          required: ["name", "search"],
        },
      },
    },
    required: ["dish", "ingredients"],
  },
};

export const CHAT_TOOLS: FunctionDeclaration[] = [
  SEARCH_PRODUCTS_TOOL,
  FIND_INGREDIENTS_TOOL,
];
