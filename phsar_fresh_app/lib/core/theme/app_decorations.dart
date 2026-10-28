import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';

/// Shared corner radii so cards, sheets and buttons feel like one family.
class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;

  /// The leaf silhouette for anything that shows produce (product cards,
  /// category photos, deal banners): two soft corners, two tighter tips.
  static BorderRadius leaf([double size = 26]) => BorderRadius.only(
    topLeft: Radius.circular(size * .32),
    topRight: Radius.circular(size),
    bottomLeft: Radius.circular(size),
    bottomRight: Radius.circular(size * .32),
  );
}

/// Soft, low-contrast shadows tinted with forest ink instead of black.
class AppShadows {
  AppShadows._();

  static const subtle = [
    BoxShadow(color: Color(0x0A15281D), blurRadius: 12, offset: Offset(0, 3)),
  ];

  static const soft = [
    BoxShadow(color: Color(0x1015281D), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Coloured glow for primary actions.
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: .24),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppDecorations {
  AppDecorations._();

  static const cardBorder = Color(0xFFE6ECDF);

  static BoxDecoration card({double radius = AppRadius.lg}) => BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: cardBorder),
    boxShadow: AppShadows.subtle,
  );
}

/// Standard durations and curves for UI motion.
class AppMotion {
  AppMotion._();

  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 260);
  static const curve = Curves.easeOutCubic;

  /// Honours the system "reduce motion" setting.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true
      ? Duration.zero
      : duration;
}
