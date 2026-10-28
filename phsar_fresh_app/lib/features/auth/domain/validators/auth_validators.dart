class AuthValidators {
  AuthValidators._();

  /// Accepts Cambodian local numbers, with or without the leading zero.
  static bool isValidPhoneNumber(String value) {
    final number = value.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^0?[1-9][0-9]{7,8}$').hasMatch(number);
  }

  static String normalizePhoneNumber(String value) {
    final number = value.replaceAll(RegExp(r'[\s-]'), '');
    return '+855${number.startsWith('0') ? number.substring(1) : number}';
  }

  static bool isValidOtp(String value) => RegExp(r'^[0-9]{6}$').hasMatch(value);
}
