import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/orders/presentation/models/order_content.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_amount.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_status_timeline.dart';

class OrderDetailsSheet extends ConsumerWidget {
  final MarketOrder order;
  final bool receipt;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    this.receipt = false,
  });

  static Future<void> show(
    BuildContext context,
    MarketOrder order, {
    bool receipt = false,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    builder: (_) => OrderDetailsSheet(order: order, receipt: receipt),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    String price(int cents) => currency.format(cents, l10n.localeName);
    final now = ref.watch(ordersReferenceTimeProvider);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              receipt ? l10n.ordersReceipt : l10n.ordersDetailsTitle,
              style: const TextStyle(
                fontSize: AppFontSize.display,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.ordersReference(order.id),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: AppFontSize.bodyLarge,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              orderPlacedAt(order, now, l10n),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppFontSize.caption,
                height: 1.5,
              ),
            ),
            if (order.isDemo)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.ordersSampleNotice,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: AppFontSize.badge,
                    height: 1.5,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (order.status != OrderStatus.cancelled)
              OrderStatusTimeline(status: order.status),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.checkoutDeliveryAddress,
                    style: const TextStyle(
                      fontSize: AppFontSize.badge,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.address,
                    style: const TextStyle(
                      fontSize: AppFontSize.bodySmall,
                      height: 1.5,
                    ),
                  ),
                  if (order.deliveredAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.ordersDeliveredOn(
                          orderDay(order.deliveredAt!, now, l10n),
                        ),
                        style: const TextStyle(
                          fontSize: AppFontSize.caption,
                          color: AppColors.primaryDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.marketItemCount(order.itemCount),
              style: const TextStyle(
                fontSize: AppFontSize.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: SizedBox(
                        width: 46,
                        height: 50,
                        child: MarketImage(
                          path: item.product.imageUrl,
                          semanticLabel: item.product.title(l10n),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title(l10n),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSize.footnote,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.checkoutItemQuantity(
                              item.quantity,
                              item.pack?.label(l10n) ??
                                  item.product.unitLabel(l10n),
                            ),
                            style: const TextStyle(
                              fontSize: AppFontSize.badge,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        price(item.priceInCents * item.quantity),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSize.footnote,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(color: AppColors.border),
            _ReceiptRow(
              label: l10n.marketSubtotal,
              amount: price(order.subtotalInCents),
            ),
            _ReceiptRow(
              label: l10n.checkoutDeliveryFee,
              amount: price(order.deliveryInCents),
            ),
            if (order.discountInCents > 0)
              _ReceiptRow(
                label: l10n.cartVoucherDiscount,
                amount: '−${price(order.discountInCents)}',
              ),
            _ReceiptRow(
              label: l10n.checkoutPaymentMethod,
              amount: order.payment.orderLabel(l10n),
            ),
            const Divider(color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.checkoutTotalDue,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppFontSize.body,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OrderAmount(
                      key: const Key('order-receipt-total'),
                      cents: order.totalInCents,
                      green: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.loginButton,
              ),
              child: Text(l10n.marketClose),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String amount;

  const _ReceiptRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.caption,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            amount,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: AppFontSize.caption,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
