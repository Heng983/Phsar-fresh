/// A product suggested by Ming Sros, as returned by `POST /chat`.
class ChatProduct {
  final String id;
  final String name;
  final String? nameKm;
  final String? origin;
  final String category;
  final String unit;
  final int priceCents;
  final String? imageUrl;
  final bool inStock;

  const ChatProduct({
    required this.id,
    required this.name,
    this.nameKm,
    this.origin,
    required this.category,
    required this.unit,
    required this.priceCents,
    this.imageUrl,
    required this.inStock,
  });

  /// The Khmer name when the app is in Khmer and the server supplied one.
  String displayName(String languageCode) =>
      languageCode == 'km' && (nameKm?.trim().isNotEmpty ?? false)
      ? nameKm!
      : name;

  /// Parses and validates one product. Relative image paths are resolved
  /// against [baseUri] (the API host) so `/uploads/x.jpg` loads correctly.
  factory ChatProduct.fromJson(Map<String, dynamic> json, {Uri? baseUri}) {
    final id = json['id'];
    final name = json['name'];
    final nameKm = json['nameKm'];
    final origin = json['origin'];
    final category = json['category'];
    final unit = json['unit'];
    final priceCents = json['priceCents'];
    final imageUrl = json['imageUrl'];
    final inStock = json['inStock'];
    if ((id is! String && id is! num) ||
        id.toString().trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        (nameKm != null && nameKm is! String) ||
        (origin != null && origin is! String) ||
        category is! String ||
        unit is! String ||
        priceCents is! num ||
        !priceCents.isFinite ||
        priceCents < 0 ||
        priceCents % 1 != 0 ||
        (imageUrl != null && imageUrl is! String) ||
        inStock is! bool) {
      throw const FormatException('Invalid chat product');
    }
    return ChatProduct(
      id: id.toString(),
      name: name,
      nameKm: nameKm as String?,
      origin: origin as String?,
      category: category,
      unit: unit,
      priceCents: priceCents.toInt(),
      imageUrl: _resolveImage(imageUrl as String?, baseUri),
      inStock: inStock,
    );
  }

  static String? _resolveImage(String? url, Uri? baseUri) {
    final value = url?.trim();
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.hasScheme) return value;
    return baseUri?.resolveUri(uri).toString();
  }
}

/// One ingredient of a dish, with the matching product (null when Phsar Fresh
/// does not sell it).
class ChatRecipeItem {
  final String ingredient;
  final String? quantity;
  final ChatProduct? product;

  const ChatRecipeItem({required this.ingredient, this.quantity, this.product});
}

/// The ingredient list Ming Sros returns for "what do I need to cook X?".
class ChatRecipe {
  final String dish;
  final int? servings;
  final List<ChatRecipeItem> items;

  const ChatRecipe({required this.dish, this.servings, required this.items});

  /// Parses and validates the `recipe` of a `POST /chat` reply.
  factory ChatRecipe.fromJson(Map<String, dynamic> json, {Uri? baseUri}) {
    final dish = json['dish'];
    final servings = json['servings'];
    final items = json['items'];
    if (dish is! String ||
        dish.trim().isEmpty ||
        (servings != null && (servings is! num || servings % 1 != 0)) ||
        items is! List) {
      throw const FormatException('Invalid chat recipe');
    }
    return ChatRecipe(
      dish: dish,
      servings: (servings as num?)?.toInt(),
      items: List.unmodifiable([
        for (final item in items) _item(item, baseUri),
      ]),
    );
  }

  static ChatRecipeItem _item(Object? value, Uri? baseUri) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat recipe item');
    }
    final ingredient = value['ingredient'];
    final quantity = value['quantity'];
    final product = value['product'];
    if (ingredient is! String ||
        ingredient.trim().isEmpty ||
        (quantity != null && quantity is! String) ||
        (product != null && product is! Map<String, dynamic>)) {
      throw const FormatException('Invalid chat recipe item');
    }
    return ChatRecipeItem(
      ingredient: ingredient,
      quantity: (quantity as String?)?.trim().isEmpty ?? true ? null : quantity,
      product: product == null
          ? null
          : ChatProduct.fromJson(
              product as Map<String, dynamic>,
              baseUri: baseUri,
            ),
    );
  }
}

class ChatMessage {
  final bool isUser;
  final String text;
  final List<ChatProduct> products;
  final ChatRecipe? recipe;
  final DateTime? sentAt;

  const ChatMessage({
    required this.isUser,
    required this.text,
    this.products = const [],
    this.recipe,
    this.sentAt,
  });
}
