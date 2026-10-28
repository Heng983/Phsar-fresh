import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/catalog/data/catalog_repository.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';

import '../../support/pump_helpers.dart';

/// The preview catalog, answering only once [release] is called.
class _SlowCatalog implements CatalogRepository {
  final _local = const LocalCatalogRepository();
  final _ready = Completer<void>();

  void release() => _ready.complete();

  Future<T> _later<T>(Future<T> Function() load) async {
    await _ready.future;
    return load();
  }

  @override
  bool get isRemote => true;

  @override
  Future<List<ProductCategory>> categories() => _later(_local.categories);

  @override
  Future<ProductPage> products(
    ProductRequest request, {
    int page = 1,
    int limit = 20,
  }) => _later(() => _local.products(request, page: page, limit: limit));

  @override
  Future<List<MarketPromotion>> promotions() => _later(_local.promotions);

  @override
  Future<List<AppBanner>> banners() async => const [];

  @override
  Future<List<MarketProduct>> popularProducts({int limit = 8}) =>
      _later(() => _local.popularProducts(limit: limit));
}

/// Answers everything at once except banners, which wait for [release].
class _SlowBanners extends _SlowCatalog {
  final _bannersReady = Completer<void>();

  _SlowBanners() {
    super.release();
  }

  @override
  void release() => _bannersReady.complete();

  @override
  Future<List<AppBanner>> banners() async {
    await _bannersReady.future;
    return const [];
  }
}

void main() {
  testWidgets('Explore shows skeletons until the catalog answers', (
    tester,
  ) async {
    final catalog = _SlowCatalog();
    await pumpMarket(tester, explore: true, catalog: catalog, settle: false);
    await tester.pump();
    expect(find.byKey(const Key('market-promotions-loading')), findsOneWidget);
    expect(find.byKey(const Key('explore-categories-loading')), findsOneWidget);

    catalog.release();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('market-promotions-loading')), findsNothing);
    expect(find.byKey(const Key('explore-categories-loading')), findsNothing);
    expect(find.byKey(const Key('catalog-loading')), findsNothing);
    // The mini-cart bar shortens the screen; scroll the row into view.
    await tester.scrollUntilVisible(
      find.byKey(const Key('explore-category-vegetables')),
      200,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const Key('explore-category-vegetables')), findsOne);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Explore keeps the deal skeleton until banners load too', (
    tester,
  ) async {
    final catalog = _SlowBanners();
    await pumpMarket(tester, explore: true, catalog: catalog, settle: false);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('market-promotions-loading')), findsOneWidget);
    expect(find.byKey(const Key('market-promotions-carousel')), findsNothing);

    catalog.release();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('market-promotions-loading')), findsNothing);
    expect(find.byKey(const Key('market-promotions-carousel')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Categories shows a product skeleton until products load', (
    tester,
  ) async {
    final catalog = _SlowCatalog();
    await pumpMarket(tester, catalog: catalog, settle: false);
    await tester.pump();
    expect(find.byKey(const Key('catalog-loading')), findsOneWidget);

    catalog.release();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('catalog-loading')), findsNothing);
    expect(find.byKey(const Key('explore-all-greens')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
