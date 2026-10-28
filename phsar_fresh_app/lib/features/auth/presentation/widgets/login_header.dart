import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/app_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    this.title,
    this.description,
    this.showTagline = true,
  });

  final String? title;
  final String? description;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(size: 76),
        const SizedBox(height: 12),
        Text(
          context.l10n.authEyebrow,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.orange,
            fontSize: AppFontSize.footnote,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title ?? context.l10n.authWelcome,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppFontSize.display,
            height: context.lineHeight(1.2),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: context.l10n.authFreshProduce),
                TextSpan(
                  text: ' (${context.l10n.authKhmerName})',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppFontSize.title,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            description ?? context.l10n.authDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.bodySmall,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }
}
