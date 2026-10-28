import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

/// "Quantity" on the left, a compact pill stepper on the right.
class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final String unitLabel;
  final ValueChanged<int> onChanged;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.unitLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.l10n.productQuantity,
          style: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              buttonKey: const Key('product-quantity-minus'),
              tooltip: context.l10n.marketDecreaseQuantity,
              icon: Icons.remove_rounded,
              filled: false,
              onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: Text(
                '$quantity',
                key: const Key('product-quantity'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.bodyLarge,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _StepButton(
              buttonKey: const Key('product-quantity-plus'),
              tooltip: context.l10n.marketIncreaseQuantity,
              icon: Icons.add_rounded,
              filled: true,
              onPressed: quantity < 99 ? () => onChanged(quantity + 1) : null,
            ),
          ],
        ),
      ),
    ],
  );
}

class _StepButton extends StatelessWidget {
  final Key buttonKey;
  final String tooltip;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  const _StepButton({
    required this.buttonKey,
    required this.tooltip,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    key: buttonKey,
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: filled ? AppColors.primary : Colors.white,
      foregroundColor: filled ? Colors.white : AppColors.textPrimary,
      disabledBackgroundColor: Colors.white.withValues(alpha: .6),
      fixedSize: const Size.square(38),
      minimumSize: const Size.square(38),
      padding: EdgeInsets.zero,
    ),
    icon: Icon(icon, size: 20),
  );
}
