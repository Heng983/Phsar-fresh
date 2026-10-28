import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_promotions.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';

/// Where categories and products come from.
abstract interface class CatalogRepository {
  /// True when requests go over the network (searches are then debounced).
  bool get isRemote;

  Future<List<ProductCategory>> categories();

  /// Products in the server's order: in stock first, then A–Z.
  Future<ProductPage> products(
    ProductRequest request, {
    int page = 1,
    int limit = 20,
  });

  Future<List<MarketPromotion>> promotions();

  /// Picture banners made in the admin panel. Empty = the app shows its
  /// built-in Ming Sros banner instead.
  Future<List<AppBanner>> banners();

  /// Best sellers first, at most [limit].
  Future<List<MarketProduct>> popularProducts({int limit = 8});
}

/// The offline preview catalog, searched the same way as the server
/// (English and Khmer names, descriptions, origins and categories).
class LocalCatalogRepository implements CatalogRepository {
  const LocalCatalogRepository();

  @override
  bool get isRemote => false;

  @override
  Future<List<ProductCategory>> categories() async => marketCategories;

  @override
  Future<ProductPage> products(
    ProductRequest request, {
    int page = 1,
    int limit = 20,
  }) async {
    final words = request.search.toLowerCase().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);
    final matches = marketProducts.where((product) {
      if (request.categoryId != null &&
          product.category.id != request.categoryId) {
        return false;
      }
      if (request.inStockOnly && !product.inStock) return false;
      final text = _searchText(product);
      return words.every(text.contains);
    }).toList();
    final start = (page - 1) * limit;
    return ProductPage(
      items: matches.skip(start).take(limit).toList(growable: false),
      page: page,
      hasMore: start + limit < matches.length,
    );
  }

  @override
  Future<List<MarketPromotion>> promotions() async => marketPromotions;

  @override
  Future<List<AppBanner>> banners() async => const [];

  /// Products marked popular first, then the catalog order.
  @override
  Future<List<MarketProduct>> popularProducts({int limit = 8}) async {
    final sorted = [...marketProducts]
      ..sort((a, b) => (b.isPopular ? 1 : 0) - (a.isPopular ? 1 : 0));
    return sorted.take(limit).toList(growable: false);
  }

  static String _searchText(MarketProduct product) {
    final category = product.category;
    return [
      product.name,
      product.nameKm,
      product.summary,
      product.summaryKm,
      product.origin,
      category.name,
      category.nameKm,
      category.origin,
      category.originKm,
    ].whereType<String>().join(' ').toLowerCase();
  }
}
