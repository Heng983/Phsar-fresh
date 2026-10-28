import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';

class CartItemCard extends ConsumerWidget {
  final MarketCartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    final source =
        productDetailFor(item.product).farmName ?? item.product.origin;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo and name open the product; the ✕ and stepper stay
              // separate so they never trigger navigation.
              Expanded(
                child: InkWell(
                  key: ValueKey('cart-item-open-${item.product.id}'),
                  onTap: () => ProductDetailPage.open(context, item.product),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ClipRRect(
                          borderRadius: AppRadius.leaf(22),
                          child: SizedBox(
                            width: 82,
                            height: 96,
                            child: MarketImage(
                              path: item.product.imageUrl,
                              semanticLabel: item.product.title(l10n),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (source != null)
                                Text(
                                  source,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: AppFontSize.badge,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                item.product.title(l10n),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: AppFontSize.bodyLarge,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                productPrice(item.priceInCents, l10n, currency),
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: AppFontSize.headline,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                productConvertedPrice(
                                  item.priceInCents,
                                  l10n,
                                  currency,
                                ),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppFontSize.badge,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.cartRemoveItem(item.product.title(l10n)),
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    item.pack?.label(l10n) ??
                        productDetailFor(
                          item.product,
                        ).defaultPack?.label(l10n) ??
                        item.product.unitLabel(l10n),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppFontSize.caption,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _QuantityControl(
                    quantity: item.quantity,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityControl({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.l10n.marketDecreaseQuantity,
          onPressed: () => onChanged(quantity - 1),
          icon: const Icon(Icons.remove_rounded, size: 20),
        ),
        Semantics(
          label: context.l10n.productQuantity,
          value: '$quantity',
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton.filled(
          tooltip: context.l10n.marketIncreaseQuantity,
          onPressed: () => onChanged(quantity + 1),
          style: IconButton.styleFrom(backgroundColor: AppColors.primaryDark),
          icon: const Icon(Icons.add_rounded, size: 20),
        ),
      ],
    ),
  );
}
