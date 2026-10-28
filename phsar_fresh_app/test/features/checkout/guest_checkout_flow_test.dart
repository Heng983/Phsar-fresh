import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:phsar_fresh_app/main.dart' as entry;
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/pump_helpers.dart';

void main() {
  testWidgets(
    'Application starts without backend credentials or SDK initialization',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await entry.main();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
      await tester.ensureVisible(find.text('Get Started'));
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(find.byType(MarketPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Guests can preview checkout and return with the basket preserved',
    (tester) async {
      await pumpMarket(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MarketPage)),
      );
      final originalBasket = container.read(marketCartProvider);
      await tester.tap(find.byKey(const Key('market-tab-cart')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('cart-checkout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cart-checkout')));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byKey(const Key('checkout-total')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('checkout-place-order')));
      await tester.tap(find.byKey(const Key('checkout-place-order')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(container.read(marketCartProvider), originalBasket);
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('checkout-back')));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutPage), findsNothing);
      expect(container.read(marketCartProvider), originalBasket);
      expect(tester.takeException(), isNull);
    },
  );
}
