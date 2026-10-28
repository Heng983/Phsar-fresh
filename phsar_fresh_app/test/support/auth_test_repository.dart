import 'dart:async';
import 'dart:typed_data';

import 'package:phsar_fresh_app/features/auth/data/auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_repository.dart';

const testPhone = '+85512345678';
const testUser = AuthUser(id: 'test-account', phone: testPhone);
const testSession = AuthSession(user: testUser);

/// Only a UI test fixture. The application never creates local accounts.
class TestAuthRepository extends UnavailableAuthRepository {
  TestAuthRepository({AuthUser? user = testUser})
    : _session = user == null ? null : AuthSession(user: user);

  AuthSession? _session;
  final _changes = StreamController<AuthSession?>.broadcast(sync: true);
  bool failUpdates = false;

  @override
  bool get isAvailable => true;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthSession?> get sessionChanges => _changes.stream;

  void setUser(AuthUser? user) {
    _session = user == null ? null : AuthSession(user: user);
    _changes.add(_session);
  }

  void updateUser({
    String? name,
    String? avatarUrl,
    bool removeAvatar = false,
  }) {
    final user = currentSession!.user;
    setUser(
      AuthUser(
        id: user.id,
        displayName: name ?? user.displayName,
        phone: user.phone,
        email: user.email,
        pendingEmail: user.pendingEmail,
        avatarUrl: removeAvatar ? null : avatarUrl ?? user.avatarUrl,
        linkedProviders: user.linkedProviders,
      ),
    );
  }

  @override
  Future<void> updateDisplayName(String name) async {
    if (failUpdates) throw StateError('Test update rejected');
    updateUser(name: name.trim());
  }

  @override
  Future<void> signOut() async => setUser(null);

  Future<void> close() => _changes.close();
}

class TestProfilePhotoRepository implements ProfilePhotoRepository {
  TestProfilePhotoRepository(this.auth);

  final TestAuthRepository auth;
  Uint8List? savedPhoto;
  int saves = 0;
  int removals = 0;
  bool rejectUpload = false;

  @override
  Future<void> save(Uint8List jpeg, {required String displayName}) async {
    if (rejectUpload) throw StateError('Test upload rejected');
    savedPhoto = jpeg;
    saves++;
    auth.updateUser(
      name: displayName.trim(),
      avatarUrl: 'https://photos.example/saved.jpg',
    );
  }

  @override
  Future<void> remove({required String displayName}) async {
    removals++;
    auth.updateUser(name: displayName.trim(), removeAvatar: true);
  }
}
