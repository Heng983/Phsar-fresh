import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/data/api_auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/profile/data/api_profile_photo_repository.dart';

import '../../support/fake_backend.dart';

AuthCredentials credentials(
  AuthAction action, {
  String secret = 'password123',
  bool remember = true,
}) => AuthCredentials(
  action: action,
  phoneNumber: '+85512345678',
  secret: secret,
  rememberMe: remember,
);

Matcher failsWith(AuthFailureReason reason) => throwsA(
  isA<AuthFailure>().having((failure) => failure.reason, 'reason', reason),
);

void main() {
  test('Signing in stores tokens and publishes the session', () async {
    final backend = FakeBackend(
      (r) => (
        200,
        {
          ...tokenReply(),
          'user': backendUser(avatarUrl: '/uploads/avatars/a.jpg'),
        },
      ),
    );
    final api = fakeApiClient(backend);
    final auth = ApiAuthRepository(api.client, api.tokens);
    final sessions = <AuthSession?>[];
    auth.sessionChanges.listen(sessions.add);

    final result = await auth.submit(credentials(AuthAction.signIn));

    expect(backend.calls, ['POST /auth/login']);
    expect(backend.requests.single.data, {
      'phone': '+85512345678',
      'password': 'password123',
    });
    // Sign-in must not send a stale token or trigger a refresh on 401.
    expect(backend.requests.single.headers['Authorization'], isNull);
    final user = result.session!.user;
    expect(user.id, 'user-1');
    expect(user.displayName, 'Sok Dara');
    expect(user.avatarUrl, 'http://api.test:3000/uploads/avatars/a.jpg');
    expect(auth.currentSession?.user.id, 'user-1');
    expect(await api.tokens.access, 'access-1');
    expect(await api.tokens.refresh, 'refresh-1');
    await pumpEventQueue();
    expect(sessions.single?.user.id, 'user-1');
  });

  test('Login errors map to clear reasons', () async {
    for (final (status, reason) in [
      (401, AuthFailureReason.invalidCredentials),
      (403, AuthFailureReason.phoneNotConfirmed),
      (429, AuthFailureReason.tooManyAttempts),
      (500, AuthFailureReason.rejected),
    ]) {
      final api = fakeApiClient(
        FakeBackend((_) => (status, {'message': 'error'})),
      );
      final auth = ApiAuthRepository(api.client, api.tokens);
      await expectLater(
        auth.submit(credentials(AuthAction.signIn)),
        failsWith(reason),
      );
      expect(auth.currentSession, isNull);
    }
    final offline = fakeApiClient(FakeBackend((_) => null));
    await expectLater(
      ApiAuthRepository(
        offline.client,
        offline.tokens,
      ).submit(credentials(AuthAction.signIn)),
      failsWith(AuthFailureReason.connection),
    );
  });

  test('Registration sends a code, then verify-otp signs in', () async {
    final backend = FakeBackend(
      (r) => switch (r.path) {
        '/auth/register' => (201, {'message': 'Verification code sent'}),
        '/auth/resend-otp' => (200, {'message': 'sent'}),
        '/auth/verify-otp' when (r.data as Map)['code'] == '000000' => (
          400,
          {'message': 'Invalid code'},
        ),
        '/auth/verify-otp' => (200, tokenReply()),
        _ => (404, null),
      },
    );
    final api = fakeApiClient(backend);
    final auth = ApiAuthRepository(api.client, api.tokens);

    final registered = await auth.submit(credentials(AuthAction.register));
    expect(registered.session, isNull);
    expect(registered.user?.phone, '+85512345678');

    await auth.resendSignupOtp('+85512345678');
    await expectLater(
      auth.submit(credentials(AuthAction.verifyOtp, secret: '000000')),
      failsWith(AuthFailureReason.invalidCode),
    );
    final verified = await auth.submit(
      credentials(AuthAction.verifyOtp, secret: '123456'),
    );
    expect(verified.session?.user.id, 'user-1');
    expect(backend.requests.last.data, {
      'phone': '+85512345678',
      'code': '123456',
    });
    expect(backend.calls, [
      'POST /auth/register',
      'POST /auth/resend-otp',
      'POST /auth/verify-otp',
      'POST /auth/verify-otp',
    ]);
  });

  test('An already registered phone number is reported', () async {
    final api = fakeApiClient(FakeBackend((_) => (409, {'message': 'taken'})));
    await expectLater(
      ApiAuthRepository(
        api.client,
        api.tokens,
      ).submit(credentials(AuthAction.register)),
      failsWith(AuthFailureReason.phoneInUse),
    );
  });

  test(
    'An expired access token is refreshed once and the request retried',
    () async {
      final backend = FakeBackend((r) {
        final token = r.headers['Authorization'];
        return switch (r.path) {
          '/auth/refresh' => (
            200,
            tokenReply(access: 'access-2', refresh: 'refresh-2'),
          ),
          '/auth/me' when token == 'Bearer access-2' => (
            200,
            backendUser(name: 'Updated'),
          ),
          '/auth/me' => (401, {'message': 'Unauthorized'}),
          _ => (200, tokenReply()),
        };
      });
      final api = fakeApiClient(backend);
      final auth = ApiAuthRepository(api.client, api.tokens);
      await auth.submit(credentials(AuthAction.signIn));

      await auth.refreshAccount();

      expect(backend.calls, [
        'POST /auth/login',
        'GET /auth/me',
        'POST /auth/refresh',
        'GET /auth/me',
      ]);
      expect(backend.requests[2].data, {'refreshToken': 'refresh-1'});
      expect(auth.currentSession?.user.displayName, 'Updated');
      expect(await api.tokens.refresh, 'refresh-2');
    },
  );

  test('A rejected refresh token signs the user out', () async {
    final backend = FakeBackend(
      (r) => switch (r.path) {
        '/auth/login' => (200, tokenReply()),
        _ => (401, {'message': 'Invalid refresh token'}),
      },
    );
    final api = fakeApiClient(backend);
    final auth = ApiAuthRepository(api.client, api.tokens);
    await auth.submit(credentials(AuthAction.signIn));
    final sessions = <AuthSession?>[];
    auth.sessionChanges.listen(sessions.add);

    await expectLater(auth.refreshAccount(), throwsA(isA<AuthFailure>()));
    await pumpEventQueue();

    expect(auth.currentSession, isNull);
    expect(sessions.last, isNull);
    expect(await api.tokens.refresh, isNull);
  });

  test(
    'A saved session appears immediately and refreshes in the background',
    () async {
      final backend = FakeBackend(
        (_) => (200, backendUser(name: 'From server')),
      );
      final api = fakeApiClient(backend);
      await api.tokens.save(access: 'a', refresh: 'r');
      await api.tokens.saveUser(jsonEncode(backendUser(name: 'Saved')));
      final auth = ApiAuthRepository(api.client, api.tokens);

      await auth.restore();
      expect(auth.currentSession?.user.displayName, 'Saved');

      await pumpEventQueue();
      expect(backend.calls, ['GET /auth/me']);
      expect(auth.currentSession?.user.displayName, 'From server');
    },
  );

  test('Restoring without saved tokens stays signed out and offline', () async {
    final backend = FakeBackend((_) => (200, backendUser()));
    final api = fakeApiClient(backend);
    final auth = ApiAuthRepository(api.client, api.tokens);
    await auth.restore();
    await pumpEventQueue();
    expect(auth.currentSession, isNull);
    expect(backend.calls, isEmpty);
  });

  test('Sign out revokes the refresh token, and works offline', () async {
    var online = true;
    final backend = FakeBackend((r) => online ? (200, tokenReply()) : null);
    final api = fakeApiClient(backend);
    final auth = ApiAuthRepository(api.client, api.tokens);
    await auth.submit(credentials(AuthAction.signIn));
    await auth.signOut();
    expect(backend.calls.last, 'POST /auth/logout');
    expect(backend.requests.last.data, {'refreshToken': 'refresh-1'});
    expect(auth.currentSession, isNull);
    expect(await api.tokens.access, isNull);

    await auth.submit(credentials(AuthAction.signIn));
    online = false;
    await auth.signOut();
    expect(auth.currentSession, isNull);
    expect(await api.tokens.refresh, isNull);
  });

  test('Name and photo changes update the session profile', () async {
    final backend = FakeBackend(
      (r) => switch ((r.method, r.path)) {
        ('PATCH', '/users/me') => (
          200,
          backendUser(name: (r.data as Map)['name'] as String),
        ),
        ('POST', '/users/me/avatar') => (
          201,
          backendUser(avatarUrl: '/uploads/avatars/new.jpg'),
        ),
        ('DELETE', '/users/me/avatar') => (200, backendUser()),
        _ => (200, tokenReply()),
      },
    );
    final api = fakeApiClient(backend);
    final auth = ApiAuthRepository(api.client, api.tokens);
    final photos = ApiProfilePhotoRepository(auth);
    await auth.submit(credentials(AuthAction.signIn));

    await auth.updateDisplayName('  Dara  ');
    expect(backend.requests.last.data, {'name': 'Dara'});
    expect(auth.currentSession?.user.displayName, 'Dara');

    await photos.save(Uint8List.fromList([1, 2, 3]), displayName: 'Dara');
    final upload = backend.requests.last;
    expect(upload.headers['Authorization'], 'Bearer access-1');
    final file = (upload.data as FormData).files.single;
    expect(file.key, 'file');
    expect(file.value.contentType.toString(), 'image/jpeg');
    expect(
      auth.currentSession?.user.avatarUrl,
      'http://api.test:3000/uploads/avatars/new.jpg',
    );

    await photos.remove(displayName: 'Dara');
    expect(backend.calls.last, 'DELETE /users/me/avatar');
    expect(auth.currentSession?.user.avatarUrl, isNull);
  });

  test(
    'Features the backend lacks report unavailable instead of hanging',
    () async {
      final backend = FakeBackend((_) => (200, {}));
      final api = fakeApiClient(backend);
      final auth = ApiAuthRepository(api.client, api.tokens);
      await expectLater(
        auth.requestOtp('+85512345678'),
        failsWith(AuthFailureReason.unavailable),
      );
      await expectLater(
        auth.signInWithProvider(SocialProvider.google),
        failsWith(AuthFailureReason.unavailable),
      );
      expect(backend.calls, isEmpty);
    },
  );
}
