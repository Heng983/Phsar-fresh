import 'package:intl/intl.dart';

enum AppCurrency {
  usd,
  khr;

  // Fixed display conversion for the local demo, not a live exchange-rate feed.
  static const rielPerDollar = 4100;

  String format(int cents, String locale) => NumberFormat.currency(
    locale: locale,
    name: this == usd ? 'USD' : 'KHR',
    symbol: this == usd ? r'$' : '៛',
    decimalDigits: this == usd ? 2 : 0,
  ).format(this == usd ? cents / 100 : cents * rielPerDollar ~/ 100);

  String convertedPrice(int cents, String locale) {
    if (this == khr) return '≈ ${usd.format(cents, locale)}';
    final amount = NumberFormat.decimalPattern(
      locale,
    ).format(cents * rielPerDollar ~/ 100);
    return '≈ $amount ៛';
  }
}
