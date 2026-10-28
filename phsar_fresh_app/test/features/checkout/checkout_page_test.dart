import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_address_sheet.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/pump_helpers.dart';

void main() {
  test('Delivery slots respect opening hours and lead time', () {
    final morning = DateTime(2026, 10, 16, 9);
    expect(DeliverySchedule.expressOpen(morning), isTrue);
    expect(DeliverySchedule.slotsOn(morning, morning), [
      for (final hour in [10, 12, 14, 16, 18]) DateTime(2026, 10, 16, hour),
    ]);
    expect(
      DeliverySchedule.resolve(null, morning),
      const DeliverySlot.express(),
    );

    final early = DateTime(2026, 10, 16, 7);
    expect(DeliverySchedule.expressOpen(early), isFalse);
    expect(
      DeliverySchedule.slotsOn(early, early).first,
      DateTime(2026, 10, 16, 8),
    );

    final lateEvening = DateTime(2026, 10, 16, 19, 45);
    expect(DeliverySchedule.expressOpen(lateEvening), isFalse);
    expect(DeliverySchedule.days(lateEvening), [
      DateTime(2026, 10, 17),
      DateTime(2026, 10, 18),
      DateTime(2026, 10, 19),
    ]);
    expect(
      DeliverySchedule.resolve(null, lateEvening),
      DeliverySlot(DateTime(2026, 10, 17, 8)),
    );

    final expired = DeliverySlot(DateTime(2026, 10, 16, 10));
    expect(
      DeliverySchedule.resolve(expired, DateTime(2026, 10, 16, 9, 30)),
      DeliverySlot(DateTime(2026, 10, 16, 12)),
    );

    final newYearsEve = DateTime(2026, 12, 31, 23, 50);
    expect(DeliverySchedule.days(newYearsEve).first, DateTime(2027));
    expect(
      DeliverySlot(DateTime(2027, 1, 1, 8)).noteLabel,
      '2027-01-01 08:00–10:00',
    );
  });

  testWidgets('Cart opens checkout and preserves choices when returning', (
    tester,
  ) async {
    final container = await pumpCart(tester);
    container.read(cartVoucherProvider.notifier).apply('KHMERFRESH');
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('cart-checkout')));
    await tester.tap(find.byKey(const Key('cart-checkout')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('checkout-total'))).data,
      r'$7.00',
    );
    await reveal(tester, find.byKey(const Key('checkout-delivery-schedule')));
    await tester.tap(find.byKey(const Key('checkout-delivery-schedule')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('checkout-delivery-day-1')));
    await tester.tap(find.byKey(const Key('checkout-delivery-day-1')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('checkout-delivery-slot-16')));
    await tester.tap(find.byKey(const Key('checkout-delivery-slot-16')));
    await reveal(tester, find.byKey(const Key('checkout-instructions')));
    await tester.enterText(
      find.byKey(const Key('checkout-instructions')),
      'Leave with security',
    );
    FocusScope.of(tester.element(find.byType(CheckoutPage))).unfocus();
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('checkout-payment-cash')));
    await tester.tap(find.byKey(const Key('checkout-payment-cash')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pay on delivery ·'), findsOneWidget);
    expect(container.read(checkoutProvider).payment, CheckoutPayment.cash);
    final secondDay = DeliverySchedule.days(DateTime.now())[1];
    expect(
      container.read(checkoutProvider).delivery,
      DeliverySlot(
        DateTime(secondDay.year, secondDay.month, secondDay.day, 16),
      ),
    );
    await tester.tap(find.byKey(const Key('checkout-place-order')));
    await tester.pumpAndSettle();
    expect(find.text('Checkout is coming soon'), findsOneWidget);
    expect(container.read(marketCartCountProvider), 3);
    expect(container.read(cartSummaryProvider).totalInCents, 700);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-back')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('cart-checkout')));
    await tester.tap(find.byKey(const Key('cart-checkout')));
    await tester.pumpAndSettle();
    expect(
      container.read(checkoutProvider).instructions,
      'Leave with security',
    );
    expect(container.read(checkoutProvider).payment, CheckoutPayment.cash);
    await reveal(tester, find.byKey(const Key('checkout-summary-toggle')));
    await tester.tap(find.byKey(const Key('checkout-summary-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkout-total')), findsNothing);
    await tester.tap(find.byKey(const Key('checkout-summary-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkout-total')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Delivery form validates and updates the shared address', (
    tester,
  ) async {
    final container = await pumpCheckout(tester);
    await tester.tap(find.byKey(const Key('checkout-change-address')));
    await tester.pumpAndSettle();
    // The signed-in account's phone is filled in for the recipient.
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('checkout-phone-input')))
          .controller!
          .text,
      '012345678',
    );
    await tester.enterText(find.byKey(const Key('checkout-phone-input')), '');
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('checkout-save-address')));
    await tester.tap(find.byKey(const Key('checkout-save-address')));
    await tester.pumpAndSettle();
    expect(find.text('Enter the recipient’s name.'), findsOneWidget);
    expect(find.text('Enter a valid Cambodian mobile number.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('checkout-recipient-input')),
      'Sophea',
    );
    await tester.enterText(
      find.byKey(const Key('checkout-phone-input')),
      '+855 12 345 678',
    );
    await tester.enterText(
      find.byKey(const Key('checkout-address-input')),
      'Street 310, Phnom Penh',
    );
    for (final field in {
      'house-number': '12B',
      'street': 'Street 310',
      'note': 'Green gate, second floor',
    }.entries) {
      final finder = find.byKey(Key('checkout-${field.key}'));
      await reveal(tester, finder);
      await tester.enterText(finder, field.value);
    }
    await reveal(tester, find.byKey(const Key('checkout-label-home')));
    await tester.tap(find.byKey(const Key('checkout-label-home')));
    await reveal(tester, find.byKey(const Key('checkout-save-address')));
    await tester.tap(find.byKey(const Key('checkout-save-address')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutAddressSheet), findsNothing);
    expect(container.read(marketLocationProvider), 'Street 310, Phnom Penh');
    final location = container.read(deliveryLocationProvider);
    expect(location.houseNumber, '12B');
    expect(location.street, 'Street 310');
    expect(location.addressLabel, DeliveryAddressLabel.home);
    expect(
      find.text('12B, Street 310\nStreet 310, Phnom Penh'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('checkout-address-label')), findsOneWidget);
    expect(find.text('Green gate, second floor'), findsOneWidget);
    await tester.tap(find.byKey(const Key('checkout-change-address')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('checkout-note')));
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('checkout-note')))
          .controller!
          .text,
      'Green gate, second floor',
    );
    await tester.enterText(
      find.byKey(const Key('checkout-note')),
      'Unsaved note',
    );
    Navigator.of(tester.element(find.byType(CheckoutAddressSheet))).pop();
    await tester.pumpAndSettle();
    expect(
      container.read(deliveryLocationProvider).note,
      'Green gate, second floor',
    );
    expect(container.read(checkoutProvider).phone, '+85512345678');
    expect(find.text('Sophea · +85512345678'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'km']) {
    for (final currency in AppCurrency.values) {
      for (final width in [320.0, 720.0]) {
        testWidgets('Checkout fits $language ${currency.name} at $width', (
          tester,
        ) async {
          final container = await pumpCheckout(
            tester,
            width: width,
            scale: 1.5,
            language: language,
            currency: currency,
          );
          await container
              .read(deliveryLocationProvider.notifier)
              .select(
                const DeliveryLocation(
                  label: 'Phnom Penh, BKK1',
                  houseNumber: '12B',
                  street: 'Street 310',
                  note: 'Second floor, green gate by the market',
                  addressLabel: DeliveryAddressLabel.other,
                  customLabel: 'Family house by central market',
                ),
              );
          await tester.pumpAndSettle();
          expect(
            find.text('12B, Street 310\nPhnom Penh, BKK1'),
            findsOneWidget,
          );
          await reveal(
            tester,
            find.byKey(const Key('checkout-delivery-schedule')),
          );
          await tester.tap(find.byKey(const Key('checkout-delivery-schedule')));
          await tester.pumpAndSettle();
          await reveal(
            tester,
            find.byKey(const Key('checkout-delivery-day-2')),
          );
          await tester.tap(find.byKey(const Key('checkout-delivery-day-2')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('checkout-delivery-slot-18')),
            findsOneWidget,
          );
          await reveal(
            tester,
            find.byKey(const Key('checkout-payment-abaPay')),
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(CheckoutPage)),
          )!;
          expect(find.text(l10n.checkoutAbaPay), findsOneWidget);
          expect(
            container.read(checkoutProvider).payment,
            CheckoutPayment.abaPay,
          );
          expect(
            find.byKey(const Key('checkout-payment-acleda')),
            findsNothing,
          );
          expect(find.byKey(const Key('checkout-payment-wing')), findsNothing);
          await reveal(tester, find.byKey(const Key('checkout-payment-card')));
          await tester.tap(find.byKey(const Key('checkout-payment-card')));
          await tester.pumpAndSettle();
          expect(
            container.read(checkoutProvider).payment,
            CheckoutPayment.card,
          );
          expect(
            find.text(l10n.checkoutPayCard(currency.format(850, language))),
            findsOneWidget,
          );
          await reveal(tester, find.byKey(const Key('checkout-payment-cash')));
          expect(find.text(l10n.checkoutCash), findsOneWidget);
          await reveal(tester, find.byKey(const Key('checkout-total')));
          expect(
            tester.widget<Text>(find.byKey(const Key('checkout-total'))).data,
            currency.format(850, language),
          );
          expect(
            tester
                .widget<Text>(find.byKey(const Key('checkout-payable-total')))
                .data,
            currency.format(850, language),
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets('Empty baskets cannot place an order', (tester) async {
    final container = await pumpCheckout(tester);
    for (final item in container.read(marketCartProvider)) {
      container
          .read(marketCartProvider.notifier)
          .setQuantity(item.product.id, 0);
    }
    await tester.pumpAndSettle();
    expect(find.text('Your basket is empty'), findsOneWidget);
    expect(find.byKey(const Key('checkout-place-order')), findsNothing);
  });
}
