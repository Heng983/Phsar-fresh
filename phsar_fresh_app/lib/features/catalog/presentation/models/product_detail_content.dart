import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_detail.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

extension ProductPackLabel on ProductPackOption {
  String label(AppLocalizations l10n) => switch (size) {
    ProductPackSize.quarterKg => l10n.product250g,
    ProductPackSize.halfKg => l10n.product500g,
    ProductPackSize.kilogram => l10n.product1kg,
    ProductPackSize.standardPack => l10n.productSinglePack,
    ProductPackSize.doublePack => l10n.productDoublePack,
    ProductPackSize.sixEggs => l10n.productSixEggs,
    ProductPackSize.dozenEggs => l10n.productDozenEggs,
  };
}

String productPrice(int cents, AppLocalizations l10n, AppCurrency currency) =>
    currency.format(cents, l10n.localeName);

String productConvertedPrice(
  int cents,
  AppLocalizations l10n,
  AppCurrency currency,
) => currency.convertedPrice(cents, l10n.localeName);
