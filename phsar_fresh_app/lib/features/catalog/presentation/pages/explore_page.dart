import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/empty_state.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/promotion_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/explore_category_shortcuts.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/explore_section_header.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_harvest_deal.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_search_section.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product_grid.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

const ProductRequest _homeRequest = (
  search: '',
  categoryId: null,
  inStockOnly: false,
);

/// Discovery: deals and Ming Sros, categories, popular products and fresh
/// arrivals; or product results while searching.
class ExplorePage extends ConsumerStatefulWidget {
  final ValueChanged<String> onCategory;
  final VoidCallback onOpenChat;

  const ExplorePage({
    super.key,
    required this.onCategory,
    required this.onOpenChat,
  });

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  bool _showAll = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showProducts() {
    setState(() => _showAll = true);
    _scrollController.jumpTo(0);
  }

  void _reset() {
    setState(() => _showAll = false);
    ref.read(exploreFilterProvider.notifier).reset();
    _scrollController.jumpTo(0);
  }

  /// Pull to refresh: reloads deals, banners, categories and popular
  /// products. What's on screen stays until the new data arrives.
  Future<void> _refresh() async {
    ref
      ..invalidate(promotionsProvider)
      ..invalidate(bannersProvider)
      ..invalidate(categoriesProvider)
      ..invalidate(popularProductsProvider);
    // A failed reload keeps the old data on screen (errors show as before).
    Future<void> settle(Future<Object?> future) async {
      try {
        await future;
      } catch (_) {
        // keep what's on screen; the section shows its own error state
      }
    }

    await Future.wait([
      settle(ref.read(promotionsProvider.future)),
      settle(ref.read(bannersProvider.future)),
      settle(ref.read(categoriesProvider.future)),
      settle(ref.read(popularProductsProvider.future)),
    ]);
  }

  /// Up to six best sellers; hidden when there are none.
  List<Widget> _popular(AppLocalizations l10n) => ref
      .watch(popularProductsProvider)
      .when(
        loading: () => [
          SliverToBoxAdapter(
            child: ExploreSectionHeader(
              title: l10n.explorePopular,
              subtitle: l10n.explorePopularSubtitle,
              icon: Icons.local_fire_department_outlined,
              tint: AppTints.chili,
            ),
          ),
          const SliverProductGridSkeleton(),
        ],
        error: (_, _) => [
          SliverToBoxAdapter(
            child: CatalogErrorState(
              onRetry: () => ref.invalidate(popularProductsProvider),
            ),
          ),
        ],
        data: (products) => [
          if (products.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: ExploreSectionHeader(
                title: l10n.explorePopular,
                subtitle: l10n.explorePopularSubtitle,
                icon: Icons.local_fire_department_outlined,
                tint: AppTints.chili,
                actionLabel: l10n.exploreSeeAll,
                onAction: _showProducts,
              ),
            ),
            SliverProductGrid(
              products: products.take(6).toList(growable: false),
              section: 'popular',
            ),
          ],
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(exploreFilterProvider);
    final filtering =
        filter.query.trim().isNotEmpty ||
        filter.categoryId != null ||
        filter.hasOptions;
    final showResults = filtering || _showAll;
    final categories = ref.watch(categoriesProvider);
    final hasCategories =
        categories.isLoading || (categories.value?.isNotEmpty ?? false);
    // Only the preview catalog marks new arrivals so far.
    final home = ref.watch(productListProvider(_homeRequest)).value?.items;
    final hasNewArrivals =
        home?.any((product) => product.isNewArrival) ?? false;
    final noProducts = SizedBox(
      height: 280,
      child: EmptyState(
        icon: Icons.search_off,
        title: l10n.exploreNoProducts,
        description: l10n.marketNoResultsDescription,
        actionLabel: l10n.marketResetFilters,
        onAction: _reset,
      ),
    );
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        // Pull-to-refresh also works when the page is short.
        physics: const AlwaysScrollableScrollPhysics(),
        key: const PageStorageKey('market-explore'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          const SliverToBoxAdapter(child: MarketHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: const SliverToBoxAdapter(
              child: MarketSearchSection(forProducts: true),
            ),
          ),
          if (!showResults) ...[
            SliverToBoxAdapter(
              child: ExploreSectionHeader(
                title: l10n.exploreTodayHarvest,
                subtitle: l10n.exploreWelcome,
                icon: Icons.eco_outlined,
                tint: AppTints.leaf,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: MarketHarvestDeal(
                  onOpenChat: widget.onOpenChat,
                  onOpenCategory: widget.onCategory,
                ),
              ),
            ),
            if (hasCategories) ...[
              SliverToBoxAdapter(
                child: ExploreSectionHeader(
                  title: l10n.exploreShopCategories,
                  icon: Icons.grid_view_rounded,
                  tint: AppTints.sky,
                ),
              ),
              SliverToBoxAdapter(
                child: ExploreCategoryShortcuts(onSelected: widget.onCategory),
              ),
            ],
          ],
          if (showResults) ...[
            SliverToBoxAdapter(
              child: ExploreSectionHeader(
                title: l10n.exploreProducts,
                actionLabel: filtering
                    ? l10n.marketResetFilters
                    : l10n.exploreDiscover,
                onAction: _reset,
              ),
            ),
            ProductListSliver(
              request: productRequestFor(filter),
              section: 'results',
              sort: filter.sort,
              empty: noProducts,
            ),
          ] else ...[
            ..._popular(l10n),
            if (hasNewArrivals) ...[
              SliverToBoxAdapter(
                child: ExploreSectionHeader(
                  title: l10n.exploreFreshArrivals,
                  subtitle: l10n.exploreFreshSubtitle,
                  actionLabel: l10n.exploreSeeAll,
                  onAction: _showProducts,
                ),
              ),
              ProductListSliver(
                request: _homeRequest,
                section: 'fresh',
                where: (product) => product.isNewArrival,
                empty: const SizedBox.shrink(),
              ),
            ],
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
