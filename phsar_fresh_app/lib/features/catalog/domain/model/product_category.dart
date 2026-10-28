/// Picks the Khmer text in Khmer mode when one is available.
String pickLocalized(String languageCode, String english, String? khmer) =>
    languageCode == 'km' && (khmer?.trim().isNotEmpty ?? false)
    ? khmer!
    : english;

/// A product category, as returned by `GET /categories`.
///
/// [description] and [origin] are only filled by the offline preview catalog.
class ProductCategory {
  final String id;
  final String name;
  final String? nameKm;
  final int productCount;
  final String? imageUrl;
  final String? description;
  final String? descriptionKm;
  final String? origin;
  final String? originKm;

  const ProductCategory({
    required this.id,
    required this.name,
    this.nameKm,
    this.productCount = 0,
    this.imageUrl,
    this.description,
    this.descriptionKm,
    this.origin,
    this.originKm,
  });

  String localizedName(String languageCode) =>
      pickLocalized(languageCode, name, nameKm);

  String? localizedDescription(String languageCode) => description == null
      ? null
      : pickLocalized(languageCode, description!, descriptionKm);

  factory ProductCategory.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    final id = json['id'];
    final name = json['name'];
    final nameKm = json['nameKm'];
    final count = json['productCount'] ?? 0;
    final image = json['imageUrl'];
    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        (nameKm != null && nameKm is! String) ||
        count is! int ||
        (image != null && image is! String)) {
      throw const FormatException('Invalid category');
    }
    return ProductCategory(
      id: id,
      name: name,
      nameKm: nameKm as String?,
      productCount: count,
      imageUrl: resolveUrl == null ? image as String? : resolveUrl(image),
    );
  }

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'nameKm': nameKm};
}
