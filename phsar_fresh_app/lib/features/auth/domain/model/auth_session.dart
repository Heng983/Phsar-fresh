enum SocialProvider { google, facebook, apple }

/// Account details used by the UI, independent of any backend SDK.
class AuthUser {
  const AuthUser({
    required this.id,
    this.displayName = '',
    this.phone,
    this.email,
    this.pendingEmail,
    this.avatarUrl,
    this.linkedProviders = const {},
  });

  final String id;
  final String displayName;
  final String? phone;
  final String? email;
  final String? pendingEmail;
  final String? avatarUrl;
  final Set<SocialProvider> linkedProviders;
}

class AuthSession {
  const AuthSession({required this.user});

  final AuthUser user;
}

class AuthResult {
  const AuthResult({this.session, this.user});

  final AuthSession? session;
  final AuthUser? user;
}
