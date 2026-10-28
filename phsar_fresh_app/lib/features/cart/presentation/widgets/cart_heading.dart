import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class CartHeading extends StatelessWidget {
  final int itemCount;

  const CartHeading({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.cartEyebrow,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: AppFontSize.footnote,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.marketYourBasket,
            style: TextStyle(
              fontSize: AppFontSize.displayLarge,
              height: context.lineHeight(1.2),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              context.l10n.marketItemCount(itemCount),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: AppFontSize.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        context.l10n.cartSubtitle,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
    ],
  );
}
