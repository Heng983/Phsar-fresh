import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/promotion_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';

class HarvestDealBanner extends ConsumerStatefulWidget {
  final MarketPromotion promotion;
  final double imageHeight;
  final bool compact;
  final DateTime endsAt;
  final bool claimed;
  final VoidCallback onClaim;

  const HarvestDealBanner({
    super.key,
    required this.promotion,
    required this.imageHeight,
    required this.compact,
    required this.endsAt,
    required this.claimed,
    required this.onClaim,
  });

  @override
  ConsumerState<HarvestDealBanner> createState() => _HarvestDealBannerState();
}

class _HarvestDealBannerState extends ConsumerState<HarvestDealBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (!widget.endsAt.isAfter(DateTime.now())) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = widget.endsAt
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, 999999);
    String digits(int number) => number.toString().padLeft(2, '0');
    final countdown =
        '${digits(seconds ~/ 3600)}:${digits(seconds ~/ 60 % 60)}:${digits(seconds % 60)}';
    final l10n = context.l10n;
    final promotion = widget.promotion;
    final currency = ref.watch(currencyProvider);
    final price = currency.format(
      promotion.product.priceInCents,
      l10n.localeName,
    );
    final originalPrice = currency.format(
      promotion.originalPriceInCents,
      l10n.localeName,
    );
    final convertedPrice = currency.convertedPrice(
      promotion.product.priceInCents,
      l10n.localeName,
    );
    final prices = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: price,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: AppFontSize.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: '/${promotion.product.unitLabel(l10n)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.badge,
                ),
              ),
            ],
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              originalPrice,
              style: const TextStyle(
                fontSize: AppFontSize.badge,
                color: Color(0xFF7C8977),
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              convertedPrice,
              style: const TextStyle(
                fontSize: AppFontSize.badge,
                color: AppColors.mango,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
    final button = FilledButton(
      key: ValueKey('claim-deal-${promotion.product.id}'),
      onPressed: seconds == 0 || widget.claimed ? null : widget.onClaim,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.loginButton,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(
        widget.claimed
            ? l10n.marketAddedToCart
            : seconds == 0
            ? l10n.marketDealEnded
            : l10n.marketClaimDeal,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: AppFontSize.badge, height: 1.4),
      ),
    );
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.leaf(30),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: widget.imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MarketImage(
                  path: promotion.product.imageUrl,
                  semanticLabel: promotion.product.title(l10n),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xDD10241A)],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mango,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: Color(0xFF573B0C),
                            size: 15,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              l10n.marketFlashDeal,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: AppFontSize.badge,
                                color: Color(0xFF573B0C),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.headline(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppFontSize.title,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promotion.product.description(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: AppFontSize.badge,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE3E9DB),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15281D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: Color(0xFFFFD8BE),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  countdown,
                                  style: const TextStyle(
                                    fontSize: AppFontSize.badge,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .7,
                                    color: Color(0xFFFFD8BE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Center(
                child: widget.compact
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [prices, const SizedBox(height: 8), button],
                      )
                    : Row(
                        children: [
                          Expanded(child: prices),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  140 *
                                  (MediaQuery.textScalerOf(context).scale(11) /
                                      11),
                            ),
                            child: button,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
