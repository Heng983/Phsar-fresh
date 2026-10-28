import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';

/// A product as returned by `GET /products`.
///
/// [imageUrl] is a full URL from the server, or a bundled `assets/` path for
/// the offline preview catalog. [isOrganic], [isNewArrival] and [isPopular]
/// are preview-only merchandising flags; the server leaves them false.
class MarketProduct {
  final String id;
  final String name;
  final String? nameKm;

  /// Maps to the server's `description`.
  final String? summary;
  final String? summaryKm;
  final String? origin;
  final String unit;
  final String? unitKm;
  final int priceInCents;
  final String? imageUrl;
  final bool inStock;
  final ProductCategory category;
  final bool isOrganic;
  final bool isNewArrival;
  final bool isPopular;

  const MarketProduct({
    required this.id,
    required this.name,
    this.nameKm,
    this.summary,
    this.summaryKm,
    this.origin,
    required this.unit,
    this.unitKm,
    required this.priceInCents,
    this.imageUrl,
    this.inStock = true,
    required this.category,
    this.isOrganic = false,
    this.isNewArrival = false,
    this.isPopular = false,
  });

  String localizedName(String languageCode) =>
      pickLocalized(languageCode, name, nameKm);

  String localizedSummary(String languageCode) =>
      summary == null ? '' : pickLocalized(languageCode, summary!, summaryKm);

  String localizedUnit(String languageCode) =>
      pickLocalized(languageCode, unit, unitKm);

  factory MarketProduct.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    final id = json['id'];
    final name = json['name'];
    final price = json['priceCents'];
    final unit = json['unit'];
    final inStock = json['inStock'] ?? true;
    final category = json['category'];
    final image = json['imageUrl'];
    String? optional(String key) {
      final value = json[key];
      if (value != null && value is! String) {
        throw FormatException('Invalid product $key');
      }
      return value as String?;
    }

    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        price is! int ||
        price < 0 ||
        unit is! String ||
        inStock is! bool ||
        category is! Map<String, dynamic> ||
        (image != null && image is! String)) {
      throw const FormatException('Invalid product');
    }
    return MarketProduct(
      id: id,
      name: name,
      nameKm: optional('nameKm'),
      summary: optional('description'),
      summaryKm: optional('descriptionKm'),
      origin: optional('origin'),
      unit: unit,
      unitKm: optional('unitKm'),
      priceInCents: price,
      imageUrl: resolveUrl == null ? image as String? : resolveUrl(image),
      inStock: inStock,
      category: ProductCategory.fromJson(category),
      isOrganic: json['isOrganic'] == true,
      isNewArrival: json['isNewArrival'] == true,
      isPopular: json['isPopular'] == true,
    );
  }

  /// Same shape as the server's product, used for the saved basket.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'nameKm': nameKm,
    'description': summary,
    'descriptionKm': summaryKm,
    'origin': origin,
    'unit': unit,
    'unitKm': unitKm,
    'priceCents': priceInCents,
    'imageUrl': imageUrl,
    'inStock': inStock,
    'category': category.toJson(),
    'isOrganic': isOrganic,
    'isNewArrival': isNewArrival,
    'isPopular': isPopular,
  };
}
