import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_summary.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';

import '../../support/market_test_fixtures.dart';

void main() {
  test('Summary prices selected packs, quantities, delivery and discount', () {
    final summary = CartSummary.calculate([
      const MarketCartItem(
        product: greensProduct,
        quantity: 3,
        pack: ProductPackOption(size: ProductPackSize.halfKg, priceInCents: 90),
      ),
      const MarketCartItem(product: fruitsProduct, quantity: 2),
    ], voucherApplied: true);
    expect(summary.itemCount, 5);
    expect(summary.subtotalInCents, 910);
    expect(summary.discountInCents, 150);
    expect(summary.deliveryInCents, 100);
    expect(summary.totalInCents, 860);
  });

  test('Discount cannot exceed merchandise and empty carts have no fees', () {
    final smallBasket = CartSummary.calculate([
      const MarketCartItem(
        product: greensProduct,
        pack: ProductPackOption(
          size: ProductPackSize.quarterKg,
          priceInCents: 45,
        ),
      ),
    ], voucherApplied: true);
    expect(smallBasket.discountInCents, 45);
    expect(smallBasket.totalInCents, 100);
    final empty = CartSummary.calculate([], voucherApplied: true);
    expect(empty.subtotalInCents, 0);
    expect(empty.discountInCents, 0);
    expect(empty.deliveryInCents, 0);
    expect(empty.totalInCents, 0);
  });

  test('Vouchers normalize input, reject unknown codes and never stack', () {
    final container = ProviderContainer(overrides: [seededCartOverride]);
    addTearDown(container.dispose);
    final voucher = container.read(cartVoucherProvider.notifier);
    expect(voucher.apply('unknown'), isFalse);
    expect(container.read(cartVoucherProvider), isNull);
    expect(container.read(cartSummaryProvider).totalInCents, 850);
    expect(voucher.apply('  khmerfresh  '), isTrue);
    expect(voucher.apply('KHMERFRESH'), isTrue);
    expect(container.read(cartSummaryProvider).totalInCents, 700);
    expect(voucher.apply('invalid'), isFalse);
    expect(container.read(cartVoucherProvider), 'KHMERFRESH');
    container.read(marketCartProvider.notifier).setQuantity('greens', 2);
    expect(container.read(cartSummaryProvider).totalInCents, 880);
    voucher.remove();
    expect(container.read(cartSummaryProvider).totalInCents, 1030);
  });

  test('Emptying the basket clears its voucher before shopping again', () {
    final container = ProviderContainer(overrides: [seededCartOverride]);
    addTearDown(container.dispose);
    container.read(cartVoucherProvider.notifier).apply('KHMERFRESH');
    final cart = container.read(marketCartProvider.notifier);
    for (final item in container.read(marketCartProvider)) {
      cart.setQuantity(item.product.id, 0, packSize: item.pack?.size);
    }
    expect(container.read(cartVoucherProvider), isNull);
    expect(container.read(cartSummaryProvider).totalInCents, 0);
    expect(
      container.read(cartVoucherProvider.notifier).apply('KHMERFRESH'),
      isFalse,
    );
    cart.add(greensProduct);
    expect(container.read(cartSummaryProvider).totalInCents, 280);
  });
}
