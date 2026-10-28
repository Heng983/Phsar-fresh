import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';

class CheckoutBottomBar extends ConsumerWidget {
  final VoidCallback onPlaceOrder;

  const CheckoutBottomBar({super.key, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    final total = ref.watch(cartSummaryProvider).totalInCents;
    final payment = ref.watch(
      checkoutProvider.select((value) => value.payment),
    );
    final amount = currency.format(total, l10n.localeName);
    final action = switch (payment) {
      CheckoutPayment.abaPay => l10n.checkoutPayAbaPay(amount),
      CheckoutPayment.card => l10n.checkoutPayCard(amount),
      CheckoutPayment.cash => l10n.checkoutPlaceCashOrder(amount),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.checkoutPayable,
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        amount,
                        key: const Key('checkout-payable-total'),
                        style: const TextStyle(
                          fontSize: AppFontSize.headline,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        currency.convertedPrice(total, l10n.localeName),
                        style: const TextStyle(
                          fontSize: AppFontSize.caption,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    key: const Key('checkout-place-order'),
                    onPressed: onPlaceOrder,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      backgroundColor: AppColors.loginButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(switch (payment) {
                          CheckoutPayment.abaPay =>
                            Icons.qr_code_scanner_rounded,
                          CheckoutPayment.card => Icons.credit_card_rounded,
                          CheckoutPayment.cash => Icons.local_shipping_outlined,
                        }, size: 21),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            action,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: AppFontSize.bodySmall,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
