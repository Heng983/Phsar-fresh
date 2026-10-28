import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/pressable.dart';

class CheckoutChoiceCard extends StatelessWidget {
  final bool selected;
  final bool filled;
  final Widget leading;
  final String title;
  final String subtitle;

  /// Shown in place of the [subtitle] text; [subtitle] becomes its semantics label.
  final Widget? subtitleWidget;
  final String? badge;
  final Widget? detail;
  final VoidCallback onTap;

  const CheckoutChoiceCard({
    super.key,
    required this.selected,
    this.filled = false,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.subtitleWidget,
    this.badge,
    this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inverse = selected && filled;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: Pressable(
        scale: .98,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.curve,
          decoration: BoxDecoration(
            color: inverse
                ? AppColors.loginButton
                : selected
                ? Colors.white
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: inverse
                ? AppShadows.glow(AppColors.loginButton)
                : selected
                ? AppShadows.subtle
                : const [],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        leading,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 5,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: inverse
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontSize: AppFontSize.bodySmall,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (badge != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.mango,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        badge!,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: AppFontSize.badge,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              if (subtitleWidget != null)
                                Semantics(
                                  label: subtitle,
                                  child: ExcludeSemantics(
                                    child: subtitleWidget!,
                                  ),
                                )
                              else
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: inverse
                                        ? const Color(0xFFD6F1DA)
                                        : AppColors.textSecondary,
                                    fontSize: AppFontSize.caption,
                                    height: 1.45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ExcludeSemantics(
                          child: Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle,
                            size: 22,
                            color: inverse
                                ? const Color(0xFFD1FFDA)
                                : selected
                                ? AppColors.primary
                                : const Color(0xFFD8E3CE),
                          ),
                        ),
                      ],
                    ),
                    if (selected && detail != null) ...[
                      const SizedBox(height: 14),
                      detail!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
