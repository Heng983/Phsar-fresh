import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/address_details_fields.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/market_location_sheet.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_notifications_sheet.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_profile_button.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/providers/notifications_provider.dart';

class MarketHeader extends ConsumerWidget {
  const MarketHeader({super.key});

  Future<void> _changeLocation(BuildContext context, WidgetRef ref) async {
    final location = await MarketLocationSheet.show(
      context,
      ref.read(deliveryLocationProvider),
    );
    if (!context.mounted || location == null) return;
    try {
      await ref.read(deliveryLocationProvider.notifier).select(location);
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(context, message: context.l10n.locationSaveError);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(deliveryLocationProvider);
    final addressName = location.addressName(context.l10n);
    final brand = context.l10n.marketBrand;
    final unread = ref.watch(marketUnreadNotificationCountProvider);
    // The brand, then where the basket is going: the line shoppers check.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          const MarketProfileButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.headline,
                    height: 1.3,
                    letterSpacing: AppTheme.letterSpacingFor(brand, -.4),
                  ),
                ),
                Semantics(
                  button: true,
                  child: InkWell(
                    onTap: () => _changeLocation(context, ref),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              addressName == null
                                  ? location.label
                                  : '$addressName · ${location.label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: AppFontSize.footnote,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: context.l10n.marketNotifications,
            onPressed: () => MarketNotificationsSheet.show(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(48, 48),
              elevation: 0,
              shadowColor: Colors.transparent,
              side: const BorderSide(color: AppDecorations.cardBorder),
              shape: const CircleBorder(),
            ),
            icon: Badge.count(
              count: unread,
              isLabelVisible: unread > 0,
              maxCount: 9,
              backgroundColor: AppColors.mango,
              textColor: AppColors.textPrimary,
              textStyle: const TextStyle(
                fontSize: AppFontSize.badge,
                fontWeight: FontWeight.w700,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
