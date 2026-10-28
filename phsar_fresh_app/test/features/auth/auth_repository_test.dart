import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/data/auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/account_contact.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';

import '../../support/auth_test_repository.dart';

void main() {
  const repository = UnavailableAuthRepository();
  final unavailable = isA<AuthFailure>().having(
    (error) => error.reason,
    'reason',
    AuthFailureReason.unavailable,
  );

  test('Default app has no authenticated or restored session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(authSessionProvider, (_, _) {});
    addTearDown(subscription.close);
    expect(container.read(authRepositoryProvider).isAvailable, isFalse);
    expect(await container.read(authSessionProvider.future), isNull);
    expect(repository.currentSession, isNull);
    expect(await repository.sessionChanges.toList(), isEmpty);
  });

  test('Disconnected account actions never report success', () async {
    for (final action in AuthAction.values) {
      await expectLater(
        repository.submit(
          AuthCredentials(
            action: action,
            phoneNumber: testPhone,
            secret: 'not-a-real-secret',
            rememberMe: true,
          ),
        ),
        throwsA(unavailable),
      );
    }
    for (final provider in SocialProvider.values) {
      await expectLater(
        repository.signInWithProvider(provider),
        throwsA(unavailable),
      );
      await expectLater(repository.linkAccount(provider), throwsA(unavailable));
    }
    await expectLater(repository.requestOtp(testPhone), throwsA(unavailable));
    await expectLater(
      repository.resendSignupOtp(testPhone),
      throwsA(unavailable),
    );
    await expectLater(
      repository.updateDisplayName('Test'),
      throwsA(unavailable),
    );
    await expectLater(
      repository.requestContactChange(AccountContact.email, 'test@example.com'),
      throwsA(unavailable),
    );
    await expectLater(
      repository.verifyPhoneChange(testPhone, '123456'),
      throwsA(unavailable),
    );
    await expectLater(
      repository.resendContactChange(AccountContact.phone, testPhone),
      throwsA(unavailable),
    );
    await expectLater(repository.refreshAccount(), throwsA(unavailable));
    await expectLater(repository.signOut(), throwsA(unavailable));
  });

  test(
    'A replacement repository supplies account changes without SDK types',
    () async {
      final replacement = TestAuthRepository();
      addTearDown(replacement.close);
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(replacement)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(authSessionProvider, (_, _) {});
      addTearDown(subscription.close);
      expect(
        (await container.read(authSessionProvider.future))!.user.phone,
        testPhone,
      );
      replacement.updateUser(name: 'Sophea');
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(authSessionProvider).value!.user.displayName,
        'Sophea',
      );
      await replacement.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authSessionProvider).value, isNull);
    },
  );
}
