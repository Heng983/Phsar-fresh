import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_detail.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/product_favorites_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_farm_section.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_image_gallery.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_info_section.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_pack_selector.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_purchase_bar.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_quantity_selector.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product/product_similar_section.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final MarketProduct product;

  /// The tapped card's hero tag, so its photo flies into the gallery.
  final Object? heroTag;

  const ProductDetailPage({super.key, required this.product, this.heroTag});

  static Future<void> open(
    BuildContext context,
    MarketProduct product, {
    Object? heroTag,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: product, heroTag: heroTag),
    ),
  );

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late final ProductDetail _detail;

  /// Null for products with a single price (all server products today).
  ProductPackOption? _pack;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _detail = productDetailFor(widget.product);
    _pack = _detail.defaultPack;
  }

  int get _priceInCents => _pack?.priceInCents ?? widget.product.priceInCents;

  String _unitLabel(AppLocalizations l10n) =>
      _pack?.label(l10n) ?? widget.product.unitLabel(l10n);

  void _addToBasket() {
    ref
        .read(marketCartProvider.notifier)
        .add(widget.product, quantity: _quantity, pack: _pack);
    HapticFeedback.lightImpact();
  }

  Future<void> _copyProduct() async {
    final l10n = context.l10n;
    final source = [
      _detail.farmName ?? widget.product.origin,
      _detail.farmAddress,
    ].whereType<String>().join(', ');
    await Clipboard.setData(
      ClipboardData(
        text: [
          widget.product.title(l10n),
          '${_unitLabel(l10n)} • ${productPrice(_priceInCents, l10n, ref.read(currencyProvider))}',
          if (source.isNotEmpty) source,
        ].join('\n'),
      ),
    );
    if (!mounted) return;
    AppSnackBar.show(
      context,
      message: l10n.productCopied,
      tone: AppSnackBarTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSource = _detail.farmName != null || widget.product.origin != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const Key('product-detail-scroll'),
              padding: EdgeInsets.zero,
              children: [
                ProductImageGallery(
                  images: _detail.images,
                  title: widget.product.title(context.l10n),
                  heroTag: widget.heroTag,
                  onCopy: _copyProduct,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProductInfoSection(
                        detail: _detail,
                        priceInCents: _priceInCents,
                        unitLabel: _unitLabel(l10n),
                      ),
                      if (_detail.packs.length > 1) ...[
                        const SizedBox(height: 24),
                        ProductPackSelector(
                          packs: _detail.packs,
                          selected: _pack!,
                          onChanged: (pack) => setState(() => _pack = pack),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ProductQuantitySelector(
                        quantity: _quantity,
                        unitLabel: _unitLabel(l10n),
                        onChanged: (quantity) =>
                            setState(() => _quantity = quantity),
                      ),
                      if (hasSource) ...[
                        const SizedBox(height: 24),
                        ProductFarmSection(detail: _detail),
                      ],
                      ProductSimilarSection(product: widget.product),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ProductPurchaseBar(
        totalInCents: _priceInCents * _quantity,
        isFavorite: ref
            .watch(productFavoritesProvider)
            .containsKey(widget.product.id),
        onFavorite: () =>
            ref.read(productFavoritesProvider.notifier).toggle(widget.product),
        onAdd: widget.product.inStock ? _addToBasket : null,
      ),
    );
  }
}
