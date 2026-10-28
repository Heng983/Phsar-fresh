import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';

class CartCheckoutButton extends ConsumerWidget {
  final int totalInCents;
  final VoidCallback onPressed;

  const CartCheckoutButton({
    super.key,
    required this.totalInCents,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FilledButton(
    key: const Key('cart-checkout'),
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.loginButton,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: Row(
      children: [
        const Icon(Icons.shopping_bag_outlined, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cartCheckout,
                style: const TextStyle(
                  fontSize: AppFontSize.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                productPrice(
                  totalInCents,
                  context.l10n,
                  ref.watch(currencyProvider),
                ),
                style: const TextStyle(
                  fontSize: AppFontSize.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, size: 22),
      ],
    ),
  );
}
