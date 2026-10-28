import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/orders/presentation/models/order_content.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_amount.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_details_sheet.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_status_timeline.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/orders_help_sheet.dart';
import 'package:phsar_fresh_app/features/payment/presentation/pages/khqr_payment_page.dart';

class ActiveOrderCard extends ConsumerWidget {
  final MarketOrder order;

  const ActiveOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(ordersReferenceTimeProvider);
    final arrival = order.estimatedArrival;
    final minutes = arrival?.difference(now).inMinutes;
    final awaitingPayment = order.status == OrderStatus.awaitingPayment;
    final eta = awaitingPayment
        ? l10n.ordersPaymentNeeded
        : minutes != null && minutes > 0
        ? l10n.ordersArrivingIn(minutes)
        : l10n.ordersDeliveryInProgress;
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: order.status.tint.soft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.label(l10n),
                  style: TextStyle(
                    color: order.status.tint.ink,
                    fontSize: AppFontSize.badge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                order.isDemo
                    ? l10n.ordersTrackingPreview
                    : l10n.ordersDeliveryUpdate,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.badge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.ordersReference(order.id),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppFontSize.headline,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${orderPlacedAt(order, now, l10n)} · ${l10n.marketItemCount(order.itemCount)}',
            style: const TextStyle(
              fontSize: AppFontSize.caption,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final delivery = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.lightOrange,
                      child: Icon(
                        Icons.delivery_dining_rounded,
                        color: AppColors.orange,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eta,
                            style: const TextStyle(
                              fontSize: AppFontSize.body,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            order.address,
                            style: const TextStyle(
                              fontSize: AppFontSize.badge,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                if (constraints.maxWidth < 340 ||
                    MediaQuery.textScalerOf(context).scale(14) > 17) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      delivery,
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OrderAmount(
                          cents: order.totalInCents,
                          green: true,
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 3, child: delivery),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: OrderAmount(
                        cents: order.totalInCents,
                        green: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          OrderStatusTimeline(status: order.status),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.courierName ?? l10n.ordersCourierPending,
                        style: const TextStyle(
                          fontSize: AppFontSize.bodySmall,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.ordersDeliveryPartner,
                        style: const TextStyle(
                          fontSize: AppFontSize.badge,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('order-help-${order.id}'),
                  tooltip: l10n.ordersGetHelp,
                  onPressed: () =>
                      OrdersHelpSheet.show(context, orderId: order.id),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  icon: const Icon(Icons.support_agent_rounded, size: 22),
                ),
              ],
            ),
          ),
          if (awaitingPayment && order.serverId != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              key: ValueKey('order-pay-${order.id}'),
              onPressed: () async {
                await KhqrPaymentPage.open(
                  context,
                  orderId: order.serverId!,
                  orderCode: order.id,
                  payment: order.khqr,
                );
                // Paid or not, show the new status.
                await ref.read(remoteOrdersProvider.notifier).refresh();
              },
              icon: const Icon(Icons.qr_code_2_rounded, size: 20),
              label: Text(l10n.ordersPayNow),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            key: ValueKey('order-details-${order.id}'),
            onPressed: () => OrderDetailsSheet.show(context, order),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    l10n.ordersViewDetails,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
