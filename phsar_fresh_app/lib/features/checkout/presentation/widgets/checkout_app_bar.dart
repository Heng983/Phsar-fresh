import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';

class CheckoutAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final double toolbarHeight;

  const CheckoutAppBar({super.key, required this.toolbarHeight});

  static const _titleStyle = TextStyle(
    fontSize: AppFontSize.headlineLarge,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.primaryDark,
  );

  static const _captionStyle = TextStyle(
    fontSize: AppFontSize.caption,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static double heightFor(BuildContext context) {
    final availableWidth = math.min(
      720.0,
      MediaQuery.sizeOf(context).width -
          MediaQuery.paddingOf(context).horizontal,
    );
    final titleWidth = math.max(1.0, availableWidth - 40 - 48 - 14);
    final title = TextPainter(
      text: TextSpan(
        text: context.l10n.checkoutTitle,
        style: Theme.of(context).textTheme.bodyMedium?.merge(
          _titleStyle.copyWith(height: context.lineHeight(1.2)),
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.localeOf(context),
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: titleWidth);
    final height = math.max(
      84.0,
      title.height + 5 + MediaQuery.textScalerOf(context).scale(12) * 1.4 + 24,
    );
    title.dispose();
    return height.ceilToDouble();
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(marketCartCountProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          side: BorderSide(color: AppColors.border),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: toolbarHeight,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('checkout-back'),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.primaryDark,
                          minimumSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                context.l10n.checkoutTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _titleStyle.copyWith(
                                  height: context.lineHeight(1.2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const ExcludeSemantics(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(width: 6, height: 6),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    context.l10n.marketItemCount(itemCount),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _captionStyle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
