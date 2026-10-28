import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onSupport;

  const LoginFooter({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: AppFontSize.footnote,
      height: 1.6,
    );
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 3,
          children: [
            Text(
              l10n.authAgreementPrefix,
              style: style,
              textAlign: TextAlign.center,
            ),
            _link(l10n.authTerms, onTerms),
            Text(l10n.authAgreementAnd, style: style),
            _link(l10n.authPrivacy, onPrivacy),
            Text(
              l10n.authAgreementSuffix,
              style: style,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Material(
          color: const Color(0xFFEAF1E3),
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onSupport,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.authSupport,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppFontSize.badge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _link(String label, VoidCallback onPressed) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: AppFontSize.footnote,
        height: 1.6,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      ),
    ),
  );
}
