import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';
import 'package:phsar_fresh_app/features/market/presentation/providers/market_tab_request_provider.dart';
import 'package:phsar_fresh_app/features/notifications/domain/app_notification.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/models/notification_content.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/models/order_content.dart';

class MarketNotificationsSheet extends ConsumerWidget {
  /// Items newer than this get the "new" dot.
  final DateTime? unreadSince;

  const MarketNotificationsSheet({super.key, this.unreadSince});

  /// Opens the bell and marks everything read, on opening and again on
  /// closing for anything that arrived meanwhile.
  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final seen = container.read(notificationsSeenAtProvider.notifier);
    final unreadSince = container.read(notificationsSeenAtProvider);
    seen.markAllRead();
    container.read(notificationsProvider.notifier).refresh();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => MarketNotificationsSheet(unreadSince: unreadSince),
    ).whenComplete(seen.markAllRead);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final feed = ref.watch(notificationsProvider);
    final items = feed.value ?? const <AppNotification>[];

    void open(AppNotification item) {
      ref
          .read(marketTabRequestProvider.notifier)
          .open(
            item.type != AppNotificationType.promotion
                ? MarketTab.orders
                : MarketTab.explore,
          );
      Navigator.pop(context);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.marketNotifications,
              style: const TextStyle(
                fontSize: AppFontSize.headlineLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty && feed.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              const _Empty()
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _NotificationTile(
                      key: ValueKey('notification-${item.id}'),
                      item: item,
                      unread:
                          unreadSince == null || item.at.isAfter(unreadSince!),
                      onTap: () => open(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final bool unread;
  final VoidCallback onTap;

  const _NotificationTile({
    super.key,
    required this.item,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (background, foreground) = item.iconColors;
    final message = item.message(l10n);
    final time =
        '${orderDay(item.at, DateTime.now(), l10n)} · '
        '${DateFormat.Hm(l10n.localeName).format(item.at)}';
    return Material(
      color: unread ? AppColors.mint : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: background,
                child: Icon(item.icon, size: 20, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.heading(l10n),
                      style: const TextStyle(
                        fontSize: AppFontSize.bodySmall,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppFontSize.caption,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: AppFontSize.badge,
                        color: AppColors.inputHint,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 6),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightGreen,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.notificationsEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFontSize.body,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.notificationsEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFontSize.caption,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
