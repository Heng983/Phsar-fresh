import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/explore_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_product_card.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/pump_helpers.dart';

void main() {
  for (final language in ['en', 'km']) {
    for (final width in [320.0, 375.0, 720.0]) {
      testWidgets('Explore sections fit $language at $width', (tester) async {
        await pumpMarket(
          tester,
          explore: true,
          language: language,
          width: width,
          scale: width == 320 ? 1.4 : 1,
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(ExplorePage)),
        )!;
        expect(find.text(l10n.exploreTodayHarvest), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text(l10n.explorePopular),
          200,
          scrollable: find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.explorePopular), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('Explore cards open details to add a product to the basket', (
    tester,
  ) async {
    await pumpMarket(tester, explore: true);
    await tester.enterText(find.byKey(const Key('market-search')), 'rice');
    await tester.pumpAndSettle();
    expect(find.byType(MarketProductCard), findsOneWidget);
    expect(find.byKey(const Key('explore-results-rice')), findsOneWidget);
    final card = find.byKey(const Key('explore-results-rice'));
    expect(
      find.descendant(of: card, matching: find.byType(FilledButton)),
      findsNothing,
    );
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailPage), findsOneWidget);
    await tester.tap(find.byKey(const Key('product-detail-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-tab-cart')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('market-cart-total')));
    await tester.pumpAndSettle();
    expect(find.text('\$9.70'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Explore shortcuts open matching categories and the tab can switch back',
    (tester) async {
      await pumpMarket(tester, explore: true);
      final shortcut = find.byKey(const Key('explore-category-fruits'));
      // The mini-cart bar makes the viewport shorter, so the shortcut row
      // may not be built yet; scroll until it is.
      await tester.scrollUntilVisible(
        shortcut,
        200,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      expect(find.byType(ExplorePage), findsNothing);
      // Fruits are shown on Categories: mangoes and citrus.
      expect(
        find.byKey(const Key('explore-in-category-mangoes')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('explore-in-category-citrus')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('explore-in-category-greens')), findsNothing);
      await tester.tap(find.byKey(const Key('market-tab-explore')));
      await tester.pumpAndSettle();
      expect(find.byType(ExplorePage), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1500));
      await tester.pumpAndSettle();
      expect(find.text("Today's harvest deals"), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('See all, in-stock filter and empty product search work', (
    tester,
  ) async {
    await pumpMarket(tester, explore: true);
    // hitTestable: keep scrolling until "See all" is tappable, not just
    // built behind the mini-cart bar at the bottom of the screen.
    final seeAll = find.text('See all').hitTestable();
    await tester.scrollUntilVisible(
      seeAll,
      200,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(seeAll.first);
    await tester.pumpAndSettle();
    expect(find.text('Shop fresh products'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Popular first'), findsOneWidget);
    await tester.tap(find.text('Popular first'));
    await tester.tap(find.byKey(const Key('market-in-stock-filter')));
    await tester.tap(find.byKey(const Key('market-apply-filters')));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ExplorePage)),
    );
    final filter = container.read(exploreFilterProvider);
    expect(filter.inStockOnly, isTrue);
    final loaded = container
        .read(productListProvider(productRequestFor(filter)))
        .value!
        .items;
    // Popular products first, then the catalog order.
    expect(sortProducts(loaded, filter.sort, 'en').map((p) => p.id), [
      'greens',
      'eggs',
      'rice',
      'mangoes',
      'citrus',
      'spices',
      'fish',
    ]);
    await tester.enterText(
      find.byKey(const Key('market-search')),
      'no-such-product',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching products'), findsOneWidget);
    await tester.ensureVisible(find.text('Reset filters').last);
    await tester.tap(find.text('Reset filters').last);
    await tester.pumpAndSettle();
    expect(find.text("Today's harvest deals"), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Explore banner opens Ming Sros chat', (tester) async {
    await pumpMarket(tester, explore: true);
    await tester.ensureVisible(
      find.byKey(const Key('market-promotions-carousel')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('promotion-dot-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ming-sros-open')).hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(ExplorePage), findsNothing);
    expect(find.text('Ming Sros'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Popular shows best sellers first, at most six', (tester) async {
    await pumpMarket(tester, explore: true);
    await tester.scrollUntilVisible(
      find.byKey(const Key('explore-popular-greens')),
      200,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Popular this week', skipOffstage: false), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ExplorePage)),
    );
    final popular = container.read(popularProductsProvider).value!;
    expect(popular.length, greaterThan(6));
    for (final product in popular.skip(6)) {
      expect(
        find.byKey(Key('explore-popular-${product.id}'), skipOffstage: false),
        findsNothing,
      );
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Popular section hides when there are none', (tester) async {
    setTestScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [popularProductsProvider.overrideWith((ref) async => [])],
        child: testApp(
          home: Scaffold(
            body: ExplorePage(onCategory: (_) {}, onOpenChat: () {}),
          ),
          disableAnimations: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(find.text('Popular this week'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
