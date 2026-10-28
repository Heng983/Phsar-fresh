import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_promotions.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/promotion_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_harvest_deal.dart';

import '../../support/market_test_fixtures.dart';
import '../../support/pump_helpers.dart';

void main() {
  testWidgets(
    'Swipe and dots select promotions and claim the correct product',
    (tester) async {
      await pumpMarket(tester);
      final slider = find.byKey(const Key('market-promotions-carousel'));
      await tester.ensureVisible(slider);
      await tester.pumpAndSettle();
      await tester.drag(slider, const Offset(-300, 0));
      await tester.pumpAndSettle();
      final greens = find.byKey(const Key('claim-deal-greens')).hitTestable();
      expect(greens, findsOneWidget);
      await tester.tap(greens);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MarketHarvestDeal)),
      );
      expect(container.read(marketCartCountProvider), 4);
      expect(
        container
            .read(marketCartProvider)
            .firstWhere((item) => item.product.id == 'greens')
            .quantity,
        2,
      );
      expect(tester.widget<FilledButton>(greens).onPressed, isNull);
      await tester.tap(find.byKey(const Key('promotion-dot-2')));
      await tester.pumpAndSettle();
      final fruits = find.byKey(const Key('claim-deal-mangoes')).hitTestable();
      expect(fruits, findsOneWidget);
      await tester.tap(fruits);
      await tester.pumpAndSettle();
      expect(container.read(marketCartCountProvider), 5);
      expect(
        container
            .read(marketCartProvider)
            .firstWhere((item) => item.product.id == 'mangoes')
            .quantity,
        2,
      );
      await tester.tap(find.byKey(const Key('market-tab-explore')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('market-promotions-carousel')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('promotion-dot-1')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('claim-deal-greens')).hitTestable(),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Promotions rotate automatically and stop when removed', (
    tester,
  ) async {
    await pumpMarket(tester, disableAnimations: false);
    expect(
      tester
          .widget<CarouselSlider>(find.byType(CarouselSlider))
          .options
          .autoPlay,
      isTrue,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byKey(const Key('claim-deal-greens')).hitTestable(),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion keeps automatic promotion rotation off', (
    tester,
  ) async {
    await pumpMarket(tester);
    expect(
      tester
          .widget<CarouselSlider>(find.byType(CarouselSlider))
          .options
          .autoPlay,
      isFalse,
    );
    await tester.pumpWidget(const SizedBox());
  });

  test('Promotion claims are unique and expired offers do not add to cart', () {
    final container = ProviderContainer(overrides: [seededCartOverride]);
    addTearDown(container.dispose);
    final claims = container.read(claimedPromotionsProvider.notifier);
    expect(claims.claim(marketPromotions.first), isTrue);
    expect(claims.claim(marketPromotions.first), isFalse);
    expect(container.read(marketCartCountProvider), 4);
    final expired = ProviderContainer(
      overrides: [
        seededCartOverride,
        harvestDealDeadlineProvider.overrideWithValue(
          DateTime.now().subtract(const Duration(seconds: 1)),
        ),
      ],
    );
    addTearDown(expired.dispose);
    expect(
      expired
          .read(claimedPromotionsProvider.notifier)
          .claim(marketPromotions.first),
      isFalse,
    );
    expect(expired.read(marketCartCountProvider), 3);
  });

  test('An expired server deal cannot be claimed', () {
    final container = ProviderContainer(overrides: [seededCartOverride]);
    addTearDown(container.dispose);
    final expired = MarketPromotion(
      product: greensProduct,
      originalPriceInCents: 225,
      endsAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    expect(
      container.read(claimedPromotionsProvider.notifier).claim(expired),
      isFalse,
    );
    expect(container.read(marketCartCountProvider), 3);
  });

  testWidgets('An expired server deal is removed from the carousel', (
    tester,
  ) async {
    final expired = MarketPromotion(
      product: greensProduct,
      originalPriceInCents: 225,
      endsAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsProvider.overrideWith((ref) async => [expired]),
        ],
        child: testApp(
          home: const Scaffold(
            body: SingleChildScrollView(child: MarketHarvestDeal()),
          ),
          disableAnimations: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Same rule as the server: an ended deal is not shown, so it can't be
    // claimed. With no other slides the carousel hides itself.
    expect(find.byKey(const Key('claim-deal-greens')), findsNothing);
    expect(find.byKey(const Key('market-promotions-carousel')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  Future<void> pumpDeals(
    WidgetTester tester, {
    VoidCallback? onOpenChat,
    List<MarketPromotion>? promotions,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (promotions != null)
            promotionsProvider.overrideWith((ref) async => promotions),
        ],
        child: testApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarketHarvestDeal(onOpenChat: onOpenChat),
            ),
          ),
          disableAnimations: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Ming Sros slide follows the deals and opens chat', (
    tester,
  ) async {
    var opened = 0;
    await pumpDeals(tester, onOpenChat: () => opened++);
    await tester.tap(find.byKey(const Key('promotion-dot-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ming-sros-open')).hitTestable());
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Without deals only the Ming Sros slide shows', (tester) async {
    await pumpDeals(tester, onOpenChat: () {}, promotions: const []);
    expect(find.byKey(const Key('promotion-ming-sros')), findsOneWidget);
    expect(find.byKey(const Key('promotion-dot-0')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Categories carousel has no Ming Sros slide', (tester) async {
    await pumpMarket(tester);
    expect(find.byKey(const Key('market-promotions-carousel')), findsOneWidget);
    expect(find.byKey(const Key('promotion-ming-sros')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  for (final language in ['en', 'km']) {
    for (final (width, scale) in [(320.0, 1.4), (375.0, 1.0), (375.0, 1.3)]) {
      testWidgets('Ming Sros slide fits $language at $width x$scale', (
        tester,
      ) async {
        await pumpMarket(
          tester,
          explore: true,
          language: language,
          width: width,
          scale: scale,
        );
        await tester.ensureVisible(
          find.byKey(const Key('market-promotions-carousel')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('promotion-dot-3')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('ming-sros-open')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
