import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/catalog_repository.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_filter.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';

import '../../support/market_test_fixtures.dart';

/// Loads a product list the way a page does (kept alive while listened to).
Future<ProductListState> loadProducts(
  ProviderContainer container,
  MarketFilter filter,
) async {
  final provider = productListProvider(productRequestFor(filter));
  final subscription = container.listen(provider, (_, _) {});
  addTearDown(subscription.close);
  return container.read(provider.future);
}

Future<List<String>> productIds(
  ProviderContainer container,
  MarketFilter filter,
) async => [
  for (final product in (await loadProducts(container, filter)).items)
    product.id,
];

/// A large server-like catalog for paging.
class _ManyProducts implements CatalogRepository {
  final requestedPages = <int>[];

  @override
  bool get isRemote => false;

  @override
  Future<List<ProductCategory>> categories() async => const [];

  @override
  Future<ProductPage> products(
    ProductRequest request, {
    int page = 1,
    int limit = 20,
  }) async {
    requestedPages.add(page);
    const total = 45;
    final start = (page - 1) * limit;
    return ProductPage(
      items: [
        for (var i = start; i < (start + limit).clamp(0, total); i++)
          MarketProduct(
            id: 'p$i',
            name: 'Product $i',
            unit: 'kg',
            priceInCents: 100,
            category: vegetablesCategory,
          ),
      ],
      page: page,
      hasMore: start + limit < total,
    );
  }

  @override
  Future<List<MarketPromotion>> promotions() async => const [];

  @override
  Future<List<AppBanner>> banners() async => const [];

  @override
  Future<List<MarketProduct>> popularProducts({int limit = 8}) async =>
      const [];
}

void main() {
  test(
    'Category filters and Explore filters are independent in both directions',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final categories = container.read(marketFilterProvider.notifier);
      final explore = container.read(exploreFilterProvider.notifier);
      categories.applyOptions(inStockOnly: true, sort: MarketSort.itemCount);
      categories.selectCategory('fruits');
      categories.search('mango');
      expect(container.read(exploreFilterProvider).query, isEmpty);
      expect(container.read(exploreFilterProvider).categoryId, isNull);
      final categoryState = container.read(marketFilterProvider);
      explore.search('rice');
      explore.applyOptions(inStockOnly: false, sort: MarketSort.name);
      expect(container.read(marketFilterProvider), same(categoryState));
      explore.reset();
      expect(container.read(marketFilterProvider), same(categoryState));
      categories.selectCategory(null);
      expect(container.read(marketFilterProvider).categoryId, isNull);
      expect(container.read(marketFilterProvider).query, 'mango');
    },
  );

  test('Cart totals update when a deal is added, changed or removed', () {
    final container = ProviderContainer(overrides: [seededCartOverride]);
    addTearDown(container.dispose);
    final cart = container.read(marketCartProvider.notifier);
    expect(container.read(marketCartCountProvider), 3);
    cart.add(citrusDealProduct);
    expect(container.read(marketCartCountProvider), 4);
    cart.add(citrusDealProduct);
    expect(container.read(marketCartProvider).length, 4);
    expect(container.read(marketCartCountProvider), 5);
    cart.setQuantity('citrus', 0);
    expect(container.read(marketCartCountProvider), 3);
  });

  test(
    'Product search covers both languages and combines category and stock',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        await productIds(container, const MarketFilter(query: 'mangoes')),
        ['mangoes'],
      );
      expect(await productIds(container, const MarketFilter(query: 'ស៊ុត')), [
        'eggs',
      ]);
      expect(
        await productIds(container, const MarketFilter(categoryId: 'seafood')),
        ['fish'],
      );
      expect(
        await productIds(
          container,
          const MarketFilter(categoryId: 'fruits', inStockOnly: true),
        ),
        ['mangoes', 'citrus'],
      );
      final all = await loadProducts(container, const MarketFilter());
      expect(all.hasMore, isFalse);
      expect(
        sortProducts(
          all.items,
          MarketSort.itemCount,
          'en',
        ).take(3).every((product) => product.isPopular),
        isTrue,
      );
    },
  );

  test('Preview popular products put favourites first', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final popular = await container.read(popularProductsProvider.future);
    expect(popular.take(3).map((product) => product.id), [
      'greens',
      'eggs',
      'rice',
    ]);
    expect(popular, hasLength(7));
  });

  test('Long lists load more pages on request', () async {
    final repository = _ManyProducts();
    final container = ProviderContainer(
      overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final first = await loadProducts(container, const MarketFilter());
    expect(first.items, hasLength(20));
    expect(first.hasMore, isTrue);

    final notifier = container.read(
      productListProvider(productRequestFor(const MarketFilter())).notifier,
    );
    await notifier.loadMore();
    await notifier.loadMore();
    final last = await loadProducts(container, const MarketFilter());
    expect(last.items, hasLength(45));
    expect(last.items.last.id, 'p44');
    expect(last.hasMore, isFalse);
    await notifier.loadMore(); // nothing more to load
    expect(repository.requestedPages, [1, 2, 3]);
  });
}
