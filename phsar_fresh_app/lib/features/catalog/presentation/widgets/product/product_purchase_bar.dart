import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';

/// Favourite + one wide "Add to basket · total" button.
class ProductPurchaseBar extends ConsumerWidget {
  final int totalInCents;
  final bool isFavorite;
  final VoidCallback onFavorite;

  /// Null disables the button (e.g. out of stock).
  final VoidCallback? onAdd;

  const ProductPurchaseBar({
    super.key,
    required this.totalInCents,
    required this.isFavorite,
    required this.onFavorite,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    final enabled = onAdd != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('product-detail-favorite'),
                    tooltip: isFavorite
                        ? l10n.productUnsaved
                        : l10n.productSaved,
                    onPressed: onFavorite,
                    style: IconButton.styleFrom(
                      fixedSize: const Size.square(54),
                      backgroundColor: isFavorite
                          ? AppColors.lightGreen
                          : Colors.white,
                      foregroundColor: isFavorite
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      side: BorderSide(
                        color: isFavorite
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: enabled
                            ? AppShadows.glow(AppColors.primary)
                            : null,
                      ),
                      child: FilledButton(
                        key: const Key('product-detail-add'),
                        onPressed: onAdd,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_basket_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.productAddBasket,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: AppFontSize.bodySmall,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              productPrice(totalInCents, l10n, currency),
                              key: const Key('product-detail-total'),
                              style: const TextStyle(
                                fontSize: AppFontSize.body,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
