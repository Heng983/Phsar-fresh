import 'package:phsar_fresh_app/features/auth/domain/model/account_contact.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';

/// Implement this interface and override authRepositoryProvider for a backend.
abstract interface class AuthRepository {
  bool get isAvailable;
  AuthSession? get currentSession;
  Stream<AuthSession?> get sessionChanges;

  Future<AuthResult> submit(AuthCredentials credentials);
  Future<void> requestOtp(String phone, {bool shouldCreateUser = false});
  Future<void> resendSignupOtp(String phone);
  Future<void> updateDisplayName(String name);
  Future<void> requestContactChange(AccountContact contact, String value);
  Future<bool> verifyPhoneChange(String phone, String code);
  Future<void> resendContactChange(AccountContact contact, String value);
  Future<void> refreshAccount();
  Future<bool> linkAccount(SocialProvider provider);
  Future<bool> signInWithProvider(
    SocialProvider provider, {
    bool rememberMe = true,
  });
  Future<void> signOut();
}

/// No accounts, persistence, network requests, or browser launches are performed.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  bool get isAvailable => false;

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthSession?> get sessionChanges => const Stream.empty();

  Future<T> _unavailable<T>() =>
      Future.error(const AuthFailure(AuthFailureReason.unavailable));

  @override
  Future<AuthResult> submit(AuthCredentials credentials) => _unavailable();

  @override
  Future<void> requestOtp(String phone, {bool shouldCreateUser = false}) =>
      _unavailable();

  @override
  Future<void> resendSignupOtp(String phone) => _unavailable();

  @override
  Future<void> updateDisplayName(String name) => _unavailable();

  @override
  Future<void> requestContactChange(AccountContact contact, String value) =>
      _unavailable();

  @override
  Future<bool> verifyPhoneChange(String phone, String code) => _unavailable();

  @override
  Future<void> resendContactChange(AccountContact contact, String value) =>
      _unavailable();

  @override
  Future<void> refreshAccount() => _unavailable();

  @override
  Future<bool> linkAccount(SocialProvider provider) => _unavailable();

  @override
  Future<bool> signInWithProvider(
    SocialProvider provider, {
    bool rememberMe = true,
  }) => _unavailable();

  @override
  Future<void> signOut() => _unavailable();
}
