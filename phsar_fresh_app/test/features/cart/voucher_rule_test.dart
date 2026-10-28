import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/voucher_rule.dart';

void main() {
  test('fixed codes take their amount, never more than the subtotal', () {
    const rule = VoucherRule(code: 'FIVE', isPercent: false, value: 500);
    expect(rule.discountFor(2000), 500);
    expect(rule.discountFor(300), 300);
    expect(rule.discountFor(0), 0);
  });

  test('percentage codes respect the cap', () {
    const rule = VoucherRule(
      code: 'TEN',
      isPercent: true,
      value: 10,
      maxDiscountInCents: 300,
    );
    expect(rule.discountFor(1999), 199);
    expect(rule.discountFor(10000), 300);
  });

  test('nothing comes off below the minimum order', () {
    const rule = VoucherRule(
      code: 'BIG',
      isPercent: false,
      value: 200,
      minSubtotalInCents: 2500,
    );
    expect(rule.discountFor(2499), 0);
    expect(rule.discountFor(2500), 200);
  });

  test('reads the server rule', () {
    final rule = VoucherRule.fromJson({
      'code': 'NEWYEAR15',
      'type': 'PERCENT',
      'value': 15,
      'maxDiscountCents': 200,
      'minSubtotalCents': 2500,
      'discountCents': 200,
    });
    expect(rule.isPercent, isTrue);
    expect(rule.discountFor(4000), 200);
  });
}
