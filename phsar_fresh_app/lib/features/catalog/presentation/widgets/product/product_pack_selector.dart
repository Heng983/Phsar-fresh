import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_detail.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';

class ProductPackSelector extends ConsumerWidget {
  final List<ProductPackOption> packs;
  final ProductPackOption selected;
  final ValueChanged<ProductPackOption> onChanged;

  const ProductPackSelector({
    super.key,
    required this.packs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productPackSize,
          style: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
            final columns = (constraints.maxWidth / (100 * scale))
                .floor()
                .clamp(1, packs.length);
            final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final pack in packs)
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Semantics(
                            selected: selected.size == pack.size,
                            button: true,
                            child: Material(
                              color: selected.size == pack.size
                                  ? AppColors.lightGreen
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: selected.size == pack.size
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: selected.size == pack.size ? 1.6 : 1,
                                ),
                              ),
                              child: InkWell(
                                key: ValueKey('product-pack-${pack.size.name}'),
                                onTap: () => onChanged(pack),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 14,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Text(
                                          pack.label(l10n),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: AppFontSize.caption,
                                            height: 1.4,
                                            fontWeight: FontWeight.w600,
                                            color: selected.size == pack.size
                                                ? AppColors.primaryDark
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          productPrice(
                                            pack.priceInCents,
                                            l10n,
                                            currency,
                                          ),
                                          style: TextStyle(
                                            fontSize: AppFontSize.caption,
                                            fontWeight: FontWeight.w700,
                                            color: selected.size == pack.size
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (pack.isPopular)
                            Positioned(
                              top: -7,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.productPopular,
                                  style: const TextStyle(
                                    fontSize: AppFontSize.badge,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
