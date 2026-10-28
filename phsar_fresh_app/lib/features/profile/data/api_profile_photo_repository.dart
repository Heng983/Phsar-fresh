import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:phsar_fresh_app/features/auth/data/api_auth_repository.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_repository.dart';

/// Uploads to `POST /users/me/avatar` (multipart field `file`) and removes with
/// `DELETE /users/me/avatar`. Both return the updated profile.
class ApiProfilePhotoRepository implements ProfilePhotoRepository {
  const ApiProfilePhotoRepository(this._auth);

  final ApiAuthRepository _auth;

  @override
  Future<void> save(Uint8List jpeg, {required String displayName}) =>
      _auth.applyProfileUpdate(
        (dio) => dio.post<dynamic>(
          '/users/me/avatar',
          data: FormData.fromMap({
            'file': MultipartFile.fromBytes(
              jpeg,
              filename: 'avatar.jpg',
              contentType: DioMediaType('image', 'jpeg'),
            ),
          }),
        ),
      );

  @override
  Future<void> remove({required String displayName}) => _auth
      .applyProfileUpdate((dio) => dio.delete<dynamic>('/users/me/avatar'));
}
