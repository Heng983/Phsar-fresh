import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:phsar_fresh_app/features/profile/domain/model/avatar_image.dart';

enum ProfilePhotoSource { gallery, camera }

class ProfilePhotoPicker {
  final ImagePicker _picker = ImagePicker();

  Future<PreparedAvatar?> pick(ProfilePhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == ProfilePhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
      requestFullMetadata: false,
    );
    return file == null ? null : _prepare(file);
  }

  Future<PreparedAvatar?> recover() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    final response = await _picker.retrieveLostData();
    if (response.exception != null) throw response.exception!;
    final file = response.files?.firstOrNull;
    return file == null ? null : _prepare(file);
  }

  Future<PreparedAvatar> _prepare(XFile file) async {
    if (await file.length() > 10 * 1024 * 1024) {
      throw const FormatException('Image too large');
    }
    return compute(prepareAvatar, await file.readAsBytes());
  }
}

final profilePhotoPickerProvider = Provider<ProfilePhotoPicker>(
  (ref) => ProfilePhotoPicker(),
);
