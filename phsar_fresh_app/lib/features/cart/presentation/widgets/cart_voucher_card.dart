import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/core/widgets/tint_icon.dart';
import 'package:phsar_fresh_app/features/cart/data/voucher_repository.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_summary.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/voucher_problem_text.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/product_detail_content.dart';

class CartVoucherCard extends ConsumerStatefulWidget {
  const CartVoucherCard({super.key});

  @override
  ConsumerState<CartVoucherCard> createState() => _CartVoucherCardState();
}

class _CartVoucherCardState extends ConsumerState<CartVoucherCard> {
  late final TextEditingController _controller;
  VoucherCheck? _refused;
  bool _checking = false;

  bool get _invalid => _refused != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(cartVoucherProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_checking) return;
    final notifier = ref.read(cartVoucherProvider.notifier);
    if (ref.read(apiClientProvider) == null) {
      // Local preview: answer at once.
      final applied = notifier.apply(_controller.text);
      setState(
        () => _refused = applied
            ? null
            : const VoucherCheck.refused(VoucherProblem.invalid),
      );
      if (applied) FocusScope.of(context).unfocus();
      return;
    }
    setState(() {
      _checking = true;
      _refused = null;
    });
    VoucherCheck result;
    try {
      result = await notifier.applyCode(_controller.text);
    } on Object catch (e) {
      debugPrint('Voucher apply failed: $e');
      result = const VoucherCheck.refused(VoucherProblem.network);
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _refused = result.isOk ? null : result;
    });
    if (result.isOk) {
      _controller.text = result.rule!.code;
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = ref.watch(currencyProvider);
    final voucher = ref.watch(cartVoucherProvider);
    final rule = ref.watch(cartVoucherRuleProvider);
    final summary = ref.watch(cartSummaryProvider);
    final remote = ref.watch(apiClientProvider) != null;
    String price(int cents) => productPrice(cents, l10n, currency);
    final shortBy = rule == null
        ? 0
        : rule.minSubtotalInCents - summary.subtotalInCents;
    final input = TextField(
      key: const Key('cart-voucher-input'),
      controller: _controller,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enabled: voucher == null && !_checking,
      onSubmitted: (_) => _apply(),
      onChanged: (_) {
        if (_invalid) setState(() => _refused = null);
      },
      decoration: InputDecoration(
        labelText: l10n.cartVoucherCode,
        hintText: remote ? null : CartSummary.voucherCode,
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TintIcon(icon: Icons.sell_outlined, tint: AppTints.mango),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.cartVoucherCode,
                  style: const TextStyle(
                    fontSize: AppFontSize.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (voucher == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                remote
                    ? l10n.cartVoucherHintRemote
                    : l10n.cartVoucherHint(
                        CartSummary.voucherCode,
                        price(CartSummary.voucherValueInCents),
                      ),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.caption,
                  height: 1.5,
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (voucher != null) return input;
              final button = FilledButton(
                key: const Key('cart-apply-voucher'),
                onPressed: _checking ? null : _apply,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _checking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.cartApplyVoucher),
              );
              if (constraints.maxWidth < 380 ||
                  MediaQuery.textScalerOf(context).scale(14) > 18) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [input, const SizedBox(height: 10), button],
                );
              }
              return Row(
                children: [
                  Expanded(child: input),
                  const SizedBox(width: 10),
                  button,
                ],
              );
            },
          ),
          if (_invalid)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  voucherProblemText(l10n, _refused!, price),
                  key: const Key('cart-voucher-error'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: AppFontSize.caption,
                  ),
                ),
              ),
            ),
          if (voucher != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.cartVoucherApplied(
                          voucher,
                          price(summary.discountInCents),
                        ),
                        key: const Key('cart-voucher-success'),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: AppFontSize.caption,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cartRemoveVoucher,
                    onPressed: () {
                      ref.read(cartVoucherProvider.notifier).remove();
                      setState(() => _refused = null);
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 19,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (shortBy > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.cartVoucherAddMore(price(shortBy), voucher),
                  key: const Key('cart-voucher-short'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSize.caption,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
