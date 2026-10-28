import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class OrderAmount extends ConsumerWidget {
  final int cents;
  final bool green;

  const OrderAmount({super.key, required this.cents, this.green = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currency.format(cents, context.l10n.localeName),
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: AppFontSize.headline,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: green ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          currency.convertedPrice(cents, context.l10n.localeName),
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: AppFontSize.badge,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
