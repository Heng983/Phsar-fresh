import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

extension PromotionContent on MarketPromotion {
  /// The server's title in the app language, else the preview deal titles.
  String headline(AppLocalizations l10n) {
    final server = l10n.localeName == 'km' ? titleKm ?? title : title;
    if (server != null) return server;
    return switch (product.id) {
      'citrus' => l10n.marketDealTitle,
      'greens' => l10n.marketGreensPromotion,
      'mangoes' => l10n.marketFruitsPromotion,
      _ => product.title(l10n),
    };
  }
}
