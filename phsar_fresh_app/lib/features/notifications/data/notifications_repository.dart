import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/features/notifications/domain/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `GET /notifications` — live promotions for everyone, plus the signed-in
/// customer's order updates, newest first.
class NotificationsRepository {
  const NotificationsRepository(this._client);

  final ApiClient _client;

  Future<List<AppNotification>> feed() async {
    final response = await _client.dio
        .get<dynamic>('/notifications')
        .timeout(const Duration(seconds: 20));
    final data = response.data;
    if (data is! List) throw const FormatException('Unexpected notifications');
    return [for (final item in data) ?AppNotification.tryParse(item)];
  }
}

/// When the customer last opened the bell, kept on this device.
class NotificationSeenStorage {
  NotificationSeenStorage(this.preferences);

  final SharedPreferences preferences;
  static const key = 'phsar_fresh.notifications_seen_at.v1';

  DateTime? read() {
    final saved = preferences.getInt(key);
    return saved == null ? null : DateTime.fromMillisecondsSinceEpoch(saved);
  }

  Future<void> write(DateTime at) =>
      preferences.setInt(key, at.millisecondsSinceEpoch);
}

/// None by default (tests, previews); `main.dart` installs the device's.
final notificationSeenStorageProvider = Provider<NotificationSeenStorage?>(
  (ref) => null,
);
