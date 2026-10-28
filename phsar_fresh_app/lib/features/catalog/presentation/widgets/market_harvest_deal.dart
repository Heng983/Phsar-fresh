import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_promotions.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/promotion_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/promotion_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/harvest_deal_banner.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/ming_sros_promo_slide.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/server_banner_slide.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Harvest deals, then (on Explore, when [onOpenChat] is set) the admin's
/// picture banners — or the built-in Ming Sros slide when there are none.
class MarketHarvestDeal extends ConsumerStatefulWidget {
  const MarketHarvestDeal({super.key, this.onOpenChat, this.onOpenCategory});

  final VoidCallback? onOpenChat;

  /// Used by banners that open a category.
  final ValueChanged<String>? onOpenCategory;

  @override
  ConsumerState<MarketHarvestDeal> createState() => _MarketHarvestDealState();
}

class _MarketHarvestDealState extends ConsumerState<MarketHarvestDeal>
    with WidgetsBindingObserver {
  /// How often deals and banners are re-checked while the carousel is shown.
  static const refreshEvery = Duration(minutes: 5);

  final _controller = CarouselSliderController();
  int _activeIndex = 0;
  Timer? _poll;
  Timer? _expiry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(refreshEvery, (_) => _reload());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    _expiry?.cancel();
    super.dispose();
  }

  /// Back from the background: pick up changes made in the admin panel.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  void _reload() {
    if (!mounted) return;
    ref
      ..invalidate(promotionsProvider)
      ..invalidate(bannersProvider);
  }

  /// Rebuilds exactly when the next slide's end time passes, so it leaves
  /// the carousel on time (and the server list is re-checked).
  void _scheduleExpiry(Iterable<DateTime?> ends) {
    _expiry?.cancel();
    final now = DateTime.now();
    final next = ends
        .whereType<DateTime>()
        .where((end) => end.isAfter(now))
        .fold<DateTime?>(
          null,
          (soonest, end) =>
              soonest == null || end.isBefore(soonest) ? end : soonest,
        );
    if (next == null) return;
    _expiry = Timer(next.difference(now) + const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {});
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(promotionsProvider);
    final onOpenChat = widget.onOpenChat;
    // Banners belong to Explore only (the Categories tab shows deals only).
    final bannersAsync = onOpenChat == null ? null : ref.watch(bannersProvider);
    // Skeleton only on the first load; a refresh keeps the current slides.
    // On Explore it also waits for banners, so the Ming Sros slide does not
    // flash before the admin's banners replace it.
    final loading =
        (async.isLoading && !async.hasValue) ||
        (bannersAsync != null &&
            bannersAsync.isLoading &&
            !bannersAsync.hasValue);
    final now = DateTime.now();
    final promotions = (async.value ?? const [])
        .where((deal) => deal.endsAt == null || deal.endsAt!.isAfter(now))
        .toList(growable: false);
    final banners = (bannersAsync?.value ?? const <AppBanner>[])
        .where((b) => b.endsAt == null || b.endsAt!.isAfter(now))
        .toList(growable: false);
    _scheduleExpiry([
      for (final deal in promotions) deal.endsAt,
      for (final banner in banners) banner.endsAt,
    ]);
    final showMingSros = onOpenChat != null && banners.isEmpty;
    final slideCount =
        promotions.length + banners.length + (showMingSros ? 1 : 0);
    if (!loading && slideCount == 0) return const SizedBox.shrink();
    if (_activeIndex >= slideCount && slideCount > 0) {
      _activeIndex = slideCount - 1;
    }
    final claimed = ref.watch(claimedPromotionsProvider);
    final endsAt = ref.watch(harvestDealDeadlineProvider);
    final media = MediaQuery.of(context);
    final scale = media.textScaler.scale(14) / 14;
    final imageHeight =
        156.0 + (scale - 1).clamp(0, double.infinity).toDouble() * 40;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340 * scale;
        // Khmer lines are taller and never smaller than 12 px, so the
        // footer (prices, countdown, button) needs a little more room.
        final footerHeight =
            ((compact ? 140 : 92) + (context.isKhmer ? 10 : 0)) * scale;
        if (loading) {
          // A preview deal in the carousel's place while deals load.
          return Skeletonizer(
            key: const Key('market-promotions-loading'),
            child: SizedBox(
              height: imageHeight + footerHeight,
              child: HarvestDealBanner(
                promotion: marketPromotions.first,
                imageHeight: imageHeight,
                compact: compact,
                endsAt: endsAt,
                claimed: false,
                onClaim: () {},
              ),
            ),
          );
        }
        return Column(
          children: [
            CarouselSlider.builder(
              key: const Key('market-promotions-carousel'),
              carouselController: _controller,
              itemCount: slideCount,
              options: CarouselOptions(
                height: imageHeight + footerHeight,
                viewportFraction: 1,
                disableCenter: true,
                enableInfiniteScroll: false,
                autoPlay:
                    !media.disableAnimations && !media.accessibleNavigation,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 450),
                pauseAutoPlayOnTouch: true,
                pauseAutoPlayInFiniteScroll: false,
                onPageChanged: (index, _) =>
                    setState(() => _activeIndex = index),
              ),
              itemBuilder: (context, index, _) {
                if (index >= promotions.length && banners.isNotEmpty) {
                  final banner = banners[index - promotions.length];
                  return ServerBannerSlide(
                    key: ValueKey('promotion-banner-${banner.id}'),
                    banner: banner,
                    imageHeight: imageHeight,
                    compact: compact,
                    onTap: _bannerTap(context, banner, onOpenChat),
                  );
                }
                if (index == promotions.length) {
                  return MingSrosPromoSlide(
                    key: const ValueKey('promotion-ming-sros'),
                    imageHeight: imageHeight,
                    compact: compact,
                    onOpen: onOpenChat!,
                  );
                }
                final promotion = promotions[index];
                return HarvestDealBanner(
                  key: ValueKey('promotion-${promotion.product.id}'),
                  promotion: promotion,
                  imageHeight: imageHeight,
                  compact: compact,
                  endsAt: promotion.endsAt ?? endsAt,
                  claimed: claimed.contains(promotion.product.id),
                  onClaim: () {
                    final added = ref
                        .read(claimedPromotionsProvider.notifier)
                        .claim(promotion);
                    if (added) HapticFeedback.lightImpact();
                  },
                );
              },
            ),
            if (slideCount > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < slideCount; index++)
                    Semantics(
                      button: true,
                      selected: _activeIndex == index,
                      label: context.l10n.marketPromotionPosition(
                        index + 1,
                        slideCount,
                      ),
                      child: Tooltip(
                        message: index < promotions.length
                            ? promotions[index].headline(context.l10n)
                            : banners.isNotEmpty
                            ? banners[index - promotions.length].localizedTitle(
                                Localizations.localeOf(context).languageCode,
                              )
                            : context.l10n.exploreMingSrosAction,
                        child: InkResponse(
                          key: ValueKey('promotion-dot-$index'),
                          onTap: () {
                            if (media.disableAnimations) {
                              _controller.jumpToPage(index);
                            } else {
                              _controller.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                              );
                            }
                          },
                          child: SizedBox(
                            width: 40,
                            height: 36,
                            child: Center(
                              child: AnimatedContainer(
                                duration: media.disableAnimations
                                    ? Duration.zero
                                    : const Duration(milliseconds: 200),
                                width: _activeIndex == index ? 22 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _activeIndex == index
                                      ? AppColors.primary
                                      : const Color(0xFFD5DCCD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  /// What tapping a banner does; null = picture only.
  VoidCallback? _bannerTap(
    BuildContext context,
    AppBanner banner,
    VoidCallback? onOpenChat,
  ) {
    switch (banner.action) {
      case BannerAction.openChat:
        return onOpenChat;
      case BannerAction.openCategory:
        final id = banner.categoryId;
        final open = widget.onOpenCategory;
        return id == null || open == null ? null : () => open(id);
      case BannerAction.openProduct:
        final product = banner.product;
        return product == null
            ? null
            : () => ProductDetailPage.open(context, product);
      case BannerAction.none:
        return null;
    }
  }
}
