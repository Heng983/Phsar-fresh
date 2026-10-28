import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the signed-in session's tokens and last known user profile.
///
/// Values are cached in memory. They are also written to the device's secure
/// storage only when the user chose "Remember me", so an unremembered session
/// ends when the app closes.
class TokenStorage {
  TokenStorage() : _secure = const FlutterSecureStorage();

  /// Never touches the device; for tests and previews.
  TokenStorage.memory() : _secure = null;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage? _secure;
  String? _access;
  String? _refresh;
  String? _user;
  bool _persist = true;
  bool _loaded = false;

  Future<String?> get access async => (await _load())._access;
  Future<String?> get refresh async => (await _load())._refresh;

  /// The last profile returned by the server, as JSON.
  Future<String?> get user async => (await _load())._user;

  /// Saves new tokens. [persist] defaults to the current session's choice,
  /// so a token refresh keeps the user's "Remember me" setting.
  Future<void> save({
    required String access,
    required String refresh,
    bool? persist,
  }) async {
    await _load();
    _persist = persist ?? _persist;
    _access = access;
    _refresh = refresh;
    if (_persist) {
      await _secure?.write(key: _accessKey, value: access);
      await _secure?.write(key: _refreshKey, value: refresh);
    } else {
      await _deleteSaved();
    }
  }

  Future<void> saveUser(String json) async {
    await _load();
    _user = json;
    if (_persist) await _secure?.write(key: _userKey, value: json);
  }

  Future<void> clear() async {
    _loaded = true;
    _access = _refresh = _user = null;
    await _deleteSaved();
  }

  Future<TokenStorage> _load() async {
    if (_loaded) return this;
    _loaded = true;
    final secure = _secure;
    if (secure == null) return this;
    try {
      _access = await secure.read(key: _accessKey);
      _refresh = await secure.read(key: _refreshKey);
      _user = await secure.read(key: _userKey);
    } catch (_) {
      // Unreadable storage (e.g. restored backup on a new device) = signed out.
      _access = _refresh = _user = null;
    }
    return this;
  }

  Future<void> _deleteSaved() async {
    await _secure?.delete(key: _accessKey);
    await _secure?.delete(key: _refreshKey);
    await _secure?.delete(key: _userKey);
  }
}
