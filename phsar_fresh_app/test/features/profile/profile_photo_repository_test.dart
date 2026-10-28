import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_repository.dart';

void main() {
  test(
    'Disconnected photo storage never reports an upload or removal as saved',
    () async {
      const repository = UnavailableProfilePhotoRepository();
      final unavailable = isA<AuthFailure>().having(
        (error) => error.reason,
        'reason',
        AuthFailureReason.unavailable,
      );
      await expectLater(
        repository.save(
          Uint8List.fromList([0xff, 0xd8, 0xff]),
          displayName: 'Test',
        ),
        throwsA(unavailable),
      );
      await expectLater(
        repository.remove(displayName: 'Test'),
        throwsA(unavailable),
      );
    },
  );
}
