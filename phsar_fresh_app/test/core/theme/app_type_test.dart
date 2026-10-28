import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

void main() {
  test('Khmer text never scales below the minimum size', () {
    const scaler = MinimumFontSizeTextScaler(TextScaler.noScaling);
    expect(scaler.scale(AppFontSize.badge), AppFontSize.khmerMinimum);
    expect(scaler.scale(AppFontSize.body), AppFontSize.body);
  });

  test("The user's own text size still applies on top", () {
    const scaler = MinimumFontSizeTextScaler(TextScaler.linear(1.5));
    expect(scaler.scale(AppFontSize.badge), 18);
    expect(scaler.scale(AppFontSize.title), 27);
  });

  test('Khmer headings get room for marks above and below', () {
    final en = appTextTheme(isKhmer: false);
    final km = appTextTheme(isKhmer: true);
    expect(en.displaySmall!.fontSize, km.displaySmall!.fontSize);
    expect(km.displaySmall!.height, greaterThanOrEqualTo(1.45));
    expect(km.bodyMedium!.letterSpacing, 0);
    expect(
      km.bodyMedium!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
