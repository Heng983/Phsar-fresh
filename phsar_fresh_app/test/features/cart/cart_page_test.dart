import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';

import '../../support/pump_helpers.dart';

void main() {
  testWidgets('Quantity and remove controls keep the basket in sync', (
    tester,
  ) async {
    final container = await pumpCart(tester);
    final greens = find.byKey(const ValueKey('cart-greens-default'));
    await tester.tap(
      find.descendant(
        of: greens,
        matching: find.byTooltip('Increase quantity'),
      ),
    );
    await tester.pumpAndSettle();
    expect(container.read(marketCartCountProvider), 4);
    expect(find.text('4 items'), findsOneWidget);
    expect(container.read(cartSummaryProvider).totalInCents, 1030);
    await tester.tap(find.byTooltip('Remove Battambang Greens from basket'));
    await tester.pumpAndSettle();
    expect(container.read(marketCartCountProvider), 2);
    expect(find.byType(CartItemCard), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Swiping an item left removes it and Undo puts it back', (
    tester,
  ) async {
    final container = await pumpCart(tester);
    final before = container.read(marketCartProvider);
    final greens = find.byKey(const ValueKey('cart-greens-default'));
    await tester.drag(
      find.descendant(of: greens, matching: find.byType(CartItemCard)),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(greens, findsNothing);
    expect(find.text('Removed from basket'), findsOneWidget);
    expect(container.read(marketCartCountProvider), 2);

    await tester.tap(find.byKey(const Key('snackbar-action')));
    await tester.pumpAndSettle();
    expect(greens, findsOneWidget);
    expect(
      container.read(marketCartProvider).map((item) => item.product.id),
      before.map((item) => item.product.id),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Voucher errors, apply, removal and total update correctly', (
    tester,
  ) async {
    final container = await pumpCart(tester);
    final input = find.byKey(const Key('cart-voucher-input'));
    final apply = find.byKey(const Key('cart-apply-voucher'));
    await reveal(tester, input);
    await tester.enterText(input, 'invalid');
    await reveal(tester, apply);
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(
      find.text('This code is not valid. Check it and try again.'),
      findsOneWidget,
    );
    await reveal(tester, input);
    await tester.enterText(input, 'khmerfresh');
    await reveal(tester, apply);
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cart-voucher-success')), findsOneWidget);
    expect(container.read(cartSummaryProvider).totalInCents, 700);
    await reveal(tester, find.byKey(const Key('cart-total-payable')));
    expect(
      tester.widget<Text>(find.byKey(const Key('cart-total-payable'))).data,
      r'$7.00',
    );
    await reveal(tester, find.byTooltip('Remove voucher'));
    await tester.tap(find.byTooltip('Remove voucher'));
    await tester.pumpAndSettle();
    expect(container.read(cartVoucherProvider), isNull);
    expect(container.read(cartSummaryProvider).totalInCents, 850);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Removing a pack leaves the other pack and empty state can browse',
    (tester) async {
      var continued = false;
      final container = await pumpCart(
        tester,
        onContinueShopping: () => continued = true,
      );
      container
          .read(marketCartProvider.notifier)
          .add(
            greensProduct,
            pack: const ProductPackOption(
              size: ProductPackSize.halfKg,
              priceInCents: 90,
            ),
          );
      await tester.pumpAndSettle();
      final halfPack = find.byKey(const ValueKey('cart-greens-halfKg'));
      await reveal(tester, halfPack);
      await tester.tap(
        find.descendant(
          of: halfPack,
          matching: find.byTooltip('Remove Battambang Greens from basket'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        container
            .read(marketCartProvider)
            .where((item) => item.product.id == 'greens')
            .single
            .pack,
        isNull,
      );
      for (final item in container.read(marketCartProvider)) {
        container
            .read(marketCartProvider.notifier)
            .setQuantity(item.product.id, 0, packSize: item.pack?.size);
      }
      await tester.pumpAndSettle();
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.byKey(const Key('cart-checkout')), findsNothing);
      await tester.tap(find.text('Continue shopping'));
      expect(continued, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Checkout reviews the current quote and delivery location', (
    tester,
  ) async {
    final container = await pumpCart(tester);
    container.read(marketLocationProvider.notifier).update('Siem Reap');
    container.read(cartVoucherProvider.notifier).apply('KHMERFRESH');
    await tester.pumpAndSettle();
    final checkout = find.byKey(const Key('cart-checkout'));
    await reveal(tester, checkout);
    await tester.tap(checkout);
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(find.text('Siem Reap').hitTestable(), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(container.read(marketCartCountProvider), 3);
    await tester.tap(find.byKey(const Key('checkout-back')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'km']) {
    for (final width in [320.0, 720.0]) {
      testWidgets('Cart fits $language at width $width with large text', (
        tester,
      ) async {
        await pumpCart(tester, width: width, scale: 1.5, language: language);
        expect(tester.takeException(), isNull);
        final input = find.byKey(const Key('cart-voucher-input'));
        await reveal(tester, input);
        expect(tester.takeException(), isNull);
        await tester.enterText(input, 'KHMERFRESH');
        final apply = find.byKey(const Key('cart-apply-voucher'));
        await reveal(tester, apply);
        await tester.tap(apply);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await reveal(tester, find.byKey(const Key('cart-checkout')));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('cart-checkout')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
