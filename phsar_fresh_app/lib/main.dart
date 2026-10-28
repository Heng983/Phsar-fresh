import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:phsar_fresh_app/app.dart';
import 'package:phsar_fresh_app/core/config/api_config.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/core/storage/app_settings_storage.dart';
import 'package:phsar_fresh_app/core/storage/token_storage.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/auth/data/api_auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/cart/data/cart_storage.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/api_catalog_repository.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/location/data/delivery_location_storage.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/notifications/data/notifications_repository.dart';
import 'package:phsar_fresh_app/features/profile/data/api_profile_photo_repository.dart';
import 'package:phsar_fresh_app/features/profile/presentation/providers/profile_photo_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.registerFontLicenses();

  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        appSettingsStorageProvider.overrideWithValue(
          AppSettingsStorage(preferences),
        ),
        cartStorageProvider.overrideWithValue(LocalCartStorage(preferences)),
        deliveryLocationStorageProvider.overrideWithValue(
          DeliveryLocationStorage(preferences),
        ),
        notificationSeenStorageProvider.overrideWithValue(
          NotificationSeenStorage(preferences),
        ),
        ...await _backendOverrides(),
      ],
      child: const PhsarFreshApp(),
    ),
  );
}

/// Connects the product catalog, accounts and profile photos to the backend
/// when `API_BASE_URL` is set. Without it the app runs as an offline preview.
Future<List<Override>> _backendOverrides() async {
  if (!ApiConfig.isConfigured) return const [];
  final tokens = TokenStorage();
  final client = ApiClient(tokens);
  final auth = ApiAuthRepository(client, tokens);
  await auth.restore();
  return [
    tokenStorageProvider.overrideWithValue(tokens),
    apiClientProvider.overrideWithValue(client),
    authRepositoryProvider.overrideWithValue(auth),
    catalogRepositoryProvider.overrideWithValue(ApiCatalogRepository(client)),
    profilePhotoRepositoryProvider.overrideWithValue(
      ApiProfilePhotoRepository(auth),
    ),
  ];
}
