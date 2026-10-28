import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/core/widgets/empty_state.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_checkout_button.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_heading.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_order_summary.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_packaging_card.dart';
import 'package:phsar_fresh_app/features/cart/presentation/widgets/cart_voucher_card.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';

class CartPage extends ConsumerWidget {
  final VoidCallback onContinueShopping;

  const CartPage({super.key, required this.onContinueShopping});

  static void _remove(
    BuildContext context,
    WidgetRef ref,
    MarketCartItem item,
    int index,
  ) {
    final cart = ref.read(marketCartProvider.notifier);
    cart.setQuantity(item.product.id, 0, packSize: item.pack?.size);
    final l10n = context.l10n;
    AppSnackBar.show(
      context,
      message: l10n.cartItemRemoved,
      icon: Icons.delete_outline_rounded,
      actionLabel: l10n.commonUndo,
      onAction: () => cart.restore(item, index),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(marketCartProvider);
    final summary = ref.watch(cartSummaryProvider);
    final cart = ref.read(marketCartProvider.notifier);

    if (items.isEmpty) {
      return Column(
        children: [
          const MarketHeader(),
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_basket_outlined,
              title: context.l10n.marketEmptyCart,
              description: context.l10n.marketEmptyCartDescription,
              actionLabel: context.l10n.marketContinueShopping,
              onAction: onContinueShopping,
            ),
          ),
        ],
      );
    }

    return ListView(
      key: const PageStorageKey('market-cart-scroll'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.zero,
      children: [
        const MarketHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CartHeading(itemCount: summary.itemCount),
              const SizedBox(height: 20),
              for (final (index, item) in items.indexed)
                Padding(
                  key: ValueKey(
                    'cart-${item.product.id}-${item.pack?.size.name ?? 'default'}',
                  ),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey(
                      'cart-dismiss-${item.product.id}-${item.pack?.size.name ?? 'default'}',
                    ),
                    direction: DismissDirection.endToStart,
                    background: const _RemoveBackground(),
                    onDismissed: (_) => _remove(context, ref, item, index),
                    child: CartItemCard(
                      item: item,
                      onQuantityChanged: (quantity) => quantity > 0
                          ? cart.setQuantity(
                              item.product.id,
                              quantity,
                              packSize: item.pack?.size,
                            )
                          : _remove(context, ref, item, index),
                      onRemove: () => _remove(context, ref, item, index),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              const CartVoucherCard(),
              const SizedBox(height: 16),
              const CartPackagingCard(),
              const SizedBox(height: 16),
              CartOrderSummary(
                summary: summary,
                voucher: ref.watch(cartVoucherProvider),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.handshake_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.cartFarmerSupport,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppFontSize.caption,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CartCheckoutButton(
                totalInCents: summary.totalInCents,
                onPressed: () => CheckoutPage.open(context),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onContinueShopping,
                child: Text(context.l10n.marketContinueShopping),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(
      color: AppTints.chili.soft,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.delete_outline_rounded, color: AppTints.chili.ink),
        const SizedBox(height: 4),
        Text(
          context.l10n.commonRemove,
          style: TextStyle(
            color: AppTints.chili.ink,
            fontSize: AppFontSize.caption,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
