import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

enum AppSnackBarTone { success, info }

class AppSnackBar {
  AppSnackBar._();

  static TextStyle _messageStyle(String message) => TextStyle(
    color: AppColors.textPrimary,
    fontSize: AppFontSize.bodySmall,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTheme.letterSpacingFor(message, .1),
    height: 1.4,
  );

  /// [icon] replaces the tone's own icon; [onTap] makes the whole bar a
  /// button that also dismisses it. [actionLabel] + [onAction] add a text
  /// button on the right (e.g. "Undo").
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarTone tone = AppSnackBarTone.info,
    IconData? icon,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final hasAction = actionLabel != null && onAction != null;
    final messenger = ScaffoldMessenger.of(context);
    final media = MediaQuery.of(context);
    final maxWidth = math.min(
      520.0,
      media.size.width - media.padding.horizontal - 48,
    );
    final text = TextPainter(
      text: TextSpan(
        text: message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.merge(_messageStyle(message)),
      ),
      textDirection: Directionality.of(context),
      textScaler: media.textScaler,
      locale: Localizations.localeOf(context),
    )..layout();
    final width = (text.width + 76 + (hasAction ? 96 : 0))
        .clamp(math.min(184.0, maxWidth), maxWidth)
        .toDouble();
    text.dispose();
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          width: width,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          dismissDirection: DismissDirection.horizontal,
          content: _GlassSnackBarContent(
            message: message,
            tone: tone,
            icon: icon,
            actionLabel: hasAction ? actionLabel : null,
            onAction: hasAction
                ? () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  }
                : null,
            onTap: onTap == null
                ? null
                : () {
                    messenger.hideCurrentSnackBar();
                    onTap();
                  },
          ),
        ),
        snackBarAnimationStyle: media.disableAnimations
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 300),
                reverseDuration: Duration(milliseconds: 180),
              ),
      );
  }
}

class _GlassSnackBarContent extends StatelessWidget {
  final String message;
  final AppSnackBarTone tone;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GlassSnackBarContent({
    required this.message,
    required this.tone,
    this.icon,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(28));
    final highContrast = MediaQuery.highContrastOf(context);
    final accent = tone == AppSnackBarTone.success
        ? AppColors.primary
        : AppColors.orange;

    final content = _glass(context, radius, highContrast, accent);
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _glass(
    BuildContext context,
    BorderRadius radius,
    bool highContrast,
    Color accent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: .12),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: .04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          enabled: !highContrast,
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: CustomPaint(
            foregroundPainter: _GlassRimPainter(highContrast: highContrast),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                color: highContrast ? Colors.white : null,
                gradient: highContrast
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: .76),
                          Colors.white.withValues(alpha: .56),
                          const Color(0xFFF0FFF6).withValues(alpha: .68),
                        ],
                        stops: const [0, .45, 1],
                      ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: tone == AppSnackBarTone.success
                                ? [const Color(0xFF24A261), AppColors.primary]
                                : [
                                    const Color(0xFFFFF3DC),
                                    AppColors.lightOrange,
                                  ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .5),
                            width: .8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: .15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon ??
                              (tone == AppSnackBarTone.success
                                  ? Icons.check_rounded
                                  : Icons.info_outline_rounded),
                          color: tone == AppSnackBarTone.success
                              ? Colors.white
                              : accent,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: AppSnackBar._messageStyle(message),
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        key: const Key('snackbar-action'),
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.lightGreen,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            fontSize: AppFontSize.footnote,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

class _GlassRimPainter extends CustomPainter {
  final bool highContrast;

  const _GlassRimPainter({required this.highContrast});

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    if (highContrast) {
      paint.color = AppColors.primary.withValues(alpha: .25);
    } else {
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: .98),
          Colors.white.withValues(alpha: .3),
          AppColors.primaryDark.withValues(alpha: .12),
          Colors.white.withValues(alpha: .8),
        ],
        stops: const [0, .38, .72, 1],
      ).createShader(bounds);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(.6), const Radius.circular(27.4)),
      paint,
    );
    if (!highContrast) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          bounds.deflate(1.8),
          const Radius.circular(26.2),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .6
          ..color = Colors.white.withValues(alpha: .24),
      );
    }
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      oldDelegate.highContrast != highContrast;
}
