import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';

import '../../support/auth_test_repository.dart';
import '../../support/pump_helpers.dart';

Future<void> openContact(WidgetTester tester, String contact) async {
  await revealAndTap(tester, find.byKey(const Key('profile-edit')));
  await revealAndTap(tester, find.byKey(Key('profile-change-$contact')));
}

void main() {
  late TestAuthRepository repository;
  setUp(() => repository = TestAuthRepository());
  tearDown(() => repository.close());

  for (final contact in ['phone', 'email']) {
    testWidgets('Unavailable $contact updates preserve the account and input', (
      tester,
    ) async {
      await pumpAccount(tester, repository);
      await openContact(tester, contact);
      final input = find.byKey(Key('profile-$contact-input'));
      final value = contact == 'phone' ? '098765432' : 'sophea@example.com';
      await tester.enterText(input, value);
      await revealAndTap(tester, find.byKey(const Key('profile-contact-send')));
      expect(find.byKey(const Key('profile-contact-error')), findsOneWidget);
      expect(find.byKey(const Key('profile-contact-success')), findsNothing);
      expect(tester.widget<TextFormField>(input).controller!.text, value);
      expect(repository.currentSession!.user.phone, testPhone);
      expect(repository.currentSession!.user.email, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Unavailable provider linking never shows a connected account', (
    tester,
  ) async {
    await pumpAccount(tester, repository);
    await revealAndTap(tester, find.byKey(const Key('profile-edit')));
    await revealAndTap(tester, find.byKey(const Key('profile-link-google')));
    expect(find.byKey(const Key('profile-link-error')), findsOneWidget);
    expect(find.byKey(const Key('profile-link-pending')), findsNothing);
    expect(repository.currentSession!.user.linkedProviders, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Linked status comes from the backend independent account model',
    (tester) async {
      repository.setUser(
        const AuthUser(
          id: 'test-account',
          phone: testPhone,
          linkedProviders: {SocialProvider.google},
        ),
      );
      await pumpAccount(tester, repository);
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await tester.ensureVisible(
        find.byKey(const Key('profile-link-status-google')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const Key('profile-link-status-google')))
            .data,
        'Connected',
      );
      expect(find.byKey(const Key('profile-link-google')), findsNothing);
      expect(find.byKey(const Key('profile-link-facebook')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['en', 'km']) {
    testWidgets('Account editor fits $language at 320px with larger text', (
      tester,
    ) async {
      await pumpAccount(
        tester,
        repository,
        language: language,
        width: 320,
        scale: 1.5,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      for (final key in [
        'profile-change-phone',
        'profile-change-email',
        'profile-link-facebook',
        'profile-save',
      ]) {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: key);
      }
    });
  }
}
