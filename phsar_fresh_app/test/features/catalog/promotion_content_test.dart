import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/promotion_content.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

void main() {
  test('Server promotion titles follow the locale', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final km = lookupAppLocalizations(const Locale('km'));
    const both = MarketPromotion(
      product: riceProduct,
      originalPriceInCents: 500,
      title: 'Rice week',
      titleKm: 'សប្តាហ៍អង្ករ',
    );
    const englishOnly = MarketPromotion(
      product: riceProduct,
      originalPriceInCents: 500,
      title: 'Rice week',
    );
    expect(both.headline(en), 'Rice week');
    expect(both.headline(km), 'សប្តាហ៍អង្ករ');
    expect(englishOnly.headline(km), 'Rice week');
  });
}
