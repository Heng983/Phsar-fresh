import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/orders/presentation/models/order_content.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_amount.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_details_sheet.dart';

class PastOrderCard extends ConsumerWidget {
  final MarketOrder order;
  final VoidCallback onReorder;

  const PastOrderCard({
    super.key,
    required this.order,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(ordersReferenceTimeProvider);
    final delivered = order.status == OrderStatus.delivered;
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivered
                          ? l10n.ordersDeliveredOn(
                              orderDay(
                                order.deliveredAt ?? order.placedAt,
                                now,
                                l10n,
                              ),
                            )
                          : order.status.label(l10n),
                      style: TextStyle(
                        color: order.status.tint.ink,
                        fontSize: AppFontSize.badge,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.ordersReference(order.id),
                      style: const TextStyle(
                        fontSize: AppFontSize.price,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: OrderAmount(cents: order.totalInCents)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.marketItemCount(order.itemCount)} · ${order.payment.orderLabel(l10n)}',
            style: const TextStyle(
              fontSize: AppFontSize.caption,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in order.items.take(3))
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MarketImage(
                          path: item.product.imageUrl,
                          semanticLabel: item.product.title(l10n),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xBF15281D),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7),
                              ),
                            ),
                            child: Text(
                              '×${item.quantity}',
                              style: const TextStyle(
                                fontSize: AppFontSize.badge,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (order.items.length > 3)
                Container(
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    l10n.ordersMoreItems(order.items.length - 3),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppFontSize.badge,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          if (delivered) ...[
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.leftAtReception
                        ? l10n.ordersLeftAtReception
                        : l10n.ordersHandedToCustomer,
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final reorder = FilledButton(
                key: ValueKey('order-reorder-${order.id}'),
                onPressed: onReorder,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  backgroundColor: AppColors.loginButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.replay_rounded, size: 19),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        l10n.ordersReorder,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppFontSize.footnote,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              final receipt = TextButton(
                key: ValueKey('order-receipt-${order.id}'),
                onPressed: () =>
                    OrderDetailsSheet.show(context, order, receipt: delivered),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  foregroundColor: AppColors.textPrimary,
                  backgroundColor: AppColors.inputBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 19),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        delivered ? l10n.ordersReceipt : l10n.ordersViewDetails,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: AppFontSize.footnote),
                      ),
                    ),
                  ],
                ),
              );
              if (constraints.maxWidth < 300 &&
                  MediaQuery.textScalerOf(context).scale(13) > 16) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [reorder, const SizedBox(height: 8), receipt],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 3, child: reorder),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: receipt),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
