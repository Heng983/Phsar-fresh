import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

class AuthErrorMessages {
  AuthErrorMessages._();

  static String forError(
    Object error,
    AppLocalizations l10n,
    StackTrace stack,
  ) => error is AuthFailure
      ? switch (error.reason) {
          AuthFailureReason.unavailable => l10n.authUnavailable,
          AuthFailureReason.connection => l10n.authConnectionError,
          AuthFailureReason.phoneNotConfirmed =>
            l10n.authPhoneConfirmationRequired,
          AuthFailureReason.identityInUse => l10n.profileIdentityInUse,
          AuthFailureReason.invalidCredentials => l10n.authInvalidCredentials,
          AuthFailureReason.invalidCode => l10n.authInvalidCode,
          AuthFailureReason.phoneInUse => l10n.authPhoneInUse,
          AuthFailureReason.tooManyAttempts => l10n.authTooManyAttempts,
          AuthFailureReason.rejected => l10n.authServiceError,
        }
      : l10n.authUnexpectedError;
}
