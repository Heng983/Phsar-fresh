import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_checkout_button.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_page.dart';

import '../../support/pump_helpers.dart';

Future<void> showCurrency(WidgetTester tester, String code) async {
  await tester.scrollUntilVisible(
    find.byKey(Key('currency-$code')),
    180,
    scrollable: find.descendant(
      of: find.byType(ProfilePage),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('Currency formatting keeps cents accurate and riel whole', () {
    expect(AppCurrency.usd.format(240, 'en'), r'$2.40');
    expect(AppCurrency.usd.format(1, 'en'), r'$0.01');
    expect(AppCurrency.khr.format(240, 'en'), '៛9,840');
    expect(AppCurrency.khr.format(1, 'en'), '៛41');
    expect(AppCurrency.khr.format(0, 'en'), '៛0');
    expect(AppCurrency.khr.format(123456, 'en'), '៛5,061,696');
    expect(AppCurrency.usd.convertedPrice(240, 'en'), '≈ 9,840 ៛');
    expect(AppCurrency.khr.convertedPrice(240, 'en'), r'≈ $2.40');
  });

  for (final language in ['en', 'km']) {
    testWidgets('Riel prices fit $language with larger text', (tester) async {
      await pumpDetail(tester, width: 320, language: language, scale: 1.4);
      final detailContainer = ProviderScope.containerOf(
        tester.element(find.byType(ProductDetailPage)),
      );
      detailContainer.read(currencyProvider.notifier).select(AppCurrency.khr);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('product-pack-halfKg')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());

      final cartContainer = await pumpCart(
        tester,
        width: 320,
        language: language,
        scale: 1.5,
      );
      cartContainer.read(currencyProvider.notifier).select(AppCurrency.khr);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('cart-checkout')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'Currency selection updates products and checkout in $language',
      (tester) async {
        await pumpMarket(
          tester,
          width: 320,
          language: language,
          signedIn: true,
        );
        await tester.tap(find.byKey(const Key('market-profile-avatar')));
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ProfilePage)),
        );
        final originalSummary = container.read(cartSummaryProvider);
        await showCurrency(tester, 'usd');
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(const Key('currency-usd')))
              .selected,
          isTrue,
        );
        await showCurrency(tester, 'khr');
        await tester.tap(find.byKey(const Key('currency-khr')));
        await tester.pumpAndSettle();
        expect(container.read(currencyProvider), AppCurrency.khr);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const Key('profile-back')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('market-tab-explore')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('market-search')),
          'greens',
        );
        await tester.pumpAndSettle();
        final product = find.byKey(const Key('explore-results-greens'));
        await tester.scrollUntilVisible(
          product,
          180,
          scrollable: find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: product,
            matching: find.textContaining(
              AppCurrency.khr.format(180, language),
              findRichText: true,
            ),
          ),
          findsOneWidget,
        );
        await tester.tap(product);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const Key('product-detail-total')))
              .data,
          AppCurrency.khr.format(180, language),
        );
        await tester.ensureVisible(
          find.byKey(const Key('product-pack-halfKg')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('product-pack-halfKg')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const Key('product-detail-total')))
              .data,
          AppCurrency.khr.format(90, language),
        );
        expect(tester.takeException(), isNull);
        Navigator.of(
          tester.element(find.byKey(const Key('product-detail-total'))),
        ).pop();
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('market-tab-cart')));
        await tester.pumpAndSettle();
        final input = find.byKey(const Key('cart-voucher-input'));
        await tester.ensureVisible(input);
        await tester.pumpAndSettle();
        await tester.enterText(input, 'KHMERFRESH');
        await tester.ensureVisible(find.byKey(const Key('cart-apply-voucher')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('cart-apply-voucher')));
        await tester.pumpAndSettle();
        expect(container.read(cartSummaryProvider).totalInCents, 700);
        await tester.ensureVisible(find.byKey(const Key('cart-total-payable')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const Key('cart-total-payable'))).data,
          AppCurrency.khr.format(700, language),
        );
        final checkout = find.byKey(const Key('cart-checkout'));
        await tester.ensureVisible(checkout);
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(CartCheckoutButton),
            matching: find.text(AppCurrency.khr.format(700, language)),
          ),
          findsOneWidget,
        );
        await tester.tap(checkout);
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const Key('checkout-total'))).data,
          AppCurrency.khr.format(700, language),
        );
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.byType(CheckoutPage))).pop();
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('market-tab-categories')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('market-profile-avatar')));
        await tester.pumpAndSettle();
        await showCurrency(tester, 'khr');
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(const Key('currency-khr')))
              .selected,
          isTrue,
        );
        await showCurrency(tester, 'usd');
        await tester.tap(find.byKey(const Key('currency-usd')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('profile-back')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('market-tab-cart')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('cart-total-payable')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const Key('cart-total-payable'))).data,
          AppCurrency.usd.format(700, language),
        );
        expect(
          container.read(cartSummaryProvider).subtotalInCents,
          originalSummary.subtotalInCents,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
