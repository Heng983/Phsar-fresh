import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/pressable.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';

/// Product tile: photo on top, bold name, origin, then the price with a
/// round "+" that adds one to the basket without leaving the list.
class MarketProductCard extends ConsumerWidget {
  final MarketProduct product;
  final VoidCallback onTap;
  final double imageHeight;

  /// Shared with the detail page so the photo flies into place. Must be
  /// unique on screen; null disables the animation (e.g. skeletons).
  final Object? heroTag;

  const MarketProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.imageHeight,
    this.heroTag,
  });

  Widget _maybeHero(Widget child) {
    final tag = heroTag;
    return tag == null ? child : Hero(tag: tag, child: child);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = product.title(l10n);
    final price = ref
        .watch(currencyProvider)
        .format(product.priceInCents, l10n.localeName);
    final origin = product.origin?.trim() ?? '';
    const radius = BorderRadius.all(Radius.circular(AppRadius.lg));
    return Pressable(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: radius,
          border: Border.all(color: AppDecorations.cardBorder),
          boxShadow: AppShadows.subtle,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // White card: white-background photos blend in.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: _maybeHero(
                          MarketImage(
                            path: product.imageUrl,
                            semanticLabel: title,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (product.isOrganic)
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: _Pill(label: l10n.exploreOrganic),
                          ),
                        ),
                      if (!product.inStock)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _Pill(
                            label: l10n.catalogOutOfStock,
                            muted: true,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppFontSize.bodyLarge,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (origin.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            origin,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppFontSize.footnote,
                              height: 1.35,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: price,
                                      style: const TextStyle(
                                        fontSize: AppFontSize.bodyLarge,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / ${product.unitLabel(l10n)}',
                                      style: const TextStyle(
                                        fontSize: AppFontSize.badge,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _AddButton(product: product),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round "+" in the bottom-right corner. Shows how many are already in the
/// basket; disabled when out of stock.
class _AddButton extends ConsumerWidget {
  const _AddButton({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final inBasket = ref.watch(
      marketCartProvider.select(
        (items) => items
            .where((item) => item.product.id == product.id)
            .fold(0, (sum, item) => sum + item.quantity),
      ),
    );
    final enabled = product.inStock;
    final button = Material(
      color: enabled ? AppColors.lightGreen : AppColors.inputBackground,
      shape: const CircleBorder(),
      child: InkWell(
        key: ValueKey('add-to-cart-${product.id}'),
        customBorder: const CircleBorder(),
        onTap: !enabled
            ? null
            : () {
                // The count bubble, cart badge and mini-cart bar already
                // confirm the add; a light tap replaces the snackbar.
                ref.read(marketCartProvider.notifier).add(product);
                HapticFeedback.lightImpact();
              },
        child: Tooltip(
          message: l10n.productAddBasket,
          child: SizedBox.square(
            dimension: 40,
            child: Icon(
              Icons.add_rounded,
              size: 24,
              color: enabled ? AppColors.primaryDark : AppColors.inputHint,
            ),
          ),
        ),
      ),
    );
    if (inBasket == 0) return button;
    // How many are already in the basket.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: -4,
          right: -4,
          child: IgnorePointer(
            child: Container(
              key: ValueKey('in-basket-${product.id}'),
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.card, width: 2),
              ),
              child: Text(
                '$inBasket',
                style: const TextStyle(
                  fontSize: AppFontSize.badge,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: muted ? AppColors.textSecondary : AppColors.primary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: AppFontSize.badge,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}
