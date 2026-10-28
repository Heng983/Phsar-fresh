import 'dart:typed_data';

import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';

/// A replacement backend can implement uploads without coupling the editor to it.
abstract interface class ProfilePhotoRepository {
  Future<void> save(Uint8List jpeg, {required String displayName});
  Future<void> remove({required String displayName});
}

class UnavailableProfilePhotoRepository implements ProfilePhotoRepository {
  const UnavailableProfilePhotoRepository();

  @override
  Future<void> save(Uint8List jpeg, {required String displayName}) =>
      Future.error(const AuthFailure(AuthFailureReason.unavailable));

  @override
  Future<void> remove({required String displayName}) =>
      Future.error(const AuthFailure(AuthFailureReason.unavailable));
}
