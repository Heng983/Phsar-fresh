import 'package:flutter/material.dart';

/// The app's type scale. Every `fontSize` in the app uses one of these, so a
/// size changes in one place. English is Figtree, Khmer is Kantumruy Pro.
abstract final class AppFontSize {
  /// Short English badges ("NEW", "-20%"). Khmer never renders below
  /// [khmerMinimum], see [MinimumFontSizeTextScaler].
  static const double badge = 11;

  /// Hints, timestamps, "≈ 1.00$", units.
  static const double caption = 12;

  /// Secondary lines and small labels.
  static const double footnote = 13;

  /// Compact body text, list rows, chips.
  static const double bodySmall = 14;

  /// Body text and buttons.
  static const double body = 15;

  /// Product names and card titles.
  static const double bodyLarge = 16;

  /// A price in a product card.
  static const double price = 17;

  /// Section titles ("Order summary").
  static const double title = 18;

  /// Page and sheet titles.
  static const double headline = 22;

  /// Large page titles.
  static const double headlineLarge = 24;

  /// Big totals and hero prices.
  static const double display = 28;

  /// Screen titles such as "Your basket".
  static const double displayLarge = 32;

  /// Onboarding headline.
  static const double hero = 38;

  /// Khmer subscripts and vowel marks become unreadable below this.
  static const double khmerMinimum = 12;
}

abstract final class AppLineHeight {
  /// Khmer stacks marks above and below the line, so tight Latin heading
  /// heights (1.1–1.25) would make lines collide.
  static const double khmerMinimum = 1.45;
}

/// Prices and totals line up because every digit is the same width.
const appFontFeatures = [FontFeature.tabularFigures()];

extension AppTypeContext on BuildContext {
  bool get isKhmer => Localizations.localeOf(this).languageCode == 'km';

  /// [latin] for English; at least [AppLineHeight.khmerMinimum] for Khmer.
  double lineHeight(double latin) =>
      isKhmer && latin < AppLineHeight.khmerMinimum
      ? AppLineHeight.khmerMinimum
      : latin;
}

/// Material's text roles on the same scale, so buttons, fields, dialogs and
/// app bars match hand-styled text.
TextTheme appTextTheme({required bool isKhmer}) {
  TextStyle style(
    double size,
    FontWeight weight, {
    required double latin,
    required double khmer,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    height: isKhmer ? khmer : latin,
    letterSpacing: 0,
    fontFeatures: appFontFeatures,
  );

  const bold = FontWeight.w700;
  const semi = FontWeight.w600;
  const regular = FontWeight.w400;
  return TextTheme(
    displayLarge: style(AppFontSize.hero, bold, latin: 1.15, khmer: 1.45),
    displayMedium: style(
      AppFontSize.displayLarge,
      bold,
      latin: 1.2,
      khmer: 1.45,
    ),
    displaySmall: style(AppFontSize.display, bold, latin: 1.2, khmer: 1.45),
    headlineLarge: style(
      AppFontSize.headlineLarge,
      bold,
      latin: 1.25,
      khmer: 1.5,
    ),
    headlineMedium: style(AppFontSize.headline, bold, latin: 1.25, khmer: 1.5),
    headlineSmall: style(AppFontSize.headline, semi, latin: 1.25, khmer: 1.5),
    titleLarge: style(AppFontSize.title, semi, latin: 1.3, khmer: 1.5),
    titleMedium: style(AppFontSize.bodyLarge, semi, latin: 1.4, khmer: 1.55),
    titleSmall: style(AppFontSize.bodySmall, semi, latin: 1.4, khmer: 1.55),
    bodyLarge: style(AppFontSize.bodyLarge, regular, latin: 1.5, khmer: 1.6),
    bodyMedium: style(AppFontSize.bodySmall, regular, latin: 1.43, khmer: 1.5),
    bodySmall: style(AppFontSize.caption, regular, latin: 1.35, khmer: 1.5),
    labelLarge: style(AppFontSize.bodySmall, semi, latin: 1.4, khmer: 1.45),
    labelMedium: style(AppFontSize.caption, semi, latin: 1.35, khmer: 1.45),
    labelSmall: style(AppFontSize.badge, semi, latin: 1.45, khmer: 1.45),
  );
}

/// Applies [minimum] to every font size before the user's own text scaling,
/// so 11 px badges read as 12 px in Khmer without touching each widget.
class MinimumFontSizeTextScaler extends TextScaler {
  const MinimumFontSizeTextScaler(
    this.parent, {
    this.minimum = AppFontSize.khmerMinimum,
  });

  final TextScaler parent;
  final double minimum;

  @override
  double scale(double fontSize) =>
      parent.scale(fontSize < minimum ? minimum : fontSize);

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => parent.textScaleFactor;

  @override
  bool operator ==(Object other) =>
      other is MinimumFontSizeTextScaler &&
      other.parent == parent &&
      other.minimum == minimum;

  @override
  int get hashCode => Object.hash(parent, minimum);

  @override
  String toString() => 'MinimumFontSizeTextScaler($parent, min: $minimum)';
}
