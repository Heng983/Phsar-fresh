import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';

/// A deal: [product] carries the deal price, [originalPriceInCents] the usual
/// one. Server deals also carry [id], titles and an end time.
class MarketPromotion {
  final MarketProduct product;
  final int originalPriceInCents;
  final String? id;
  final String? title;
  final String? titleKm;

  /// When the deal ends; null uses the app's harvest-deal countdown.
  final DateTime? endsAt;

  const MarketPromotion({
    required this.product,
    required this.originalPriceInCents,
    this.id,
    this.title,
    this.titleKm,
    this.endsAt,
  });

  /// Reads one item of `GET /promotions`.
  factory MarketPromotion.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    final product = json['product'];
    final original = json['originalPriceCents'];
    final endsAt = json['endsAt'];
    String? optional(String key) {
      final value = json[key];
      if (value != null && value is! String) {
        throw FormatException('Invalid promotion $key');
      }
      return value as String?;
    }

    if (product is! Map<String, dynamic> ||
        original is! int ||
        original < 0 ||
        (endsAt != null && endsAt is! String)) {
      throw const FormatException('Invalid promotion');
    }
    return MarketPromotion(
      product: MarketProduct.fromJson(product, resolveUrl: resolveUrl),
      originalPriceInCents: original,
      id: optional('id'),
      title: optional('title'),
      titleKm: optional('titleKm'),
      endsAt: endsAt == null ? null : DateTime.parse(endsAt as String),
    );
  }
}
