import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';

/// Offline preview catalog, shaped like the server's data. Used when
/// `API_BASE_URL` is not configured, and by tests.

const vegetablesCategory = ProductCategory(
  id: 'vegetables',
  name: 'Organic Vegetables',
  nameKm: 'បន្លែសរីរាង្គ',
  productCount: 1,
  imageUrl: 'assets/images/market/greens.jpg',
  description: 'Crisp Organic Vegetables',
  descriptionKm: 'បន្លែសរីរាង្គស្រស់ៗ',
  origin: 'Battambang',
  originKm: 'បាត់ដំបង',
);
const fruitsCategory = ProductCategory(
  id: 'fruits',
  name: 'Local Fruits',
  nameKm: 'ផ្លែឈើក្នុងស្រុក',
  productCount: 2,
  imageUrl: 'assets/images/market/fruits.jpg',
  description: 'Mangoes, Dragonfruit & Mangosteen',
  descriptionKm: 'ស្វាយ ស្រកានាគ និងមង្ឃុត',
  origin: 'Kampong Speu',
  originKm: 'កំពង់ស្ពឺ',
);
const spicesCategory = ProductCategory(
  id: 'spices',
  name: 'Kampot Spices',
  nameKm: 'គ្រឿងទេសកំពត',
  productCount: 1,
  imageUrl: 'assets/images/market/spices.jpg',
  description: 'GI Black Pepper & Kep Fleur de Sel',
  descriptionKm: 'ម្រេចខ្មៅ GI និងអំបិលផ្កាកែប',
  origin: 'Kampot GI',
  originKm: 'កំពត GI',
);
const seafoodCategory = ProductCategory(
  id: 'seafood',
  name: 'Fresh Seafood',
  nameKm: 'ត្រី និងគ្រឿងសមុទ្រស្រស់',
  productCount: 1,
  imageUrl: 'assets/images/market/fish.jpg',
  description: 'River Harvest & Fresh Seafood',
  descriptionKm: 'ត្រីទន្លេ និងគ្រឿងសមុទ្រស្រស់',
  origin: 'Tonle Sap',
  originKm: 'ទន្លេសាប',
);
const riceCategory = ProductCategory(
  id: 'rice',
  name: 'Jasmine Rice',
  nameKm: 'អង្ករផ្កាម្លិះ',
  productCount: 1,
  imageUrl: 'assets/images/market/rice.jpg',
  description: 'Premium Fragrant Jasmine',
  descriptionKm: 'អង្ករផ្កាម្លិះក្រអូបគុណភាពខ្ពស់',
  origin: 'World Best',
  originKm: 'ល្អបំផុតលើពិភពលោក',
);
const eggsCategory = ProductCategory(
  id: 'eggs',
  name: 'Free-Range Eggs',
  nameKm: 'ស៊ុតមាន់ចិញ្ចឹមលែង',
  productCount: 1,
  imageUrl: 'assets/images/market/eggs.jpg',
  description: 'Pasture-Raised Organic Eggs',
  descriptionKm: 'ស៊ុតមាន់សរីរាង្គចិញ្ចឹមលែង',
  origin: 'Free-Range',
  originKm: 'ចិញ្ចឹមលែង',
);

const marketCategories = [
  vegetablesCategory,
  fruitsCategory,
  spicesCategory,
  seafoodCategory,
  riceCategory,
  eggsCategory,
];

const _kg = 'kg';
const _kgKm = 'គីឡូ';

const citrusDealProduct = MarketProduct(
  id: 'citrus',
  name: 'Fresh Pursat Citrus',
  nameKm: 'ក្រូចស្រស់ពីពោធិ៍សាត់',
  summary: 'Fresh Pursat Citrus • Naturally Sweet & Juicy',
  summaryKm: 'ក្រូចស្រស់ពីពោធិ៍សាត់ • ផ្អែមតាមធម្មជាតិ',
  unit: _kg,
  unitKm: _kgKm,
  priceInCents: 240,
  imageUrl: 'assets/images/market/citrus.jpg',
  category: fruitsCategory,
);

