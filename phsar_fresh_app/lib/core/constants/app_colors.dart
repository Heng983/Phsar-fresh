import 'package:flutter/material.dart';

/// A market palette: rice-paper backgrounds, banana-leaf greens and one warm
/// mango accent for deals. Neutrals lean green rather than blue so produce
/// photos look fresh beside them.
class AppColors {
  AppColors._();

  /// Banana leaf: buttons, links, selected states. Matches the logo.
  static const Color primary = Color(0xFF007A38);

  static const Color primaryDark = Color(0xFF005F2D);

  /// Rice paper: the page behind everything.
  static const Color background = Color(0xFFF4F7EF);

  static const Color card = Colors.white;

  /// Fresh-leaf green behind product cards; photos sit on white tiles on it.
  static const Color productCard = Color(0xFFEEF6E5);

  /// Forest ink: headings and body text.
  static const Color textPrimary = Color(0xFF15281D);

  static const Color textSecondary = Color(0xFF56645A);

  /// Young shoot: selected pills, badges and soft green fills.
  static const Color lightGreen = Color(0xFFE3F1D8);

  static const Color lightOrange = Color(0xFFFFEFCF);

  static const Color orange = Color(0xFF9D5000);

  /// Mango: the one warm accent, kept for deals and countdowns.
  static const Color mango = Color(0xFFF59E0B);

  /// Husk: borders.
  static const Color border = Color(0xFFE3E9DB);

  static const Color inputBackground = Color(0xFFEDF2E6);
  static const Color inputHint = Color(0xFF93A196);
  static const Color divider = Color(0xFFE1E8D9);
  static const Color mint = Color(0xFFE6F3DE);
  static const Color loginButton = Color(0xFF15813C);
}

/// A soft produce-coloured fill with a matching dark "ink" for icons and text
/// on it (ink on soft keeps at least 4.5 : 1 contrast).
class AppTint {
  const AppTint(this.soft, this.ink);

  /// Background for tiles, icon chips and photo wells.
  final Color soft;

  /// Icons and short text on [soft].
  final Color ink;
}

/// The market's colours: leafy green, mango, chili, sky, eggplant, rice
/// husk and lime. Use one per card or category so screens feel like a market
/// stall, while text stays forest green.
class AppTints {
  AppTints._();

  static const leaf = AppTint(Color(0xFFE3F1D8), Color(0xFF2E6A1E));
  static const mango = AppTint(Color(0xFFFFF0CC), Color(0xFF8A4F00));
  static const chili = AppTint(Color(0xFFFDE4DE), Color(0xFFA2311E));
  static const sky = AppTint(Color(0xFFDDEFF8), Color(0xFF1C5D78));
  static const eggplant = AppTint(Color(0xFFEDE5F6), Color(0xFF5A3D85));
  static const husk = AppTint(Color(0xFFF6ECDC), Color(0xFF77522B));
  static const lime = AppTint(Color(0xFFEEF5CC), Color(0xFF566610));

  /// Money teal for payment: reads as cash/banking, distinct from the
  /// brand leaf green and the delivery sky blue.
  static const teal = AppTint(Color(0xFFDDF3EC), Color(0xFF0B6B57));
}
