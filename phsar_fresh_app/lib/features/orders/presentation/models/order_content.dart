import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

extension OrderStatusContent on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.awaitingPayment => l10n.ordersAwaitingPayment,
    OrderStatus.confirmed => l10n.ordersConfirmed,
    OrderStatus.packed => l10n.ordersPacked,
    OrderStatus.onTheWay => l10n.ordersOnTheWay,
    OrderStatus.delivered => l10n.ordersDelivered,
    OrderStatus.cancelled => l10n.ordersCancelled,
  };
}

extension OrderStatusTint on OrderStatus {
  /// One colour per status, used for its pill and label.
  AppTint get tint => switch (this) {
    OrderStatus.awaitingPayment => AppTints.mango,
    OrderStatus.confirmed => AppTints.sky,
    OrderStatus.packed => AppTints.eggplant,
    OrderStatus.onTheWay => AppTints.lime,
    OrderStatus.delivered => AppTints.leaf,
    OrderStatus.cancelled => AppTints.chili,
  };
}

extension OrderPaymentContent on CheckoutPayment {
  String orderLabel(AppLocalizations l10n) => switch (this) {
    CheckoutPayment.abaPay => l10n.checkoutAbaPay,
    CheckoutPayment.card => l10n.checkoutCard,
    CheckoutPayment.cash => l10n.checkoutCash,
  };
}

String orderDay(DateTime value, DateTime now, AppLocalizations l10n) {
  if (DateUtils.isSameDay(value, now)) return l10n.checkoutToday;
  if (DateUtils.isSameDay(value, DateTime(now.year, now.month, now.day - 1))) {
    return l10n.ordersYesterday;
  }
  return DateFormat.yMMMd(l10n.localeName).format(value);
}

String orderPlacedAt(MarketOrder order, DateTime now, AppLocalizations l10n) =>
    l10n.ordersPlacedAt(
      orderDay(order.placedAt, now, l10n),
      DateFormat.Hm(l10n.localeName).format(order.placedAt),
    );
