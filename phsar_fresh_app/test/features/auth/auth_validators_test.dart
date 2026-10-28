import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/domain/validators/auth_validators.dart';

void main() {
  test('Cambodian numbers accept local formats and normalize to +855', () {
    for (final number in [
      '012345678',
      '12345678',
      '012 345 678',
      '012-345-678',
      '0123456789',
    ]) {
      expect(AuthValidators.isValidPhoneNumber(number), isTrue);
    }
    expect(AuthValidators.normalizePhoneNumber('012 345 678'), '+85512345678');
    expect(AuthValidators.normalizePhoneNumber('12345678'), '+85512345678');
    for (final number in [
      '',
      'abc12345678',
      '1234',
      '000000000',
      '+85512345678',
      '12345678901',
    ]) {
      expect(AuthValidators.isValidPhoneNumber(number), isFalse);
    }
  });

  test('Verification codes contain exactly six digits', () {
    expect(AuthValidators.isValidOtp('123456'), isTrue);
    for (final code in ['', '12345', '1234567', '12345a']) {
      expect(AuthValidators.isValidOtp(code), isFalse);
    }
  });
}
