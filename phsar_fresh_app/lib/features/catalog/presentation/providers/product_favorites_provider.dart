import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';

/// Saved products for this session, newest last, keyed by product id.
class ProductFavoritesNotifier extends Notifier<Map<String, MarketProduct>> {
  @override
  Map<String, MarketProduct> build() => const {};

  void toggle(MarketProduct product) {
    final favorites = {...state};
    if (favorites.remove(product.id) == null) {
      favorites[product.id] = product;
    }
    state = Map.unmodifiable(favorites);
  }

  void remove(String id) {
    if (!state.containsKey(id)) return;
    state = Map.unmodifiable({...state}..remove(id));
  }
}

final productFavoritesProvider =
    NotifierProvider<ProductFavoritesNotifier, Map<String, MarketProduct>>(
      ProductFavoritesNotifier.new,
    );
