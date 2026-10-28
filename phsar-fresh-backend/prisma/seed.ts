import { createPrisma } from "./client";

const prisma = createPrisma();

// SAMPLE DATA: replace names, origins and prices with your real products.
const categories: { name: string; nameKm: string | null }[] = [
  { name: "Spices", nameKm: "គ្រឿងទេស" },
  { name: "Fruit", nameKm: "ផ្លែឈើ" },
  { name: "Vegetables", nameKm: "បន្លែ" },
  { name: "Seafood", nameKm: "គ្រឿងសមុទ្រ" },
  { name: "Pantry", nameKm: "គ្រឿងផ្សំ" },
  { name: "Meat", nameKm: "សាច់" },
  { name: "Dairy", nameKm: "ផលិតផលទឹកដោះគោ" },
  { name: "Bakery", nameKm: "នំប៉័ង និងនំ" },
  { name: "Beverages", nameKm: "ភេសជ្ជៈ" },
];

// priceCents = US dollars x 100  (350 = $3.50)

export type SeedProduct = {
  category: string;
  name: string;
  nameKm: string | null;
  description: string;
  origin: string;
  priceCents: number;
  imageUrl: string;
  stock: number;
  unit: string;
};

// Product image URL helper.
// Uses ingredient photos when an image key is provided.
// Otherwise, generates a labeled placeholder for the product.
const getProductImage = (name: string, imageKey: string | null): string => {
  if (imageKey) {
    return `https://www.themealdb.com/images/ingredients/${imageKey}.png`;
  }

  return `https://placehold.co/600x600/png?text=${encodeURIComponent(name)}`;
};

// Generate a complete SeedProduct.
const product = (
  category: string,
  name: string,
  nameKm: string,
  description: string,
  origin: string,
  priceCents: number,
  stock: number,
  unit: string,
  imageKey: string | null,
): SeedProduct => ({
  category,
  name,
  nameKm,
  description,
  origin,
  priceCents,
  imageUrl: getProductImage(name, imageKey),
  stock,
  unit,
});

