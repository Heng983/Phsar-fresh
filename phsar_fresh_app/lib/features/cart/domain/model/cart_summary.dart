import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/voucher_rule.dart';

/// Local basket pricing in integer cents. Replace the delivery fee with a
/// server quote when the catalog is connected to checkout.
class CartSummary {
  static const voucherCode = 'KHMERFRESH';
  static const voucherValueInCents = 150;
  static const deliveryFeeInCents = 100;

  final int itemCount;
  final int subtotalInCents;
  final int discountInCents;
  final int deliveryInCents;

  const CartSummary._({
    required this.itemCount,
    required this.subtotalInCents,
    required this.discountInCents,
    required this.deliveryInCents,
  });

  /// [voucher] is the applied code's rule. `voucherApplied: true` without a
  /// rule means the built-in KHMERFRESH offer.
  factory CartSummary.calculate(
    List<MarketCartItem> items, {
    bool voucherApplied = false,
    VoucherRule? voucher,
  }) {
    final subtotal = items.fold<int>(
      0,
      (sum, item) => sum + item.priceInCents * item.quantity,
    );
    final rule = voucher ?? (voucherApplied ? VoucherRule.offline : null);
    return CartSummary._(
      itemCount: items.fold<int>(0, (sum, item) => sum + item.quantity),
      subtotalInCents: subtotal,
      discountInCents: rule?.discountFor(subtotal) ?? 0,
      deliveryInCents: items.isEmpty ? 0 : deliveryFeeInCents,
    );
  }

  int get totalInCents => subtotalInCents - discountInCents + deliveryInCents;
}
