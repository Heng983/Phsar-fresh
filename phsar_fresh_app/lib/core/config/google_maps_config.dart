import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const androidKey = String.fromEnvironment(
    'GOOGLE_MAPS_ANDROID_API_KEY',
  );
  static const iosKey = String.fromEnvironment('GOOGLE_MAPS_IOS_API_KEY');

  static bool get isConfigured {
    if (kIsWeb) return false;
    final key = switch (defaultTargetPlatform) {
      TargetPlatform.android => androidKey,
      TargetPlatform.iOS => iosKey,
      _ => '',
    };
    return key.trim().isNotEmpty && !key.startsWith('YOUR_');
  }
}

final googleMapsConfiguredProvider = Provider<bool>(
  (ref) => GoogleMapsConfig.isConfigured,
);
