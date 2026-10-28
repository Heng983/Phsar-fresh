import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/features/notifications/domain/app_notification.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

extension AppNotificationContent on AppNotification {
  bool _khmer(AppLocalizations l10n) => l10n.localeName == 'km';

  String _messageHeading(AppLocalizations l10n) {
    final code = orderCode ?? '';
    return switch (messageKind) {
      StaffMessageKind.problem => l10n.notificationMessageProblemTitle(code),
      StaffMessageKind.cancelled => l10n.notificationMessageCancelledTitle(
        code,
      ),
      _ => l10n.notificationMessageTitle(code),
    };
  }

  String heading(AppLocalizations l10n) => type == AppNotificationType.message
      ? _messageHeading(l10n)
      : switch (orderUpdate) {
          null =>
            (_khmer(l10n) ? titleKm : null) ??
                title ??
                l10n.notificationsPromotion,
          OrderUpdate.placed => l10n.notificationOrderPlacedTitle,
          OrderUpdate.paid => l10n.notificationOrderPaidTitle,
          OrderUpdate.preparing => l10n.notificationOrderPreparingTitle,
          OrderUpdate.delivering => l10n.notificationOrderDeliveringTitle,
          OrderUpdate.delivered => l10n.notificationOrderDeliveredTitle,
          OrderUpdate.cancelled => l10n.notificationOrderCancelledTitle,
        };

  String? message(AppLocalizations l10n) {
    if (type == AppNotificationType.message) return body;
    final code = orderCode ?? '';
    return switch (orderUpdate) {
      null => (_khmer(l10n) ? bodyKm : null) ?? body,
      OrderUpdate.placed => l10n.notificationOrderPlacedBody(code),
      OrderUpdate.paid => l10n.notificationOrderPaidBody(code),
      OrderUpdate.preparing => l10n.notificationOrderPreparingBody(code),
      OrderUpdate.delivering => l10n.notificationOrderDeliveringBody(code),
      OrderUpdate.delivered => l10n.notificationOrderDeliveredBody(code),
      OrderUpdate.cancelled => l10n.notificationOrderCancelledBody(code),
    };
  }

  /// One line for the in-app pop-up.
  String alertText(AppLocalizations l10n) => type == AppNotificationType.message
      ? '${heading(l10n)} — ${body ?? ''}'
      : switch (orderUpdate) {
          null => heading(l10n),
          _ => message(l10n)!,
        };

  IconData get icon => type == AppNotificationType.message
      ? switch (messageKind) {
          StaffMessageKind.problem => Icons.report_problem_rounded,
          StaffMessageKind.cancelled => Icons.cancel_rounded,
          _ => Icons.chat_bubble_rounded,
        }
      : switch (orderUpdate) {
          null => Icons.local_offer_rounded,
          OrderUpdate.placed => Icons.receipt_long_rounded,
          OrderUpdate.paid => Icons.check_circle_rounded,
          OrderUpdate.preparing => Icons.shopping_basket_rounded,
          OrderUpdate.delivering => Icons.delivery_dining_rounded,
          OrderUpdate.delivered => Icons.home_rounded,
          OrderUpdate.cancelled => Icons.cancel_rounded,
        };

  /// Background and foreground of the round icon.
  (Color, Color) get iconColors => type == AppNotificationType.message
      ? switch (messageKind) {
          StaffMessageKind.problem => (AppColors.lightOrange, AppColors.orange),
          StaffMessageKind.cancelled => (
            AppTints.chili.soft,
            AppTints.chili.ink,
          ),
          _ => (AppColors.lightGreen, AppColors.primary),
        }
      : switch (orderUpdate) {
          null => (AppColors.lightOrange, AppColors.orange),
          OrderUpdate.cancelled => (
            AppColors.inputBackground,
            AppColors.textSecondary,
          ),
          _ => (AppColors.lightGreen, AppColors.primary),
        };
}
