import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_choice_card.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_section_heading.dart';

class CheckoutPaymentSection extends ConsumerWidget {
  const CheckoutPaymentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(
      checkoutProvider.select((value) => value.payment),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutSectionHeading(
          icon: Icons.payments_outlined,
          tint: AppTints.teal,
          title: l10n.checkoutPaymentMethod,
          badge: 'USD & KHR',
        ),
        for (final method in CheckoutPayment.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CheckoutChoiceCard(
              key: ValueKey('checkout-payment-${method.name}'),
              selected: selected == method,
              leading: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: method == CheckoutPayment.abaPay
                      ? Colors.transparent
                      : const Color(0xFFD8E3CE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: method == CheckoutPayment.abaPay
                    ? Image.asset(
                        'assets/images/aba_logo.png',
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      )
                    : Icon(
                        method == CheckoutPayment.card
                            ? Icons.credit_card_rounded
                            : Icons.payments_outlined,
                        size: 22,
                      ),
              ),
              title: switch (method) {
                CheckoutPayment.abaPay => l10n.checkoutAbaPay,
                CheckoutPayment.card => l10n.checkoutCard,
                CheckoutPayment.cash => l10n.checkoutCash,
              },
              subtitle: switch (method) {
                CheckoutPayment.abaPay => l10n.checkoutAbaPayDescription,
                CheckoutPayment.card => l10n.checkoutCardDescription,
                CheckoutPayment.cash => l10n.checkoutCashDescription,
              },
              subtitleWidget: method == CheckoutPayment.card
                  ? const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          _CardBrandLogo('assets/images/visa.png'),
                          SizedBox(width: 6),
                          _CardBrandLogo('assets/images/mastercard.png'),
                        ],
                      ),
                    )
                  : null,
              detail: method == CheckoutPayment.abaPay
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 22,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.checkoutAbaPayHint,
                              style: const TextStyle(
                                fontSize: AppFontSize.caption,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              onTap: () =>
                  ref.read(checkoutProvider.notifier).selectPayment(method),
            ),
          ),
      ],
    );
  }
}

class _CardBrandLogo extends StatelessWidget {
  final String asset;

  const _CardBrandLogo(this.asset);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        asset,
        height: 24,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
