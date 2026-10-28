import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/product_favorites_provider.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_page.dart';

import '../../support/auth_test_repository.dart';
import '../../support/pump_helpers.dart';

void main() {
  late TestAuthRepository repository;
  setUp(() => repository = TestAuthRepository());
  tearDown(() => repository.close());

  testWidgets(
    'Display name editor uses the injected repository and preserves the phone',
    (tester) async {
      await pumpAccount(tester, repository);
      expect(find.text('+855 12 345 678'), findsOneWidget);
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await tester.enterText(
        find.byKey(const Key('profile-name-input')),
        '  Sophea Pich  ',
      );
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(repository.currentSession!.user.displayName, 'Sophea Pich');
      expect(find.text('Sophea Pich'), findsOneWidget);
      expect(find.text('+855 12 345 678'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Invalid or failed edits keep the form available for correction',
    (tester) async {
      repository.failUpdates = true;
      await pumpAccount(tester, repository);
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await tester.enterText(
        find.byKey(const Key('profile-name-input')),
        '   ',
      );
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(find.text('Enter your name.'), findsOneWidget);
      expect(repository.currentSession!.user.displayName, isEmpty);
      await tester.enterText(
        find.byKey(const Key('profile-name-input')),
        'Sophea',
      );
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(find.byKey(const Key('profile-edit-error')), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('profile-name-input')))
            .controller
            ?.text,
        'Sophea',
      );
      expect(find.text('Fresh food lover'), findsOneWidget);
      repository.failUpdates = false;
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(find.text('Sophea'), findsOneWidget);
      expect(find.byKey(const Key('profile-edit-error')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Favorites open product details, can be removed, and the empty state leads to Explore',
    (tester) async {
      await pumpMarket(tester, signedIn: true);
      await tester.tap(find.byKey(const Key('market-profile-avatar')));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfilePage)),
      );
      container.read(productFavoritesProvider.notifier).toggle(greensProduct);
      await tester.pumpAndSettle();
      await revealAndTap(tester, find.byKey(const Key('profile-favorites')));
      await tester.tap(find.byKey(const Key('profile-favorite-greens')));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-remove-greens')));
      await tester.pumpAndSettle();
      expect(container.read(productFavoritesProvider), isEmpty);
      expect(find.text('Your next favorite is waiting'), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile-explore-favorites')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('market-search')), findsOneWidget);
      expect(find.byType(ProfilePage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Delivery and payment choices made from Profile carry through to checkout',
    (tester) async {
      final container = await pumpAccount(tester, repository);
      expect(find.byKey(const Key('profile-orders')), findsOneWidget);
      expect(find.byKey(const Key('profile-favorite-count')), findsOneWidget);
      expect(find.byKey(const Key('profile-favorites')), findsOneWidget);
      await revealAndTap(tester, find.byKey(const Key('profile-address')));
      await tester.enterText(
        find.byKey(const Key('checkout-recipient-input')),
        'Sophea',
      );
      await tester.enterText(
        find.byKey(const Key('checkout-phone-input')),
        '012345678',
      );
      await tester.enterText(
        find.byKey(const Key('checkout-address-input')),
        'Home, Street 302, BKK1',
      );
      await revealAndTap(
        tester,
        find.byKey(const Key('checkout-save-address')),
      );
      expect(container.read(checkoutProvider).recipient, 'Sophea');
      expect(container.read(marketLocationProvider), 'Home, Street 302, BKK1');
      await revealAndTap(tester, find.byKey(const Key('profile-payment')));
      await revealAndTap(
        tester,
        find.byKey(const Key('checkout-payment-card')),
      );
      expect(container.read(checkoutProvider).payment, CheckoutPayment.card);
      await revealAndTap(tester, find.text('Close'));
      expect(
        find.descendant(
          of: find.byKey(const Key('profile-payment')),
          matching: find.text('Credit/Debit Card'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Guest profile hides personal stats and shopping settings', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.tap(find.byKey(const Key('market-guest-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Guest'), findsOneWidget);
    expect(find.byKey(const Key('profile-guest-avatar-icon')), findsOneWidget);
    expect(find.byKey(const Key('profile-edit')), findsNothing);
    for (final key in [
      'profile-orders',
      'profile-favorite-count',
      'profile-favorites',
      'profile-address',
      'profile-payment',
    ]) {
      expect(find.byKey(Key(key)), findsNothing, reason: key);
    }
    expect(find.text('SHOPPING & COMMUNITY'), findsNothing);
    expect(find.byKey(const Key('profile-language-en')), findsOneWidget);
    expect(find.byKey(const Key('profile-help')), findsOneWidget);
    expect(find.byKey(const Key('profile-sign-in')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'km']) {
    testWidgets('Profile sections fit $language at 320px with larger text', (
      tester,
    ) async {
      await pumpMarket(
        tester,
        width: 320,
        language: language,
        scale: 1.5,
        signedIn: true,
      );
      await tester.tap(find.byKey(const Key('market-profile-avatar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final key in [
        'profile-favorites',
        'profile-address',
        'profile-payment',
        'profile-language-en',
        'currency-khr',
        'profile-help',
        'profile-privacy',
        'profile-sign-out',
      ]) {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$language at $key');
      }
    });
  }
}
