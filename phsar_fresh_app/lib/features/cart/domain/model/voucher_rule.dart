/// A discount code the cart can use, as checked by `POST /discount-codes/check`
/// (or the built-in KHMERFRESH offer when the app runs without a server).
class VoucherRule {
  const VoucherRule({
    required this.code,
    required this.isPercent,
    required this.value,
    this.maxDiscountInCents,
    this.minSubtotalInCents = 0,
  });

  /// The offer the app has always shown; used in local preview mode.
  static const offline = VoucherRule(
    code: 'KHMERFRESH',
    isPercent: false,
    value: 150,
  );

  final String code;

  /// True for "10% off", false for "$1.50 off".
  final bool isPercent;

  /// Percent (1–100) when [isPercent], otherwise US cents.
  final int value;

  /// Upper limit for percentage codes.
  final int? maxDiscountInCents;

  /// Cart subtotal needed before the code takes anything off.
  final int minSubtotalInCents;

  factory VoucherRule.fromJson(Map<String, dynamic> json) => VoucherRule(
    code: json['code'] as String,
    isPercent: json['type'] == 'PERCENT',
    value: (json['value'] as num).toInt(),
    maxDiscountInCents: (json['maxDiscountCents'] as num?)?.toInt(),
    minSubtotalInCents: (json['minSubtotalCents'] as num?)?.toInt() ?? 0,
  );

  /// Cents off [subtotalInCents]: never more than the subtotal, and nothing
  /// while the cart is below the minimum order.
  int discountFor(int subtotalInCents) {
    if (subtotalInCents <= 0 || subtotalInCents < minSubtotalInCents) return 0;
    var off = isPercent ? subtotalInCents * value ~/ 100 : value;
    final cap = maxDiscountInCents;
    if (isPercent && cap != null && off > cap) off = cap;
    return off.clamp(0, subtotalInCents);
  }
}
