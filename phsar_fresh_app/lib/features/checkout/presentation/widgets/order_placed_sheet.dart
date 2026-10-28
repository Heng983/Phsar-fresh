import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

/// What the customer picked on the success sheet.
enum OrderPlacedAction { track, shop }

/// Celebratory "Order placed!" bottom sheet: animated check, order number
/// (tap to copy), total and payment, the next steps, and two actions.
class OrderPlacedSheet extends StatelessWidget {
  final String code;
  final String total;
  final String payment;

  /// Already paid (ABA KHQR): "Total paid" instead of "Total amount due".
  final bool paid;

  const OrderPlacedSheet({
    super.key,
    required this.code,
    required this.total,
    required this.payment,
    this.paid = false,
  });

  static Future<OrderPlacedAction?> show(
    BuildContext context, {
    required String code,
    required String total,
    required String payment,
    bool paid = false,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<OrderPlacedAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => OrderPlacedSheet(
        code: code,
        total: total,
        payment: payment,
        paid: paid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      key: const Key('order-placed-sheet'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: _SuccessBadge()),
              const SizedBox(height: 20),
              Text(
                l10n.orderSuccessTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.headlineLarge,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.orderSuccessBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.bodySmall,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              _OrderFacts(
                code: code,
                total: total,
                payment: payment,
                paid: paid,
              ),
              const SizedBox(height: 18),
              const _NextSteps(),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('order-placed-track'),
                onPressed: () =>
                    Navigator.pop(context, OrderPlacedAction.track),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 20),
                label: Text(
                  l10n.orderSuccessTrack,
                  style: const TextStyle(
                    fontSize: AppFontSize.bodySmall,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                key: const Key('order-placed-shop'),
                onPressed: () => Navigator.pop(context, OrderPlacedAction.shop),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  l10n.marketContinueShopping,
                  style: const TextStyle(
                    fontSize: AppFontSize.bodySmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green check that pops in, inside two soft halo rings.
class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: AppMotion.of(context, const Duration(milliseconds: 650)),
    curve: Curves.elasticOut,
    builder: (context, value, child) =>
        Transform.scale(scale: .6 + .4 * value, child: child),
    child: Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreen.withValues(alpha: .55),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 84,
        height: 84,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGreen,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: AppShadows.glow(AppColors.primary),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        ),
      ),
    ),
  );
}

/// Order number (tap to copy), total and payment in one soft card.
class _OrderFacts extends StatefulWidget {
  final String code;
  final String total;
  final String payment;
  final bool paid;

  const _OrderFacts({
    required this.code,
    required this.total,
    required this.payment,
    required this.paid,
  });

  @override
  State<_OrderFacts> createState() => _OrderFactsState();
}

class _OrderFactsState extends State<_OrderFacts> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.selectionClick();
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.orderSuccessCode,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                shape: const StadiumBorder(
                  side: BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  key: const Key('order-placed-copy'),
                  customBorder: const StadiumBorder(),
                  onTap: _copy,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.code,
                          key: const Key('order-placed-code'),
                          style: const TextStyle(
                            fontSize: AppFontSize.footnote,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _FactRow(
            label: widget.paid
                ? l10n.orderSuccessTotalPaid
                : l10n.checkoutTotalDue,
            value: widget.total,
            strong: true,
          ),
          const SizedBox(height: 10),
          _FactRow(label: l10n.checkoutPaymentMethod, value: widget.payment),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _FactRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSize.caption,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: strong ? AppFontSize.body : AppFontSize.footnote,
            height: 1.4,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            color: strong ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}

/// Confirmed → Packed → On the way, with the first step done.
class _NextSteps extends StatelessWidget {
  const _NextSteps();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      (Icons.receipt_long_rounded, l10n.ordersConfirmed),
      (Icons.inventory_2_outlined, l10n.ordersPacked),
      (Icons.delivery_dining_rounded, l10n.ordersOnTheWay),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, step) in steps.indexed) ...[
          if (index > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Container(
                  height: 2,
                  color: index == 1 ? AppColors.primary : AppColors.divider,
                ),
              ),
            ),
          SizedBox(
            width: 76,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0
                        ? AppColors.primary
                        : AppColors.lightGreen,
                  ),
                  child: Icon(
                    step.$1,
                    size: 18,
                    color: index == 0 ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.$2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: AppFontSize.badge,
                    height: 1.35,
                    fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w500,
                    color: index == 0
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
