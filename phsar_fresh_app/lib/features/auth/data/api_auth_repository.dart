import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/core/storage/token_storage.dart';
import 'package:phsar_fresh_app/features/auth/data/auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/account_contact.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';

/// Phone + password accounts on the Phsar Fresh backend (`/auth`, `/users`).
///
/// Sign-up: register → SMS code → verify-otp → signed in.
/// The backend has no passwordless OTP login, password reset, contact change
/// or social sign-in yet, so those actions report [AuthFailureReason.unavailable].
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client, this._tokens) {
    _client.onSessionExpired = _expire;
  }

  final ApiClient _client;
  final TokenStorage _tokens;
  final _changes = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  Dio get _dio => _client.dio;

  /// Shows the saved session immediately (works offline), then refreshes the
  /// profile from the server in the background.
  Future<void> restore() async {
    if (await _tokens.refresh == null) return;
    final saved = await _tokens.user;
    if (saved != null) {
      try {
        _session = AuthSession(user: _userFrom(jsonDecode(saved)));
      } on Object {
        // An unreadable profile is replaced by the refresh below.
      }
    }
    unawaited(refreshAccount().catchError((Object _) {}));
  }

  @override
  bool get isAvailable => true;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthSession?> get sessionChanges => _changes.stream;

  @override
  Future<AuthResult> submit(AuthCredentials credentials) {
    final phone = credentials.phoneNumber;
    return switch (credentials.action) {
      AuthAction.signIn => _guard(
        () async => _startSession(
          await _post('/auth/login', {
            'phone': phone,
            'password': credentials.secret,
          }),
          remember: credentials.rememberMe,
        ),
        {
          401: AuthFailureReason.invalidCredentials,
          403: AuthFailureReason.phoneNotConfirmed,
        },
      ),
      AuthAction.register => _guard(() async {
        await _post('/auth/register', {
          'phone': phone,
          'password': credentials.secret,
        });
        // The SMS code is on its way; the page asks for it next.
        return AuthResult(
          user: AuthUser(id: '', phone: phone),
        );
      }, {409: AuthFailureReason.phoneInUse}),
      AuthAction.verifyOtp => _guard(
        () async => _startSession(
          await _post('/auth/verify-otp', {
            'phone': phone,
            'code': credentials.secret,
          }),
          remember: credentials.rememberMe,
        ),
        {
          400: AuthFailureReason.invalidCode,
          401: AuthFailureReason.invalidCode,
        },
      ),
    };
  }

  @override
  Future<void> resendSignupOtp(String phone) =>
      _guard(() => _post('/auth/resend-otp', {'phone': phone}));

  @override
  Future<void> updateDisplayName(String name) => applyProfileUpdate(
    (dio) => dio.patch<dynamic>('/users/me', data: {'name': name.trim()}),
  );

  @override
  Future<void> refreshAccount() async {
    if (await _tokens.refresh == null) return;
    await applyProfileUpdate((dio) => dio.get<dynamic>('/auth/me'));
  }

  /// Runs an authenticated request that returns the user's profile and
  /// publishes the updated session. Used for name and photo changes.
  Future<void> applyProfileUpdate(
    Future<Response<dynamic>> Function(Dio dio) request,
  ) => _guard(() async {
    final response = await request(_dio);
    await _setUser(_json(response.data));
  });

  @override
  Future<void> signOut() async {
    final refresh = await _tokens.refresh;
    if (refresh != null) {
      try {
        await _dio.post<dynamic>(
          '/auth/logout',
          data: {'refreshToken': refresh},
          options: ApiClient.noAuth.copyWith(
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
      } on Object {
        // Signing out on this device must work even when offline.
      }
    }
    await _tokens.clear();
    _publish(null);
  }

  // Not supported by the backend yet.
  @override
  Future<void> requestOtp(String phone, {bool shouldCreateUser = false}) =>
      _unavailable();

  @override
  Future<void> requestContactChange(AccountContact contact, String value) =>
      _unavailable();

  @override
  Future<bool> verifyPhoneChange(String phone, String code) => _unavailable();

  @override
  Future<void> resendContactChange(AccountContact contact, String value) =>
      _unavailable();

  @override
  Future<bool> linkAccount(SocialProvider provider) => _unavailable();

  @override
  Future<bool> signInWithProvider(
    SocialProvider provider, {
    bool rememberMe = true,
  }) => _unavailable();

  // ---------------------------------------------------------------- helpers

  Future<T> _unavailable<T>() =>
      Future.error(const AuthFailure(AuthFailureReason.unavailable));

  Future<Map<String, dynamic>> _post(String path, Map<String, Object?> data) =>
      _dio
          .post<dynamic>(path, data: data, options: ApiClient.noAuth)
          .then((response) => _json(response.data));

  Future<AuthResult> _startSession(
    Map<String, dynamic> data, {
    required bool remember,
  }) async {
    final access = data['accessToken'];
    final refresh = data['refreshToken'];
    if (access is! String || refresh is! String) {
      throw const FormatException('Missing tokens');
    }
    await _tokens.save(access: access, refresh: refresh, persist: remember);
    final user = await _setUser(_json(data['user']));
    return AuthResult(session: _session, user: user);
  }

  Future<AuthUser> _setUser(Map<String, dynamic> json) async {
    final user = _userFrom(json);
    await _tokens.saveUser(jsonEncode(json));
    _publish(AuthSession(user: user));
    return user;
  }

  AuthUser _userFrom(Object? value) {
    final json = _json(value);
    final id = json['id'];
    final name = json['name'];
    final phone = json['phone'];
    final avatar = json['avatarUrl'];
    if (id is! String || id.isEmpty) throw const FormatException('No user id');
    return AuthUser(
      id: id,
      displayName: name is String ? name : '',
      phone: phone is String ? phone : null,
      avatarUrl: _client.resolveUrl(avatar is String ? avatar : null),
    );
  }

  Map<String, dynamic> _json(Object? value) {
    final data = value is String ? jsonDecode(value) : value;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response');
    }
    return data;
  }

  /// Called by [ApiClient] when the server rejects the refresh token.
  void _expire() => _publish(null);

  void _publish(AuthSession? session) {
    _session = session;
    _changes.add(session);
  }

  /// Converts transport and HTTP errors into [AuthFailure]s the UI can show.
  Future<T> _guard<T>(
    Future<T> Function() run, [
    Map<int, AuthFailureReason> byStatus = const {},
  ]) async {
    try {
      return await run();
    } on AuthFailure {
      rethrow;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final reason =
          byStatus[status] ??
          switch ((error.type, status)) {
            (_, 429) => AuthFailureReason.tooManyAttempts,
            (
              DioExceptionType.connectionTimeout ||
                  DioExceptionType.sendTimeout ||
                  DioExceptionType.receiveTimeout ||
                  DioExceptionType.connectionError,
              _,
            ) =>
              AuthFailureReason.connection,
            _ => AuthFailureReason.rejected,
          };
      throw AuthFailure(reason);
    } on FormatException {
      throw const AuthFailure(AuthFailureReason.rejected);
    }
  }
}
