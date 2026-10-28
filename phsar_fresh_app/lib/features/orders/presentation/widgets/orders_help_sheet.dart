import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class OrdersHelpSheet extends StatelessWidget {
  final String? orderId;

  const OrdersHelpSheet({super.key, this.orderId});

  static Future<void> show(BuildContext context, {String? orderId}) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        builder: (_) => OrdersHelpSheet(orderId: orderId),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                backgroundColor: AppColors.lightGreen,
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ordersHelpTitle,
              style: const TextStyle(
                fontSize: AppFontSize.headlineLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (orderId != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.ordersReference(orderId!),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            const SizedBox(height: 16),
            for (final entry in [
              (l10n.ordersHelpDelivery, l10n.ordersHelpDeliveryAnswer),
              (l10n.ordersHelpItems, l10n.ordersHelpItemsAnswer),
              (l10n.ordersHelpPayment, l10n.ordersHelpPaymentAnswer),
            ])
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  entry.$1,
                  style: const TextStyle(
                    fontSize: AppFontSize.bodySmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      entry.$2,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.marketClose),
            ),
          ],
        ),
      ),
    );
  }
}
