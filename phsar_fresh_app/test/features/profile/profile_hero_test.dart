import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_components.dart';

import '../../support/pump_helpers.dart';

void main() {
  test('Cambodian numbers are spaced like the sign-in hint', () {
    expect(formatPhoneForDisplay('+85512567802'), '+855 12 567 802');
    expect(formatPhoneForDisplay('85512567802'), '+855 12 567 802');
    expect(formatPhoneForDisplay('+855969123456'), '+855 96 912 3456');
    expect(formatPhoneForDisplay('+14155550123'), '+14155550123');
  });

  for (final language in ['en', 'km']) {
    testWidgets('The name sits beside the photo in $language', (tester) async {
      setTestScreen(tester, width: 390);
      await tester.pumpWidget(
        ProviderScope(
          child: testApp(
            language: language,
            home: Builder(
              // The real app's Khmer minimum font size, which once made the
              // card think the text was very large and stack vertically.
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MinimumFontSizeTextScaler(
                    MediaQuery.textScalerOf(context),
                  ),
                ),
                child: Scaffold(
                  body: ProfileHero(
                    name: 'ViChet',
                    subtitle: formatPhoneForDisplay('+85512567802'),
                    badge: 'Supporting local, together',
                    editLabel: 'Edit',
                    initial: 'V',
                    onEdit: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final photo = tester.getRect(find.byType(ProfileAvatar));
      final name = tester.getRect(find.byKey(const Key('profile-name')));
      expect(name.left, greaterThan(photo.right));
      expect(name.top, lessThan(photo.bottom));
      expect(find.byKey(const Key('profile-edit')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
