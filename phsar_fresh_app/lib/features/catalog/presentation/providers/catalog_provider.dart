import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/features/catalog/data/catalog_repository.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_filter.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';

/// The preview catalog by default; `main.dart` installs the server's.
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => const LocalCatalogRepository(),
);

final categoriesProvider = FutureProvider<List<ProductCategory>>(
  (ref) => ref.watch(catalogRepositoryProvider).categories(),
);

/// Best sellers for Explore (it shows the first six).
final popularProductsProvider = FutureProvider<List<MarketProduct>>(
  (ref) => ref.watch(catalogRepositoryProvider).popularProducts(),
);

class MarketFilterNotifier extends Notifier<MarketFilter> {
  @override
  MarketFilter build() => const MarketFilter();

  void search(String query) => state = state.copyWith(query: query);

  /// Null shows every category.
  void selectCategory(String? categoryId) =>
      state = state.copyWith(categoryId: () => categoryId);

  void applyOptions({required bool inStockOnly, required MarketSort sort}) =>
      state = state.copyWith(inStockOnly: inStockOnly, sort: sort);

  void reset() => state = const MarketFilter();
}

/// Categories and Explore keep independent search, filter and sort choices.
final marketFilterProvider =
    NotifierProvider<MarketFilterNotifier, MarketFilter>(
      MarketFilterNotifier.new,
    );

final exploreFilterProvider =
    NotifierProvider<MarketFilterNotifier, MarketFilter>(
      MarketFilterNotifier.new,
    );

ProductRequest productRequestFor(MarketFilter filter) => (
  search: filter.query.trim(),
  categoryId: filter.categoryId,
  inStockOnly: filter.inStockOnly,
);

/// Applies the sort choice to products already loaded from the catalog.
List<MarketProduct> sortProducts(
  List<MarketProduct> products,
  MarketSort sort,
  String languageCode,
) {
  final sorted = [...products];
  switch (sort) {
    case MarketSort.curated:
      break;
    case MarketSort.name:
      sorted.sort(
        (a, b) => a
            .localizedName(languageCode)
            .compareTo(b.localizedName(languageCode)),
      );
    case MarketSort.itemCount:
      // Popular first; otherwise keep the catalog order (stable sort).
      final order = {for (var i = 0; i < products.length; i++) products[i]: i};
      sorted.sort((a, b) {
        final popularity = (b.isPopular ? 1 : 0) - (a.isPopular ? 1 : 0);
        return popularity != 0 ? popularity : order[a]!.compareTo(order[b]!);
      });
  }
  return List.unmodifiable(sorted);
}

class ProductListState {
  const ProductListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<MarketProduct> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  ProductListState copyWith({bool? loadingMore}) => ProductListState(
    items: items,
    page: page,
    hasMore: hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

/// One product list per request, with "load more" paging.
class ProductListNotifier extends AsyncNotifier<ProductListState> {
  ProductListNotifier(this.request);

  final ProductRequest request;
  static const pageSize = 20;

  @override
  Future<ProductListState> build() async {
    final repository = ref.watch(catalogRepositoryProvider);
    // Browsing lists stay cached across tabs; search results do not.
    if (request.search.isEmpty) ref.keepAlive();
    if (repository.isRemote && request.search.isNotEmpty) {
      // Wait for the user to stop typing before asking the server.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!ref.mounted) {
        return const ProductListState(items: [], page: 0, hasMore: false);
      }
    }
    final page = await repository.products(request, limit: pageSize);
    return ProductListState(
      items: page.items,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(catalogRepositoryProvider)
          .products(request, page: current.page + 1, limit: pageSize);
      if (!ref.mounted) return;
      state = AsyncData(
        ProductListState(
          items: List.unmodifiable([...current.items, ...next.items]),
          page: next.page,
          hasMore: next.hasMore,
        ),
      );
    } on Object {
      // Keep what is shown; the "Load more" button stays available.
      if (ref.mounted) state = AsyncData(current);
    }
  }
}

final productListProvider = AsyncNotifierProvider.autoDispose
    .family<ProductListNotifier, ProductListState, ProductRequest>(
      ProductListNotifier.new,
    );
