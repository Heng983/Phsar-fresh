import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';

/// Deals from the catalog: the preview deals, or the server's `/promotions`.
final promotionsProvider = FutureProvider<List<MarketPromotion>>(
  (ref) => ref.watch(catalogRepositoryProvider).promotions(),
);

/// Admin-made picture banners. A failure is treated as "none", so the
/// carousel still shows deals and the built-in Ming Sros banner.
final bannersProvider = FutureProvider<List<AppBanner>>((ref) async {
  try {
    return await ref.watch(catalogRepositoryProvider).banners();
  } catch (_) {
    return const [];
  }
});

/// The countdown for deals without their own end time.
final harvestDealDeadlineProvider = Provider<DateTime>(
  (ref) =>
      DateTime.now().add(const Duration(hours: 3, minutes: 45, seconds: 11)),
);

class ClaimedPromotionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  bool claim(MarketPromotion promotion) {
    final id = promotion.product.id;
    final DateTime endsAt =
        promotion.endsAt ?? ref.read(harvestDealDeadlineProvider);
    if (state.contains(id) || !endsAt.isAfter(DateTime.now())) {
      return false;
    }
    ref.read(marketCartProvider.notifier).add(promotion.product);
    state = Set.unmodifiable({...state, id});
    return true;
  }
}

final claimedPromotionsProvider =
    NotifierProvider<ClaimedPromotionNotifier, Set<String>>(
      ClaimedPromotionNotifier.new,
    );
