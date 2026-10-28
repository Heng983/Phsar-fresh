import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/presentation/utils/auth_error_messages.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations_en.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations_km.dart';

void main() {
  for (final l10n in <AppLocalizations>[
    AppLocalizationsEn(),
    AppLocalizationsKm(),
  ]) {
    test(
      'Account errors use localized app messages for ${l10n.localeName}',
      () {
        String message(Object error) =>
            AuthErrorMessages.forError(error, l10n, StackTrace.current);
        expect(
          message(const AuthFailure(AuthFailureReason.unavailable)),
          l10n.authUnavailable,
        );
        expect(
          message(const AuthFailure(AuthFailureReason.connection)),
          l10n.authConnectionError,
        );
        expect(
          message(const AuthFailure(AuthFailureReason.phoneNotConfirmed)),
          l10n.authPhoneConfirmationRequired,
        );
        expect(
          message(StateError('Internal implementation details')),
          l10n.authUnexpectedError,
        );
      },
    );
  }
}
