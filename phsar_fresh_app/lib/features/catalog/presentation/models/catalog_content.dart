import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

/// Text for the current language (Khmer when available in Khmer mode).
extension ProductCategoryLabel on ProductCategory {
  String label(AppLocalizations l10n) => localizedName(l10n.localeName);

  String? descriptionText(AppLocalizations l10n) =>
      localizedDescription(l10n.localeName);
}

extension MarketProductLabel on MarketProduct {
  String title(AppLocalizations l10n) => localizedName(l10n.localeName);

  String description(AppLocalizations l10n) =>
      localizedSummary(l10n.localeName);

  String unitLabel(AppLocalizations l10n) => localizedUnit(l10n.localeName);
}
