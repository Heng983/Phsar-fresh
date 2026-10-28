import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/core/widgets/tint_icon.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_summary.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';

class CartOrderSummary extends ConsumerWidget {
  final CartSummary summary;
  final String? voucher;

  const CartOrderSummary({super.key, required this.summary, this.voucher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TintIcon(
                icon: Icons.receipt_long_outlined,
                tint: AppTints.sky,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.cartOrderSummary,
                  style: const TextStyle(
                    fontSize: AppFontSize.headline,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SummaryRow(
            label: l10n.marketSubtotal,
            amount: productPrice(summary.subtotalInCents, l10n, currency),
            amountKey: const Key('market-cart-total'),
          ),
          if (voucher != null) ...[
            const SizedBox(height: 16),
            _SummaryRow(
              label: l10n.cartVoucherDiscount,
              amount:
                  '-${productPrice(summary.discountInCents, l10n, currency)}',
              color: AppColors.primary,
            ),
          ],
          const SizedBox(height: 16),
          _SummaryRow(
            label: l10n.cartDelivery,
            amount: productPrice(summary.deliveryInCents, l10n, currency),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _SummaryRow(
            label: l10n.cartTotalPayable,
            amount: productPrice(summary.totalInCents, l10n, currency),
            amountKey: const Key('cart-total-payable'),
            color: AppColors.primaryDark,
            total: true,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Tooltip(
              message: l10n.currencyConvertedNote,
              child: Text(
                productConvertedPrice(summary.totalInCents, l10n, currency),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.caption,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final Key? amountKey;
  final Color color;
  final bool total;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.amountKey,
    this.color = AppColors.textPrimary,
    this.total = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: total ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: total ? AppFontSize.bodyLarge : AppFontSize.footnote,
            height: 1.5,
            fontWeight: total ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          amount,
          key: amountKey,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: color,
            fontSize: total ? AppFontSize.display : AppFontSize.price,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
