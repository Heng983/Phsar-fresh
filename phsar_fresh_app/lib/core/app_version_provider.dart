import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The installed app's version from pubspec.yaml (e.g. "1.0.1"), or null
/// where the platform can't tell (widget tests, previews).
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version.isEmpty ? null : info.version;
  } catch (error) {
    if (kDebugMode) debugPrint('App version unavailable: ${error.runtimeType}');
    return null;
  }
});
