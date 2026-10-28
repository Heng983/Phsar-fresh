import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/tint_icon.dart';

class CheckoutSectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final AppTint tint;

  const CheckoutSectionHeading({
    super.key,
    required this.icon,
    required this.title,
    this.badge,
    this.tint = AppTints.leaf,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TintIcon(icon: icon, tint: tint),
                ),
              ),
              TextSpan(text: title),
            ],
          ),
          style: const TextStyle(
            fontSize: AppFontSize.headline,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tint.soft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                color: tint.ink,
                fontSize: AppFontSize.badge,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ),
  );
}