export const products: SeedProduct[] = [
  // ============================
  // SPICES (6)
  // ============================

  product(
    "Spices",
    "Kampot Black Pepper",
    "ម្រេចខ្មៅកំពត",
    "Whole black peppercorns with a rich, floral aroma.",
    "Kampot, Cambodia",
    350,
    40,
    "100 g",
    "black_pepper",
  ),

  product(
    "Spices",
    "Kampot Red Pepper",
    "ម្រេចក្រហមកំពត",
    "Sweet, fruity red peppercorns, fully ripened on the vine.",
    "Kampot, Cambodia",
    420,
    18,
    "100 g",
    null,
  ),

  product(
    "Spices",
    "Kampot White Pepper",
    "ម្រេចសកំពត",
    "Mild and clean white peppercorns for soups and marinades.",
    "Kampot, Cambodia",
    380,
    25,
    "100 g",
    null,
  ),

  product(
    "Spices",
    "Chili Powder",
    "ម្សៅម្ទេស",
    "Ground dried chili for spicy cooking.",
    "Cambodia",
    150,
    45,
    "100 g",
    "chili_powder",
  ),

  product(
    "Spices",
    "Turmeric Powder",
    "ម្សៅរមៀត",
    "Ground turmeric for Khmer curries and soups.",
    "Cambodia",
    180,
    30,
    "100 g",
    "turmeric",
  ),

  product(
    "Spices",
    "Cinnamon",
    "ឈើអែម",
    "Aromatic dried cinnamon sticks.",
    "Cambodia",
    200,
    25,
    "100 g",
    "cinnamon",
  ),

  // ============================
  // PANTRY (15)
  // ============================

  product(
    "Pantry",
    "Palm Sugar",
    "ស្ករត្នោត",
    "Soft natural palm sugar, made the traditional way.",
    "Kampong Speu, Cambodia",
    280,
    30,
    "500 g",
    null,
  ),

  product(
    "Pantry",
    "Mondulkiri Wild Honey",
    "ទឹកឃ្មុំមណ្ឌលគិរី",
    "Dark, aromatic forest honey.",
    "Mondulkiri, Cambodia",
    950,
    0,
    "500 ml",
    "honey",
  ),

  product(
    "Pantry",
    "Kampot Fish Sauce",
    "ទឹកត្រីកំពត",
    "Traditional fermented fish sauce.",
    "Kampot, Cambodia",
    320,
    22,
    "500 ml",
    null,
  ),

  product(
    "Pantry",
    "Free-range Eggs",
    "ពងមាន់ស្រែ",
    "Fresh farm eggs from free-range chickens.",
    "Cambodia",
    200,
    25,
    "10 eggs",
    null,
  ),

  product(
    "Pantry",
    "Kroeung Paste",
    "គ្រឿងបុក",
    "Lemongrass, galangal and turmeric paste for Khmer curries.",
    "Cambodia",
    250,
    18,
    "200 g",
    null,
  ),

  product(
    "Pantry",
    "Jasmine Rice",
    "អង្ករផ្កាម្លិះ",
    "Fragrant white jasmine rice for everyday meals.",
    "Battambang, Cambodia",
    650,
    80,
    "5 kg",
    null,
  ),

  product(
    "Pantry",
    "Sticky Rice",
    "អង្ករដំណើប",
    "Glutinous rice for traditional Khmer desserts.",
    "Cambodia",
    250,
    60,
    "1 kg",
    null,
  ),

  product(
    "Pantry",
    "Rice Noodles",
    "គុយទាវ",
    "Dried rice noodles for soups and stir-fried dishes.",
    "Cambodia",
    180,
    55,
    "500 g",
    null,
  ),

  product(
    "Pantry",
    "Soy Sauce",
    "ទឹកស៊ីអ៊ីវ",
    "Savory soy sauce for cooking and dipping.",
    "Cambodia",
    220,
    40,
    "500 ml",
    "soy_sauce",
  ),

  product(
    "Pantry",
    "Oyster Sauce",
    "ទឹកប្រេងខ្យង",
    "Rich oyster sauce for stir-fried vegetables and meat.",
    "Thailand",
    280,
    35,
    "500 ml",
    "oyster_sauce",
  ),

  product(
    "Pantry",
    "Vegetable Cooking Oil",
    "ប្រេងឆា",
    "Refined vegetable oil for everyday cooking.",
    "Thailand",
    350,
    50,
    "1 L",
    "vegetable_oil",
  ),

  product(
    "Pantry",
    "Sea Salt",
    "អំបិលសមុទ្រ",
    "Natural sea salt harvested from coastal salt fields.",
    "Kampot, Cambodia",
    100,
    90,
    "500 g",
    "salt",
  ),

  product(
    "Pantry",
    "Coconut Milk",
    "ខ្ទិះដូង",
    "Rich coconut milk for traditional curries and desserts.",
    "Cambodia",
    200,
    45,
    "400 ml",
    null,
  ),

  product(
    "Pantry",
    "Fermented Fish Paste",
    "ប្រហុក",
    "Traditional Khmer fermented fish paste.",
    "Cambodia",
    300,
    30,
    "250 g",
    null,
  ),

  product(
    "Pantry",
    "Tamarind Paste",
    "អំពិលទុំ",
    "Sour tamarind paste for Khmer soups and dipping sauces.",
    "Cambodia",
    180,
    35,
    "250 g",
    null,
  ),

  // ============================
  // FRUIT (11)
  // ============================

  product(
    "Fruit",
    "Pursat Orange",
    "ក្រូចពោធិ៍សាត់",
    "Sweet and juicy oranges.",
    "Pursat, Cambodia",
    250,
    60,
    "1 kg",
    "orange",
  ),

  product(
    "Fruit",
    "Ripe Mango",
    "ស្វាយទុំ",
    "Sweet ripe mangoes, ready to eat.",
    "Cambodia",
    220,
    35,
    "1 kg",
    null,
  ),

  product(
    "Fruit",
    "Lime",
    "ក្រូចឆ្មារ",
    "Juicy limes for dipping sauces.",
    "Cambodia",
    100,
    0,
    "500 g",
    "lime",
  ),

  product(
    "Fruit",
    "Banana",
    "ចេក",
    "Naturally sweet bananas, perfect for snacking.",
    "Cambodia",
    150,
    75,
    "1 bunch",
    null,
  ),

  product(
    "Fruit",
    "Pineapple",
    "ម្នាស់",
    "Fresh tropical pineapple with sweet, juicy flesh.",
    "Cambodia",
    180,
    40,
    "1 fruit",
    "pineapple",
  ),

  product(
    "Fruit",
    "Papaya",
    "ល្ហុង",
    "Fresh papaya, suitable for fruit salad or smoothies.",
    "Cambodia",
    200,
    35,
    "1 kg",
    null,
  ),

  product(
    "Fruit",
    "Watermelon",
    "ឪឡឹក",
    "Refreshing, sweet watermelon.",
    "Cambodia",
    180,
    45,
    "1 kg",
    null,
  ),

  product(
    "Fruit",
    "Dragon Fruit",
    "ផ្លែស្រកានាគ",
    "Tropical dragon fruit with refreshing flesh.",
    "Cambodia",
    350,
    30,
    "1 kg",
    null,
  ),

  product(
    "Fruit",
    "Fresh Coconut",
    "ដូងស្រស់",
    "Young coconut with naturally sweet coconut water.",
    "Cambodia",
    120,
    65,
    "1 fruit",
    "coconut",
  ),

  product(
    "Fruit",
    "Rambutan",
    "សាវម៉ាវ",
    "Sweet and juicy tropical rambutan.",
    "Cambodia",
    400,
    25,
    "1 kg",
    null,
  ),

  product(
    "Fruit",
    "Pomelo",
    "ក្រូចថ្លុង",
    "Large citrus fruit with juicy, mildly sweet segments.",
    "Cambodia",
    300,
    30,
    "1 fruit",
    null,
  ),

  // ============================
  // VEGETABLES (19)
  // ============================

  product(
    "Vegetables",
    "Water Spinach (Morning Glory)",
    "ត្រកួន",
    "Fresh water spinach, perfect for stir-fry.",
    "Cambodia",
    50,
    80,
    "1 bunch",
    null,
  ),

  product(
    "Vegetables",
    "Garlic",
    "ខ្ទឹមស",
    "Local garlic bulbs.",
    "Cambodia",
    150,
    50,
    "250 g",
    "garlic",
  ),

  product(
    "Vegetables",
    "Red Onion",
    "ខ្ទឹមក្រហម",
    "Small red shallot onions.",
    "Cambodia",
    120,
    40,
    "250 g",
    "red_onion",
  ),

  product(
    "Vegetables",
    "Tomato",
    "ប៉េងប៉ោះ",
    "Ripe red tomatoes.",
    "Cambodia",
    130,
    45,
    "500 g",
    null,
  ),

  product(
    "Vegetables",
    "Lettuce",
    "សាឡាត់",
    "Crisp green lettuce.",
    "Cambodia",
    90,
    30,
    "1 head",
    "lettuce",
  ),

  product(
    "Vegetables",
    "Carrot",
    "ការ៉ុត",
    "Crunchy orange carrots for soups and salads.",
    "Cambodia",
    150,
    60,
    "500 g",
    "carrots",
  ),

  product(
    "Vegetables",
    "Cucumber",
    "ត្រសក់",
    "Fresh cucumbers for salads and dipping.",
    "Cambodia",
    120,
    55,
    "500 g",
    "cucumber",
  ),

  product(
    "Vegetables",
    "Cabbage",
    "ស្ពៃក្តោប",
    "Fresh green cabbage for soups and stir-fries.",
    "Cambodia",
    180,
    45,
    "1 kg",
    "cabbage",
  ),

  product(
    "Vegetables",
    "Chinese Cabbage",
    "ស្ពៃបូកគោ",
    "Tender leafy cabbage for soups and hot pots.",
    "Cambodia",
    160,
    35,
    "500 g",
    null,
  ),

  product(
    "Vegetables",
    "Eggplant",
    "ត្រប់វែង",
    "Fresh eggplants for grilling and traditional dishes.",
    "Cambodia",
    150,
    40,
    "500 g",
    "aubergine",
  ),

  product(
    "Vegetables",
    "Pumpkin",
    "ល្ពៅ",
    "Naturally sweet pumpkin for soups and desserts.",
    "Cambodia",
    200,
    30,
    "1 kg",
    "pumpkin",
  ),

  product(
    "Vegetables",
    "Sweet Potato",
    "ដំឡូងជ្វា",
    "Fresh sweet potatoes for roasting or boiling.",
    "Cambodia",
    180,
    50,
    "1 kg",
    null,
  ),

  product(
    "Vegetables",
    "Potato",
    "ដំឡូងបារាំង",
    "Fresh potatoes suitable for frying or boiling.",
    "Vietnam",
    220,
    45,
    "1 kg",
    "potatoes",
  ),

  product(
    "Vegetables",
    "Long Beans",
    "សណ្តែកគួរ",
    "Long green beans for Khmer stir-fries.",
    "Cambodia",
    120,
    50,
    "500 g",
    null,
  ),

  product(
    "Vegetables",
    "Broccoli",
    "ផ្កាខាត់ណាខៀវ",
    "Fresh green broccoli rich in nutrients.",
    "Cambodia",
    280,
    35,
    "500 g",
    "broccoli",
  ),

  product(
    "Vegetables",
    "Ginger",
    "ខ្ញី",
    "Fresh aromatic ginger for cooking.",
    "Cambodia",
    180,
    40,
    "250 g",
    "ginger",
  ),

  product(
    "Vegetables",
    "Lemongrass",
    "ស្លឹកគ្រៃ",
    "Fresh lemongrass for Khmer soups and curries.",
    "Cambodia",
    80,
    70,
    "1 bunch",
    "lemongrass",
  ),

  product(
    "Vegetables",
    "Fresh Chili Peppers",
    "ម្ទេសស្រស់",
    "Fresh hot chilies for sauces and spicy dishes.",
    "Cambodia",
    100,
    65,
    "100 g",
    null,
  ),

  product(
    "Vegetables",
    "Fresh Mushrooms",
    "ផ្សិតស្រស់",
    "Fresh mushrooms for soups and stir-fried dishes.",
    "Cambodia",
    220,
    35,
    "250 g",
    "mushrooms",
  ),

  // ============================
  // SEAFOOD (5)
  // ============================

  product(
    "Seafood",
    "Fresh Kep Crab",
    "ក្តាមកែប",
    "Live-caught blue crab.",
    "Kep, Cambodia",
    1400,
    12,
    "1 kg",
    null,
  ),

  product(
    "Seafood",
    "Fresh Shrimp",
    "បង្គាស្រស់",
    "Fresh shrimp suitable for grilling and soups.",
    "Cambodia",
    950,
    25,
    "1 kg",
    null,
  ),

  product(
    "Seafood",
    "Fresh Squid",
    "មឹកស្រស់",
    "Fresh squid for grilling and stir-fried dishes.",
    "Sihanoukville, Cambodia",
    850,
    20,
    "1 kg",
    "squid",
  ),

  product(
    "Seafood",
    "Tilapia Fish",
    "ត្រីទីឡាព្យា",
    "Fresh whole tilapia for steaming or frying.",
    "Cambodia",
    450,
    30,
    "1 kg",
    null,
  ),

  product(
    "Seafood",
    "Mackerel",
    "ត្រីកាម៉ុង",
    "Fresh mackerel suitable for frying and grilling.",
    "Cambodia",
    650,
    22,
    "1 kg",
    null,
  ),

  // ============================
  // MEAT (6)
  // ============================

  product(
    "Meat",
    "Beef Sirloin",
    "សាច់គោ",
    "Tender beef, good for Lok Lak and stir-fry.",
    "Cambodia",
    1200,
    15,
    "1 kg",
    "beef_fillet",
  ),

  product(
    "Meat",
    "Chicken Breast",
    "សាច់ទ្រូងមាន់",
    "Fresh boneless chicken breast.",
    "Cambodia",
    550,
    20,
    "1 kg",
    "chicken",
  ),

  product(
    "Meat",
    "Pork Belly",
    "សាច់ជ្រូកបីជាន់",
    "Fresh pork belly with alternating layers of fat and meat.",
    "Cambodia",
    650,
    30,
    "1 kg",
    "pork",
  ),

  product(
    "Meat",
    "Minced Pork",
    "សាច់ជ្រូកចិញ្ច្រាំ",
    "Fresh ground pork for soups and traditional dishes.",
    "Cambodia",
    550,
    25,
    "1 kg",
    null,
  ),

  product(
    "Meat",
    "Chicken Wings",
    "ស្លាបមាន់",
    "Fresh chicken wings for grilling and frying.",
    "Cambodia",
    450,
    35,
    "1 kg",
    null,
  ),

  product(
    "Meat",
    "Whole Chicken",
    "មាន់មូល",
    "Fresh whole chicken for family meals.",
    "Cambodia",
    700,
    20,
    "1 chicken",
    "chicken",
  ),

  // ============================
  // DAIRY (3)
  // ============================

  product(
    "Dairy",
    "Fresh Milk",
    "ទឹកដោះគោស្រស់",
    "Fresh dairy milk suitable for drinking and cooking.",
    "Thailand",
    250,
    40,
    "1 L",
    "milk",
  ),

  product(
    "Dairy",
    "Plain Yogurt",
    "យ៉ាអួ",
    "Creamy plain yogurt with a mild flavor.",
    "Thailand",
    180,
    30,
    "400 g",
    "yogurt",
  ),

  product(
    "Dairy",
    "Butter",
    "ប៊ឺ",
    "Creamy butter for cooking and baking.",
    "New Zealand",
    350,
    25,
    "200 g",
    "butter",
  ),

  // ============================
  // BAKERY (2)
  // ============================

  product(
    "Bakery",
    "White Bread",
    "នំប៉័ងស",
    "Soft sliced white bread for breakfast and sandwiches.",
    "Cambodia",
    180,
    35,
    "1 loaf",
    "bread",
  ),

  product(
    "Bakery",
    "French Baguette",
    "នំប៉័ងបារាំង",
    "Fresh baguette with a crispy crust and soft inside.",
    "Cambodia",
    100,
    45,
    "1 loaf",
    null,
  ),

  // ============================
  // BEVERAGES (3)
  // ============================

  product(
    "Beverages",
    "Bottled Water",
    "ទឹកបរិសុទ្ធ",
    "Clean drinking water in a convenient bottle.",
    "Cambodia",
    50,
    100,
    "500 ml",
    null,
  ),

  product(
    "Beverages",
    "Coconut Water",
    "ទឹកដូង",
    "Refreshing coconut water.",
    "Cambodia",
    150,
    55,
    "350 ml",
    null,
  ),

  product(
    "Beverages",
    "Soy Milk",
    "ទឹកសណ្តែក",
    "Smooth soy milk for a refreshing drink.",
    "Cambodia",
    120,
    50,
    "350 ml",
    null,
  ),
];

async function main() {
  // 1) Categories: create the missing ones, update the Khmer name of existing ones.
  const categoryIds = new Map<string, string>();

  for (const c of categories) {
    const found = await prisma.category.findFirst({ where: { name: c.name } });
    const saved = found
      ? await prisma.category.update({
          where: { id: found.id },
          data: { nameKm: c.nameKm },
        })
      : await prisma.category.create({
          data: { name: c.name, nameKm: c.nameKm },
        });

    categoryIds.set(saved.name, saved.id);
  }

  // 2) Products: update if the name already exists, otherwise create.
  for (const { category, ...data } of products) {
    const categoryId = categoryIds.get(category);
    if (!categoryId) throw new Error(`Unknown category: ${category}`);

    const found = await prisma.product.findFirst({
      where: { name: data.name },
    });
    if (found) {
      await prisma.product.update({
        where: { id: found.id },
        data: { ...data, categoryId },
      });
    } else {
      await prisma.product.create({ data: { ...data, categoryId } });
    }
  }

  console.log(
    `Seeded ${categories.length} categories and ${products.length} products`,
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
