import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_keys.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_notifications_sheet.dart';
import 'package:phsar_fresh_app/features/notifications/domain/app_notification.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/models/notification_content.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/providers/notifications_provider.dart';

/// Pops up a bar when an order update or a new deal arrives while the app is
/// open. Tapping it opens the bell.
class NotificationAlerts extends ConsumerWidget {
  final Widget child;

  const NotificationAlerts({super.key, required this.child});

  /// Only news that arrived just now: signing in brings older order
  /// updates into the feed, and those belong in the bell, not a pop-up.
  static const _fresh = Duration(minutes: 10);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationsProvider, (previous, next) {
      final before = previous?.value;
      final after = next.value;
      if (before == null || after == null) return;
      final known = {for (final item in before) item.id};
      final cutoff = DateTime.now().subtract(_fresh);
      final AppNotification? latest = after
          .where(
            (item) =>
                !known.contains(item.id) &&
                item.alerts &&
                item.at.isAfter(cutoff),
          )
          .firstOrNull;
      if (latest == null) return;
      AppSnackBar.show(
        context,
        message: latest.alertText(context.l10n),
        icon: latest.icon,
        tone:
            latest.type == AppNotificationType.order ||
                latest.messageKind == StaffMessageKind.info
            ? AppSnackBarTone.success
            : AppSnackBarTone.info,
        onTap: () {
          final overlay = appNavigatorKey.currentState?.overlay?.context;
          if (overlay != null) MarketNotificationsSheet.show(overlay);
        },
      );
    });
    return child;
  }
}
