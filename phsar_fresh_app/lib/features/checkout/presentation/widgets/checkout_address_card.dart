import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/core/widgets/tint_icon.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_address_sheet.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/address_details_fields.dart';

class CheckoutAddressCard extends ConsumerWidget {
  const CheckoutAddressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final preferences = ref.watch(checkoutProvider);
    final location = ref.watch(deliveryLocationProvider);
    final addressName = location.addressName(l10n);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TintIcon(
                icon: Icons.location_on_rounded,
                tint: AppTints.chili,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.checkoutDeliveryAddress,
                  style: TextStyle(
                    fontSize: AppFontSize.footnote,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('checkout-change-address'),
                    onPressed: () => CheckoutAddressSheet.show(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: Text(l10n.checkoutChange, textAlign: TextAlign.end),
                  ),
                ),
              ),
            ],
          ),
          if (addressName != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                key: const Key('checkout-address-label'),
                avatar: Icon(
                  location.addressIcon,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(addressName),
                backgroundColor: AppColors.lightGreen,
                side: BorderSide.none,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            location.fullAddress,
            key: const Key('checkout-address'),
            style: const TextStyle(
              fontSize: AppFontSize.bodyLarge,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  preferences.recipient.isEmpty
                      ? l10n.checkoutAddRecipient
                      : '${preferences.recipient} · ${preferences.phone}',
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (location.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    location.note,
                    key: const Key('checkout-address-note'),
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.eco_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.checkoutLocalFresh,
                  style: const TextStyle(
                    fontSize: AppFontSize.badge,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
