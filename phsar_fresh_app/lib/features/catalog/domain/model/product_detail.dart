import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';

import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';

export 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';

class ProductDetail {
  final MarketProduct product;
  final List<String> images;
  final List<ProductPackOption> packs;

  /// Preview-only farm details; server products show their origin instead.
  final String? farmName;
  final String? farmAddress;

  const ProductDetail({
    required this.product,
    required this.images,
    required this.packs,
    this.farmName,
    this.farmAddress,
  });

  /// The default pack, or null when the product has a single price.
  ProductPackOption? get defaultPack =>
      packs.where((pack) => pack.isDefault).firstOrNull;
}
