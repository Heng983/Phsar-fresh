import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/empty_state.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/voucher_problem_text.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';
import 'package:phsar_fresh_app/features/checkout/data/order_repository.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_address_card.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_address_sheet.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_app_bar.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_bottom_bar.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_delivery_section.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_instructions_card.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_order_summary.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_payment_section.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/order_placed_sheet.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';
import 'package:phsar_fresh_app/features/market/presentation/providers/market_tab_request_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/payment/presentation/pages/khqr_payment_page.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          settings: const RouteSettings(name: AppRoutes.checkout),
          builder: (_) => const CheckoutPage(),
        ),
      );

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;
    final client = ref.read(apiClientProvider);
    if (client == null) {
      // Local preview: there is no server to take the order.
      return _info(
        context,
        Icons.shopping_basket_outlined,
        l10n.checkoutComingSoon,
        l10n.checkoutUnavailable,
      );
    }
    final location = ref.read(deliveryLocationProvider);
    if (!location.hasCoordinates) {
      await _info(
        context,
        Icons.location_off_outlined,
        l10n.checkoutNeedLocationTitle,
        l10n.checkoutNeedLocation,
      );
      if (context.mounted) await CheckoutAddressSheet.show(context);
      return;
    }

    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.checkoutPlacing)),
            ],
          ),
        ),
      ),
    );
    final currency = ref.read(currencyProvider);
    String price(int cents) => productPrice(cents, l10n, currency);
    try {
      final order = await OrderRepository(client).place(
        items: ref.read(marketCartProvider),
        location: location,
        preferences: ref.read(checkoutProvider),
        voucherCode: ref.read(cartVoucherProvider),
      );
      navigator.pop(); // progress
      if (!context.mounted) return;
      if (order.payment != null || order.paymentError != null) {
        // The server order now holds the basket, so empty it right away:
        // the phone may restart the app while the customer is in ABA
        // Mobile, and a paid order must never leave a full basket behind.
        final cart = ref.read(marketCartProvider.notifier);
        final basket = ref.read(marketCartProvider);
        cart.clear();
        // ABA Pay: show the KHQR and wait for PayWay to confirm.
        final paid = await KhqrPaymentPage.open(
          context,
          orderId: order.id,
          orderCode: order.code,
          payment: order.payment,
          error: order.paymentError,
        );
        // Left without paying: drop the order and give the basket back for
        // another try. (If it was paid meanwhile, cancelling is refused and
        // the basket stays empty.)
        final cancelled =
            paid != true &&
            await OrderRepository(client).cancelUnpaid(order.id);
        if (cancelled) cart.replaceAll(basket);
        if (!context.mounted) return;
        ref.invalidate(remoteOrdersProvider);
        if (paid == true) {
          final action = await OrderPlacedSheet.show(
            context,
            code: order.code,
            total: price(order.totalInCents),
            payment: l10n.orderSuccessPaidAba,
            paid: true,
          );
          if (action == OrderPlacedAction.track) {
            ref.read(marketTabRequestProvider.notifier).open(MarketTab.orders);
          }
          if (!context.mounted) return;
        }
        Navigator.of(context).maybePop();
        return;
      }
      ref.read(marketCartProvider.notifier).clear();
      ref.invalidate(remoteOrdersProvider);
      final action = await OrderPlacedSheet.show(
        context,
        code: order.code,
        total: price(order.totalInCents),
        payment: l10n.checkoutCash,
      );
      if (action == OrderPlacedAction.track) {
        ref.read(marketTabRequestProvider.notifier).open(MarketTab.orders);
      }
      if (context.mounted) Navigator.of(context).maybePop();
    } on OrderFailure catch (failure) {
      navigator.pop(); // progress
      if (!context.mounted) return;
      final voucher = failure.voucher;
      if (failure.kind == OrderFailureKind.voucher && voucher != null) {
        // The code no longer works (e.g. already used): take it off so the
        // customer sees the real total before trying again.
        ref.read(cartVoucherProvider.notifier).remove();
      }
      await _info(
        context,
        Icons.error_outline_rounded,
        l10n.checkoutOrderFailedTitle,
        switch (failure.kind) {
          OrderFailureKind.signInRequired => l10n.checkoutSignInToOrder,
          OrderFailureKind.voucher => l10n.checkoutVoucherRemoved(
            voucher == null
                ? l10n.cartInvalidVoucher
                : voucherProblemText(l10n, voucher, price),
          ),
          OrderFailureKind.unavailable =>
            failure.message ?? l10n.checkoutOrderFailed,
          OrderFailureKind.network => l10n.checkoutOrderFailed,
        },
      );
    }
  }

  static Future<void> _info(
    BuildContext context,
    IconData icon,
    String title,
    String body,
  ) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(icon, color: AppColors.primary, size: 32),
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(context.l10n.marketClose),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empty = ref.watch(marketCartProvider).isEmpty;
    return Scaffold(
      appBar: CheckoutAppBar(toolbarHeight: CheckoutAppBar.heightFor(context)),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: empty
                ? EmptyState(
                    icon: Icons.shopping_basket_outlined,
                    title: context.l10n.marketEmptyCart,
                    description: context.l10n.marketEmptyCartDescription,
                    actionLabel: context.l10n.marketContinueShopping,
                    onAction: () => Navigator.pop(context),
                  )
                : SingleChildScrollView(
                    key: const PageStorageKey('checkout-scroll'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CheckoutAddressCard(),
                        const SizedBox(height: 24),
                        const CheckoutDeliverySection(),
                        const SizedBox(height: 4),
                        const CheckoutInstructionsCard(),
                        const SizedBox(height: 26),
                        const CheckoutPaymentSection(),
                        const SizedBox(height: 16),
                        const CheckoutOrderSummary(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.eco_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                context.l10n.cartFarmerSupport,
                                textAlign: TextAlign.center,
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
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: empty || MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : CheckoutBottomBar(onPlaceOrder: () => _placeOrder(context, ref)),
    );
  }
}
