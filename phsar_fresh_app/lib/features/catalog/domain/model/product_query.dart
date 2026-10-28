import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';

/// What to load from `GET /products`. Records compare by value, so this is a
/// stable key for the product list providers.
typedef ProductRequest = ({
  String search,
  String? categoryId,
  bool inStockOnly,
});

/// One page of `GET /products`.
class ProductPage {
  const ProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<MarketProduct> items;
  final int page;
  final bool hasMore;
}
