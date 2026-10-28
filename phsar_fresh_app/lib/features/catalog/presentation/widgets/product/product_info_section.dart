import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_detail.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';

/// Category, title, rating, price and description — the essentials only.
class ProductInfoSection extends ConsumerWidget {
  final ProductDetail detail;
  final int priceInCents;
  final String unitLabel;

  const ProductInfoSection({
    super.key,
    required this.detail,
    required this.priceInCents,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    final organic = detail.product.isOrganic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    organic ? Icons.eco_rounded : Icons.category_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      // The category always fits; "fresh harvest" did not
                      // suit products such as bottled water or salt.
                      organic
                          ? l10n.productOrganicFresh
                          : detail.product.category.label(l10n),
                      key: const Key('product-detail-eyebrow'),
                      style: const TextStyle(
                        fontSize: AppFontSize.caption,
                        height: 1.4,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          detail.product.title(l10n),
          key: const Key('product-detail-title'),
          style: const TextStyle(
            fontSize: AppFontSize.headlineLarge,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              productPrice(priceInCents, l10n, currency),
              style: const TextStyle(
                fontSize: AppFontSize.headline,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '/ $unitLabel  ·  ${productConvertedPrice(priceInCents, l10n, currency)}',
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          detail.product.description(l10n),
          style: const TextStyle(
            fontSize: AppFontSize.bodySmall,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
