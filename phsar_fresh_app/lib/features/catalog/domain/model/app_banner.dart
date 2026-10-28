import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';

/// What tapping a server banner does.
enum BannerAction { none, openChat, openCategory, openProduct }

/// A picture banner for the Explore carousel, made in the admin panel
/// (`GET /banners`).
class AppBanner {
  final String id;
  final String title;
  final String? titleKm;
  final String? body;
  final String? bodyKm;
  final String? buttonLabel;
  final String? buttonLabelKm;
  final String? imageUrl;
  final BannerAction action;

  /// Set when [action] is [BannerAction.openCategory].
  final String? categoryId;

  /// Set when [action] is [BannerAction.openProduct].
  final MarketProduct? product;

  /// When the banner stops showing; null = no end.
  final DateTime? endsAt;

  const AppBanner({
    required this.id,
    required this.title,
    this.titleKm,
    this.body,
    this.bodyKm,
    this.buttonLabel,
    this.buttonLabelKm,
    this.imageUrl,
    this.action = BannerAction.none,
    this.categoryId,
    this.product,
    this.endsAt,
  });

  String localizedTitle(String languageCode) =>
      pickLocalized(languageCode, title, titleKm);

  String? localizedBody(String languageCode) =>
      body == null ? null : pickLocalized(languageCode, body!, bodyKm);

  String? localizedButton(String languageCode) => buttonLabel == null
      ? null
      : pickLocalized(languageCode, buttonLabel!, buttonLabelKm);

  static const _actions = {
    'NONE': BannerAction.none,
    'OPEN_CHAT': BannerAction.openChat,
    'OPEN_CATEGORY': BannerAction.openCategory,
    'OPEN_PRODUCT': BannerAction.openProduct,
  };

  /// Reads one item of `GET /banners`.
  factory AppBanner.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    String? optional(String key) {
      final value = json[key];
      if (value != null && value is! String) {
        throw FormatException('Invalid banner $key');
      }
      final text = (value as String?)?.trim();
      return text == null || text.isEmpty ? null : text;
    }

    final id = json['id'];
    final title = json['title'];
    final action = _actions[json['action']] ?? BannerAction.none;
    final product = json['product'];
    if (id is! String || title is! String || title.trim().isEmpty) {
      throw const FormatException('Invalid banner');
    }
    if (product != null && product is! Map<String, dynamic>) {
      throw const FormatException('Invalid banner product');
    }
    final image = optional('imageUrl');
    final ends = optional('endsAt');
    return AppBanner(
      id: id,
      title: title,
      titleKm: optional('titleKm'),
      body: optional('body'),
      bodyKm: optional('bodyKm'),
      buttonLabel: optional('buttonLabel'),
      buttonLabelKm: optional('buttonLabelKm'),
      imageUrl: resolveUrl == null ? image : resolveUrl(image),
      action: action,
      categoryId: optional('categoryId'),
      product: product == null
          ? null
          : MarketProduct.fromJson(product, resolveUrl: resolveUrl),
      endsAt: ends == null ? null : DateTime.tryParse(ends),
    );
  }
}