const greensProduct = MarketProduct(
  id: 'greens',
  name: 'Battambang Greens',
  nameKm: 'បន្លែបាត់ដំបង',
  summary: 'Crisp Organic Vegetables',
  summaryKm: 'បន្លែសរីរាង្គស្រស់ៗ',
  origin: 'Battambang',
  unit: _kg,
  unitKm: _kgKm,
  priceInCents: 180,
  imageUrl: 'assets/images/market/greens.jpg',
  category: vegetablesCategory,
  isOrganic: true,
  isNewArrival: true,
  isPopular: true,
);
const fruitsProduct = MarketProduct(
  id: 'mangoes',
  name: 'Tropical Fruits',
  nameKm: 'ផ្លែឈើត្រូពិច',
  summary: 'Mangoes, Dragonfruit & Mangosteen',
  summaryKm: 'ស្វាយ ស្រកានាគ និងមង្ឃុត',
  origin: 'Kampong Speu',
  unit: _kg,
  unitKm: _kgKm,
  priceInCents: 320,
  imageUrl: 'assets/images/market/fruits.jpg',
  category: fruitsCategory,
  isOrganic: true,
  isNewArrival: true,
);
const eggsProduct = MarketProduct(
  id: 'eggs',
  name: 'Farm Fresh Eggs',
  nameKm: 'ស៊ុតស្រស់ពីកសិដ្ឋាន',
  summary: 'Pasture-Raised Organic Eggs',
  summaryKm: 'ស៊ុតមាន់សរីរាង្គចិញ្ចឹមលែង',
  origin: 'Kandal',
  unit: '6 eggs',
  unitKm: 'ស៊ុត ៦ គ្រាប់',
  priceInCents: 250,
  imageUrl: 'assets/images/market/eggs.jpg',
  category: eggsCategory,
  isOrganic: true,
  isPopular: true,
);
const spicesProduct = MarketProduct(
  id: 'spices',
  name: 'Kampot Spices & Salt',
  nameKm: 'គ្រឿងទេស និងអំបិលកំពត',
  summary: 'GI Black Pepper & Kep Fleur de Sel',
  summaryKm: 'ម្រេចខ្មៅ GI និងអំបិលផ្កាកែប',
  origin: 'Kampot',
  unit: 'pack',
  unitKm: 'កញ្ចប់',
  priceInCents: 450,
  imageUrl: 'assets/images/market/spices.jpg',
  category: spicesCategory,
);
const fishProduct = MarketProduct(
  id: 'fish',
  name: 'Tonle Sap Fresh Catch',
  nameKm: 'ត្រីស្រស់ទន្លេសាប',
  summary: 'River Harvest & Fresh Seafood',
  summaryKm: 'ត្រីទន្លេ និងគ្រឿងសមុទ្រស្រស់',
  origin: 'Tonle Sap',
  unit: _kg,
  unitKm: _kgKm,
  priceInCents: 580,
  imageUrl: 'assets/images/market/fish.jpg',
  category: seafoodCategory,
  isNewArrival: true,
);
const riceProduct = MarketProduct(
  id: 'rice',
  name: 'Phka Rumduol Rice',
  nameKm: 'អង្ករផ្ការំដួល',
  summary: 'Premium Fragrant Jasmine',
  summaryKm: 'អង្ករផ្កាម្លិះក្រអូបគុណភាពខ្ពស់',
  origin: 'Battambang',
  unit: _kg,
  unitKm: _kgKm,
  priceInCents: 220,
  imageUrl: 'assets/images/market/rice.jpg',
  category: riceCategory,
  isPopular: true,
);

/// Demo merchandising selections; no live inventory or sales ranking.
const marketProducts = [
  greensProduct,
  fruitsProduct,
  eggsProduct,
  citrusDealProduct,
  spicesProduct,
  fishProduct,
  riceProduct,
];
