import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class AppTheme {
  AppTheme._();

  static const englishFontFamily = 'Figtree';
  static const khmerFontFamily = 'KantumruyPro';

  static final _khmerCharacters = RegExp(r'[\u1780-\u17FF\u19E0-\u19FF]');

  /// Khmer labels use natural spacing, including in mixed-language text.
  static double letterSpacingFor(String text, double spacing) =>
      _khmerCharacters.hasMatch(text) ? 0 : spacing;

  static const _naturalSpacing = TextTheme(
    displayLarge: TextStyle(letterSpacing: 0),
    displayMedium: TextStyle(letterSpacing: 0),
    displaySmall: TextStyle(letterSpacing: 0),
    headlineLarge: TextStyle(letterSpacing: 0),
    headlineMedium: TextStyle(letterSpacing: 0),
    headlineSmall: TextStyle(letterSpacing: 0),
    titleLarge: TextStyle(letterSpacing: 0),
    titleMedium: TextStyle(letterSpacing: 0),
    titleSmall: TextStyle(letterSpacing: 0),
    bodyLarge: TextStyle(letterSpacing: 0),
    bodyMedium: TextStyle(letterSpacing: 0),
    bodySmall: TextStyle(letterSpacing: 0),
    labelLarge: TextStyle(letterSpacing: 0),
    labelMedium: TextStyle(letterSpacing: 0),
    labelSmall: TextStyle(letterSpacing: 0),
  );

  static ThemeData get lightTheme => lightThemeFor(isKhmer: false);

  /// The seed palette, pinned to the exact brand colours so default Material
  /// widgets (checkboxes, switches, progress, sheets) match custom widgets.
  static final _colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary)
      .copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.lightGreen,
        onPrimaryContainer: AppColors.primaryDark,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceTint: Colors.transparent,
        surfaceContainerLowest: AppColors.card,
        surfaceContainerLow: const Color(0xFFFAFCF7),
        surfaceContainer: const Color(0xFFF6F9F2),
        surfaceContainerHigh: const Color(0xFFF2F6ED),
        surfaceContainerHighest: AppColors.inputBackground,
        outline: const Color(0xFFD3DBCB),
        outlineVariant: AppDecorations.cardBorder,
      );

  static const _sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
  );

  static ThemeData lightThemeFor({required bool isKhmer}) {
    final theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: _colorScheme,
      fontFamily: isKhmer ? khmerFontFamily : englishFontFamily,
      fontFamilyFallback: [isKhmer ? englishFontFamily : khmerFontFamily],
      textTheme: appTextTheme(isKhmer: isKhmer),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        modalBackgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: _sheetShape,
        clipBehavior: Clip.antiAlias,
        dragHandleColor: Color(0xFFD3DBCB),
        dragHandleSize: Size(40, 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: const Color(0x3315281D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppDecorations.cardBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppDecorations.cardBorder),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightGreen,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: .22),
        selectionHandleColor: AppColors.primary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    return isKhmer
        ? theme.copyWith(
            textTheme: theme.textTheme.merge(_naturalSpacing),
            primaryTextTheme: theme.primaryTextTheme.merge(_naturalSpacing),
          )
        : theme;
  }

  static void registerFontLicenses() {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks([
        englishFontFamily,
      ], await rootBundle.loadString('assets/fonts/Figtree-OFL.txt'));
      yield LicenseEntryWithLineBreaks([
        khmerFontFamily,
      ], await rootBundle.loadString('assets/fonts/KantumruyPro-OFL.txt'));
    });
  }
}
