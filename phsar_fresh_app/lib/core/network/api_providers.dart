import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/config/api_config.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/core/storage/token_storage.dart';

/// One token store and one HTTP client shared by every feature, so a token
/// refresh made by one request is seen by all of them.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Null when `API_BASE_URL` is not configured.
final apiClientProvider = Provider<ApiClient?>((ref) {
  if (!ApiConfig.isConfigured) return null;
  final client = ApiClient(ref.watch(tokenStorageProvider));
  ref.onDispose(client.close);
  return client;
});
