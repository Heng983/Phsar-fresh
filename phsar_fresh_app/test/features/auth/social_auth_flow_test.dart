import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';
import '../../support/pump_helpers.dart';

void main() {
  for (final language in ['en', 'km']) {
    for (final provider in SocialProvider.values) {
      testWidgets(
        'Unavailable ${provider.name} login stays on $language sign in',
        (tester) async {
          await pumpLogin(tester, language: language);
          final button = find.byWidgetPredicate(
            (widget) =>
                widget is SocialSignInButton && widget.provider == provider,
          );
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          await tester.tap(button);
          await tester.pumpAndSettle();
          final l10n = AppLocalizations.of(
            tester.element(find.byType(LoginPage)),
          )!;
          expect(find.text(l10n.authUnavailable), findsOneWidget);
          expect(find.byType(MarketPage), findsNothing);
          expect(find.byType(LoginPage), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
