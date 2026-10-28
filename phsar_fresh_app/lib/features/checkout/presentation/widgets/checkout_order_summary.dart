import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/core/widgets/tint_icon.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';

class CheckoutOrderSummary extends ConsumerStatefulWidget {
  const CheckoutOrderSummary({super.key});

  @override
  ConsumerState<CheckoutOrderSummary> createState() =>
      _CheckoutOrderSummaryState();
}

class _CheckoutOrderSummaryState extends ConsumerState<CheckoutOrderSummary> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = ref.watch(cartSummaryProvider);
    final items = ref.watch(marketCartProvider);
    final currency = ref.watch(currencyProvider);
    String price(int cents) => currency.format(cents, l10n.localeName);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _expanded,
            child: InkWell(
              key: const Key('checkout-summary-toggle'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const TintIcon(
                      icon: Icons.shopping_basket_outlined,
                      tint: AppTints.leaf,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${l10n.cartOrderSummary} (${l10n.marketItemCount(summary.itemCount)})',
                        style: const TextStyle(
                          fontSize: AppFontSize.headline,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        price(summary.totalInCents),
                        style: const TextStyle(
                          fontSize: AppFontSize.title,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 21,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 18),
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CheckoutItem(item: item),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _AmountRow(
                              label: l10n.marketSubtotal,
                              amount: price(summary.subtotalInCents),
                            ),
                            if (summary.discountInCents > 0)
                              _AmountRow(
                                label: l10n.cartVoucherDiscount,
                                amount: '−${price(summary.discountInCents)}',
                                green: true,
                              ),
                            _AmountRow(
                              label: l10n.checkoutDeliveryFee,
                              amount: price(summary.deliveryInCents),
                            ),
                            _AmountRow(
                              label: l10n.checkoutPackaging,
                              amount: l10n.checkoutIncluded,
                              green: true,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                color: AppColors.divider,
                              ),
                            ),
                            _AmountRow(
                              label: l10n.checkoutTotalDue,
                              amount: price(summary.totalInCents),
                              total: true,
                              amountKey: const Key('checkout-total'),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                currency.convertedPrice(
                                  summary.totalInCents,
                                  l10n.localeName,
                                ),
                                style: const TextStyle(
                                  fontSize: AppFontSize.badge,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItem extends ConsumerWidget {
  final MarketCartItem item;

  const _CheckoutItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    final total = item.priceInCents * item.quantity;
    return Container(
      key: ValueKey(
        'checkout-item-${item.product.id}-${item.pack?.size.name ?? 'default'}',
      ),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 48,
              height: 52,
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
                    fontSize: AppFontSize.caption,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.checkoutItemQuantity(
                    item.quantity,
                    item.pack?.label(l10n) ?? item.product.unitLabel(l10n),
                  ),
                  style: const TextStyle(
                    fontSize: AppFontSize.badge,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(total, l10n.localeName),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: AppFontSize.footnote,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                Text(
                  currency.convertedPrice(total, l10n.localeName),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: AppFontSize.badge,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool total;
  final bool green;
  final Key? amountKey;

  const _AmountRow({
    required this.label,
    required this.amount,
    this.total = false,
    this.green = false,
    this.amountKey,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: total ? AppFontSize.bodySmall : AppFontSize.caption,
              height: 1.5,
              fontWeight: total ? FontWeight.w600 : FontWeight.w400,
              color: total ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            amount,
            key: amountKey,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: total ? AppFontSize.title : AppFontSize.caption,
              height: 1.5,
              fontWeight: total || green ? FontWeight.w700 : FontWeight.w400,
              color: total || green
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
