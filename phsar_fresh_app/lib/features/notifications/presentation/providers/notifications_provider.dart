import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/notifications/data/notifications_repository.dart';
import 'package:phsar_fresh_app/features/notifications/domain/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository?>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return client == null ? null : NotificationsRepository(client);
});

/// The bell's feed. Reloads on sign in / out, every 30 s and when the app
/// comes back to the front, so order updates and new deals show up while
/// the app is open.
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  static const _pollEvery = Duration(seconds: 30);
  Timer? _poll;

  @override
  Future<List<AppNotification>> build() async {
    final lifecycle = AppLifecycleListener(onResume: refresh);
    ref.onDispose(() {
      _poll?.cancel();
      lifecycle.dispose();
    });
    final repository = ref.watch(notificationsRepositoryProvider);
    if (repository == null) return const [];
    await ref.watch(authSessionProvider.future);
    final items = await repository.feed();
    _schedule();
    return items;
  }

  void _schedule() {
    _poll?.cancel();
    _poll = Timer(_pollEvery, refresh);
  }

  /// Fetches again; keeps the current list if this attempt fails.
  Future<void> refresh() async {
    final repository = ref.read(notificationsRepositoryProvider);
    if (repository == null || state.isLoading) return;
    try {
      final items = await repository.feed();
      if (ref.mounted) state = AsyncData(items);
    } catch (_) {
      // Offline for a moment: try again on the next tick.
    }
    if (ref.mounted) _schedule();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

/// When the bell was last opened.
class NotificationsSeenNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => ref.watch(notificationSeenStorageProvider)?.read();

  void markAllRead() {
    final items = ref.read(notificationsProvider).value ?? const [];
    // The server's clock may run ahead of the phone's.
    var seen = DateTime.now();
    for (final item in items) {
      if (item.at.isAfter(seen)) seen = item.at;
    }
    state = seen;
    ref.read(notificationSeenStorageProvider)?.write(seen);
  }
}

final notificationsSeenAtProvider =
    NotifierProvider<NotificationsSeenNotifier, DateTime?>(
      NotificationsSeenNotifier.new,
    );

/// How many items arrived since the bell was last opened.
final marketUnreadNotificationCountProvider = Provider<int>((ref) {
  final seen = ref.watch(notificationsSeenAtProvider);
  final items = ref.watch(notificationsProvider).value ?? const [];
  return items.where((item) => seen == null || item.at.isAfter(seen)).length;
});
