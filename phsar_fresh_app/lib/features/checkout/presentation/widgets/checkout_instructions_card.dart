import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/core/widgets/tint_icon.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';

class CheckoutInstructionsCard extends ConsumerWidget {
  const CheckoutInstructionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const TintIcon(
              icon: Icons.edit_note_rounded,
              tint: AppTints.husk,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.checkoutInstructions,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.footnote,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: const Key('checkout-instructions'),
          initialValue: ref.read(checkoutProvider).instructions,
          onChanged: ref.read(checkoutProvider.notifier).updateInstructions,
          minLines: 2,
          maxLines: 4,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: AppFontSize.bodySmall, height: 1.5),
          decoration: InputDecoration(
            hintText: context.l10n.checkoutInstructionsHint,
            helperText: context.l10n.checkoutInstructionsHelp,
            helperMaxLines: 2,
            helperStyle: const TextStyle(
              fontSize: AppFontSize.badge,
              height: 1.5,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
          ),
        ),
      ],
    ),
  );
}
