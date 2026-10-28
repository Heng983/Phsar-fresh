import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/pump_helpers.dart';

void main() {
  for (final language in ['en', 'km']) {
    for (final width in [320.0, 375.0, 696.0]) {
      testWidgets('Login fits $language at width $width', (tester) async {
        await pumpLogin(tester, width: width, language: language);
        expect(find.byKey(const Key('auth-phone')), findsOneWidget);
        expect(find.byKey(const Key('auth-password')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(language == 'en' ? 'Register' : 'ចុះឈ្មោះ'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('auth-confirm-password')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Password visibility, Remember me and validated submission', (
    tester,
  ) async {
    AuthCredentials? credentials;
    await pumpLogin(
      tester,
      page: LoginPage(onSubmit: (value) => credentials = value),
    );
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    final password = find.byKey(const Key('auth-password'));
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: password, matching: find.byType(EditableText)),
          )
          .obscureText,
      isFalse,
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await submit(tester);
    expect(find.text('Enter a valid Cambodian mobile number.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(credentials, isNull);

    await tester.ensureVisible(find.byKey(const Key('auth-phone')));
    await tester.enterText(find.byKey(const Key('auth-phone')), '012 345 678');
    await tester.enterText(password, 'my-password');
    await submit(tester);
    expect(credentials?.phoneNumber, '+85512345678');
    expect(credentials?.action, AuthAction.signIn);
    expect(credentials?.rememberMe, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Register checks password confirmation', (tester) async {
    AuthCredentials? credentials;
    await pumpLogin(
      tester,
      page: LoginPage(
        initiallyRegister: true,
        onSubmit: (value) => credentials = value,
      ),
    );
    await tester.enterText(find.byKey(const Key('auth-phone')), '012345678');
    await tester.enterText(
      find.byKey(const Key('auth-password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('auth-confirm-password')),
      'different',
    );
    await submit(tester);
    expect(find.text('The passwords do not match.'), findsOneWidget);
    expect(credentials, isNull);
    await tester.ensureVisible(find.byKey(const Key('auth-confirm-password')));
    await tester.enterText(
      find.byKey(const Key('auth-confirm-password')),
      'password123',
    );
    await submit(tester);
    expect(credentials?.action, AuthAction.register);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OTP mode requests a code and validates six digits', (
    tester,
  ) async {
    AuthCredentials? credentials;
    String? requestedPhone;
    await pumpLogin(
      tester,
      page: LoginPage(
        onSubmit: (value) => credentials = value,
        onRequestOtp: (phone) => requestedPhone = phone,
      ),
    );
    await tester.enterText(find.byKey(const Key('auth-phone')), '012345678');
    await tester.tap(find.text('Use OTP'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth-password')), findsNothing);
    await tester.ensureVisible(find.text('Send code'));
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(requestedPhone, '+85512345678');
    await submit(tester);
    expect(find.text('Enter a 6-digit verification code.'), findsOneWidget);
    expect(credentials, isNull);
    await tester.ensureVisible(find.byKey(const Key('auth-otp')));
    await tester.enterText(find.byKey(const Key('auth-otp')), '123456');
    await submit(tester);
    expect(credentials?.action, AuthAction.verifyOtp);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login handles larger text and the keyboard', (tester) async {
    await pumpLogin(tester, width: 320, textScale: 1.4);
    expect(tester.takeException(), isNull);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('auth-phone')));
    await tester.tap(find.byKey(const Key('auth-phone')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('auth-submit')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Onboarding opens sign-in and explore', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const OnboardingPage(),
          routes: {
            AppRoutes.login: (_) => const LoginPage(),
            AppRoutes.register: (_) => const LoginPage(initiallyRegister: true),
            AppRoutes.explore: (_) => const MarketPage(initiallyExplore: true),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byKey(const Key('auth-confirm-password')), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(MarketPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
