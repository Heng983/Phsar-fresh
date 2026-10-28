import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/data/api_auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/fake_backend.dart';
import '../../support/pump_helpers.dart';

Future<FakeBackend> pumpBackendLogin(
  WidgetTester tester,
  FakeReply? Function(String path) reply,
) async {
  final backend = FakeBackend((r) => reply(r.path));
  final api = fakeApiClient(backend);
  setTestScreen(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          ApiAuthRepository(api.client, api.tokens),
        ),
      ],
      child: testApp(home: const LoginPage()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('auth-phone')), '012345678');
  await tester.enterText(find.byKey(const Key('auth-password')), 'password1');
  await submit(tester);
  return backend;
}

void main() {
  testWidgets('A wrong password shows a clear message from the backend', (
    tester,
  ) async {
    final backend = await pumpBackendLogin(
      tester,
      (_) => (401, {'message': 'Wrong phone number or password'}),
    );
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginPage)))!;
    expect(backend.calls, ['POST /auth/login']);
    expect(find.text(l10n.authInvalidCredentials), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('An unverified phone opens code verification and can resend', (
    tester,
  ) async {
    final backend = await pumpBackendLogin(
      tester,
      (path) => switch (path) {
        '/auth/login' => (403, {'message': 'Phone number is not verified'}),
        _ => (200, {'message': 'sent'}),
      },
    );
    expect(find.byType(OtpVerificationPage), findsOneWidget);
    final resend = find.byKey(const Key('auth-resend-code'));
    await tester.ensureVisible(resend);
    await tester.tap(resend);
    await tester.pumpAndSettle();
    expect(backend.calls, ['POST /auth/login', 'POST /auth/resend-otp']);
    expect(tester.takeException(), isNull);
  });
}
