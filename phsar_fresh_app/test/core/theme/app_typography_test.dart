import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';

import '../../support/pump_helpers.dart';

/// Load the same font faces as the app, rather than the test runner's Ahem font.
Future<void> loadAppFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

void expectAppFont(WidgetTester tester, String family) {
  var checked = 0;
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    void inspect(InlineSpan span, TextStyle inherited) {
      final style = inherited.merge(span.style);
      if (span is TextSpan) {
        final text = span.text?.trim() ?? '';
        if (text.isNotEmpty &&
            style.fontFamily != 'MaterialIcons' &&
            style.fontFamily != 'CupertinoIcons') {
          expect(
            style.fontFamily,
            family,
            reason: 'Unexpected font for "$text"',
          );
          expect(
            style.fontFamilyFallback,
            contains(
              family == AppTheme.englishFontFamily
                  ? AppTheme.khmerFontFamily
                  : AppTheme.englishFontFamily,
            ),
            reason: 'Missing mixed-language fallback for "$text"',
          );
          if (family == AppTheme.khmerFontFamily &&
              RegExp(r'[\u1780-\u17FF]').hasMatch(text)) {
            expect(
              style.letterSpacing ?? 0,
              0,
              reason: 'Khmer text must use natural spacing: "$text"',
            );
          }
          checked++;
        }
        for (final child in span.children ?? <InlineSpan>[]) {
          inspect(child, style);
        }
      }
    }

    inspect(richText.text, const TextStyle());
  }
  expect(checked, greaterThan(0));
  for (final editable in tester.widgetList<EditableText>(
    find.byType(EditableText),
  )) {
    expect(editable.style.fontFamily, family);
  }
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  for (final language in ['en', 'km']) {
    final family = language == 'km'
        ? AppTheme.khmerFontFamily
        : AppTheme.englishFontFamily;

    testWidgets('$language login and checkout use the bundled theme fonts', (
      tester,
    ) async {
      await pumpLogin(tester, language: language, width: 320, textScale: 1.5);
      expectAppFont(tester, family);
      await tester.pumpWidget(const SizedBox());
      await pumpCheckout(tester, language: language, width: 320, scale: 1.5);
      expectAppFont(tester, family);
    });

    testWidgets('$language market tabs inherit the same font family', (
      tester,
    ) async {
      await pumpMarket(tester, language: language, width: 375);
      for (final tab in MarketTab.values) {
        await tester.tap(find.byKey(Key('market-tab-${tab.name}')));
        await tester.pumpAndSettle();
        expectAppFont(tester, family);
      }
    });
  }
}
