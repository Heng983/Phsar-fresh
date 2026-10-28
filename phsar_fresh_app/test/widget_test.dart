import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/app.dart';

void main() {
  for (final width in [320.0, 375.0, 800.0]) {
    testWidgets('Market opens and switches languages at width $width', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(width, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: PhsarFreshApp()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Get Started'));
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Phsar Fresh'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('market-guest-profile')));
      await tester.pumpAndSettle();
      final khmer = find.byKey(const Key('profile-language-km'));
      await tester.ensureVisible(khmer);
      await tester.pumpAndSettle();
      await tester.tap(khmer);
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('km'),
      );
      expect(find.text('សូមស្វាគមន៍ ភ្ញៀវ'), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('market-tab-categories')));
      await tester.pumpAndSettle();
      expect(find.text('ផ្សារស្រស់'), findsOneWidget);
      expect(find.text('Phsar Fresh'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('market-guest-profile')));
      await tester.pumpAndSettle();
      final english = find.byKey(const Key('profile-language-en'));
      await tester.ensureVisible(english);
      await tester.pumpAndSettle();
      await tester.tap(english);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('market-tab-categories')));
      await tester.pumpAndSettle();

      expect(find.text('Phsar Fresh'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
