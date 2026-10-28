import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/pump_helpers.dart';

void main() {
  for (final registering in [false, true]) {
    testWidgets(
      'Disconnected ${registering ? 'registration' : 'sign in'} keeps the form and shows availability',
      (tester) async {
        await pumpLogin(
          tester,
          page: LoginPage(initiallyRegister: registering),
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(LoginPage)),
        )!;
        expect(find.text(l10n.authServicesPaused), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('auth-phone')),
          '012345678',
        );
        await tester.enterText(
          find.byKey(const Key('auth-password')),
          'test-password',
        );
        if (registering) {
          await tester.enterText(
            find.byKey(const Key('auth-confirm-password')),
            'test-password',
          );
        }
        await submit(tester);
        expect(find.byKey(const Key('auth-error')), findsOneWidget);
        expect(find.text(l10n.authUnavailable), findsOneWidget);
        expect(find.byType(OtpVerificationPage), findsNothing);
        expect(find.byType(LoginPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Disconnected OTP requests do not claim a message was sent', (
    tester,
  ) async {
    await pumpLogin(tester);
    await tester.ensureVisible(find.text('Use OTP'));
    await tester.tap(find.text('Use OTP'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth-phone')), '012345678');
    await tester.ensureVisible(find.text('Send code'));
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginPage)))!;
    expect(find.text(l10n.authUnavailable), findsOneWidget);
    expect(find.text(l10n.authCodeSent('+85512345678')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
