enum AuthAction { signIn, register, verifyOtp }

/// Validated form input, ready to pass to an authentication service.
class AuthCredentials {
  final AuthAction action;
  final String phoneNumber;
  final String secret;
  final bool rememberMe;

  const AuthCredentials({
    required this.action,
    required this.phoneNumber,
    required this.secret,
    required this.rememberMe,
  });
}
