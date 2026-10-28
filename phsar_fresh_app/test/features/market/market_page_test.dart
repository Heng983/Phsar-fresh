import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/app.dart';
import 'package:phsar_fresh_app/features/cart/presentation/pages/cart_page.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_filter.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_product_card.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';
import 'package:phsar_fresh_app/features/orders/presentation/pages/orders_page.dart';

import '../../support/pump_helpers.dart';

void main() {
  testWidgets('Cart and Orders labels open their pages after reordering tabs', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('Your Basket'), findsOneWidget);
    final cartBadge = tester.widget<Badge>(
      find.descendant(
        of: find.byKey(const Key('market-tab-cart')),
        matching: find.byType(Badge),
      ),
    );
    expect(cartBadge.isLabelVisible, isTrue);
    expect((cartBadge.label! as Text).data, '3');
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsOneWidget);
    expect(find.text('My orders'), findsOneWidget);
    final ordersBadge = tester.widget<Badge>(
      find.descendant(
        of: find.byKey(const Key('market-tab-orders')),
        matching: find.byType(Badge),
      ),
    );
    expect(ordersBadge.isLabelVisible, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final language in ['en', 'km']) {
    for (final width in [320.0, 375.0, 720.0]) {
      testWidgets('Market layout fits $language at width $width', (
        tester,
      ) async {
        await pumpMarket(tester, width: width, language: language);
        expect(find.byKey(const Key('market-search')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1000),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('explore-all-rice')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('Search, categories and an empty result can be reset', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.enterText(find.byKey(const Key('market-search')), 'Kampot');
    await tester.pumpAndSettle();
    expect(find.byType(MarketProductCard), findsOneWidget);
    expect(find.byKey(const Key('explore-all-spices')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('category-fruits')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-fruits')));
    await tester.pumpAndSettle();
    // Fruits contain nothing matching "Kampot".
    expect(find.byType(MarketProductCard), findsNothing);
    await tester.ensureVisible(find.text('Reset filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('explore-all-greens')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Filter sheet applies in-stock and sort choices', (tester) async {
    await pumpMarket(tester);
    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-in-stock-filter')));
    await tester.tap(find.text('Name'));
    await tester.tap(find.byKey(const Key('market-apply-filters')));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MarketProductCard).first),
    );
    final filter = container.read(marketFilterProvider);
    expect(filter.inStockOnly, isTrue);
    expect(filter.sort, MarketSort.name);
    final names = tester
        .widgetList<MarketProductCard>(find.byType(MarketProductCard))
        .map((card) => card.product.name)
        .toList();
    expect(names, isNotEmpty);
    expect(names, [...names]..sort());
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Deal adds to the basket and cart quantities update', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.ensureVisible(
      find.byKey(const Key('market-promotions-carousel')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('claim-deal-citrus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-tab-cart')));
    await tester.pumpAndSettle();
    expect(find.text('Your Basket'), findsOneWidget);
    expect(find.text('Fresh Pursat Citrus'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('market-cart-total')));
    await tester.pumpAndSettle();
    expect(find.text('\$9.90'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Increase quantity').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase quantity').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('market-cart-total')));
    await tester.pumpAndSettle();
    expect(find.text('\$11.70'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Categories open product details and navigation switches sections',
    (tester) async {
      await pumpMarket(tester);
      await tester.ensureVisible(find.byKey(const Key('category-vegetables')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category-vegetables')));
      await tester.pumpAndSettle();
      // A category opens its products; a product opens its details.
      final greens = find.byKey(const Key('explore-in-category-greens'));
      await tester.ensureVisible(greens);
      await tester.pumpAndSettle();
      await tester.tap(greens);
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.text('Battambang Greens').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsNothing);
      expect(greens, findsOneWidget);
      await tester.tap(find.byKey(const Key('market-tab-orders')));
      await tester.pumpAndSettle();
      expect(find.text('My orders'), findsOneWidget);
      await tester.tap(find.byKey(const Key('market-tab-chat')));
      await tester.pumpAndSettle();
      expect(find.text('Ming Sros'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Compact market layout handles larger text', (tester) async {
    await pumpMarket(tester, width: 320, scale: 1.4);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Guest profile and login lead back to the market', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PhsarFreshApp()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-guest-profile')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('browse-market')));
    await tester.tap(find.byKey(const Key('browse-market')));
    await tester.pumpAndSettle();
    expect(find.byType(MarketPage).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Location and read notifications carry across separate pages', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.tap(find.text('Phnom Penh, BKK1'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('location-address-input')),
      'Siem Reap, Sala Kamreuk',
    );
    await tester.ensureVisible(find.text('Save location'));
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-tab-explore')));
    await tester.pumpAndSettle();
    expect(find.text('Siem Reap, Sala Kamreuk'), findsOneWidget);
    final badge = tester.widget<Badge>(
      find.descendant(
        of: find.byType(MarketHeader),
        matching: find.byType(Badge),
      ),
    );
    expect(badge.isLabelVisible, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Each tab preserves its own search and sort choices', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.enterText(find.byKey(const Key('market-search')), 'Kampot');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name'));
    await tester.tap(find.byKey(const Key('market-apply-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-tab-explore')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('market-search')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.text("Today's harvest deals"), findsOneWidget);
    await tester.enterText(find.byKey(const Key('market-search')), 'rice');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('explore-results-rice')), findsOneWidget);
    await tester.tap(find.byKey(const Key('market-tab-categories')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('market-search')))
          .controller!
          .text,
      'Kampot',
    );
    expect(find.byKey(const Key('explore-all-spices')), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('market-tab-explore')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('market-search')))
          .controller!
          .text,
      'rice',
    );
    expect(find.byKey(const Key('explore-results-rice')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
