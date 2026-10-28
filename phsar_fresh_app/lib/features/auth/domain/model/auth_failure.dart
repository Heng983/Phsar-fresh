enum AuthFailureReason {
  unavailable,
  connection,
  phoneNotConfirmed,
  identityInUse,
  invalidCredentials,
  invalidCode,
  phoneInUse,
  tooManyAttempts,
  rejected,
}

class AuthFailure implements Exception {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;

  @override
  String toString() => 'AuthFailure(${reason.name})';
}
