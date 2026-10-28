import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_repository.dart';

final profilePhotoRepositoryProvider = Provider<ProfilePhotoRepository>(
  (ref) => const UnavailableProfilePhotoRepository(),
);

final profilePhotoUrlProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final url = ref.watch(authSessionProvider).value?.user.avatarUrl;
  final uri = url == null ? null : Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme == 'https') return url;
  // Plain http is only trusted for photos served by our own API (local dev).
  final api = ref.watch(apiClientProvider)?.dio.options.baseUrl;
  final apiUri = api == null ? null : Uri.tryParse(api);
  return uri.scheme == 'http' && apiUri != null && uri.origin == apiUri.origin
      ? url
      : null;
});
