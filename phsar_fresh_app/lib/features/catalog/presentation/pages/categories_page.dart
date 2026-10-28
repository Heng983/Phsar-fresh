import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/empty_state.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/promotion_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/explore_section_header.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_category_chips.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_harvest_deal.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_search_section.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/product_grid.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Browse by category: every product, or one category's products.
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetFilters() => ref.read(marketFilterProvider.notifier).reset();

  void _selectCategory(String? categoryId) {
    ref.read(marketFilterProvider.notifier).selectCategory(categoryId);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _noResults() => SizedBox(
    height: 260,
    child: EmptyState(
      icon: Icons.search_off,
      title: context.l10n.marketNoResults,
      description: context.l10n.marketNoResultsDescription,
      actionLabel: context.l10n.marketResetFilters,
      onAction: _resetFilters,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(marketFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final loadingCategories = categoriesAsync.isLoading;
    final categories = loadingCategories
        ? marketCategories
        : categoriesAsync.value ?? const <ProductCategory>[];
    final selected = loadingCategories
        ? null
        : categories
              .where((category) => category.id == filter.categoryId)
              .firstOrNull;
    final promotions = ref.watch(promotionsProvider);
    final hasDeals =
        promotions.isLoading || (promotions.value?.isNotEmpty ?? false);
    final inCategory = filter.categoryId != null;
    return CustomScrollView(
      controller: _scrollController,
      key: const PageStorageKey('market-catalog'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        const SliverToBoxAdapter(child: MarketHeader()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: const SliverToBoxAdapter(child: MarketSearchSection()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: Skeletonizer(
            enabled: loadingCategories,
            child: MarketCategoryChips(
              categories: categories,
              selected: filter.categoryId,
              onChanged: _selectCategory,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        if (hasDeals)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: const SliverToBoxAdapter(child: MarketHarvestDeal()),
          ),
        SliverToBoxAdapter(
          child: inCategory
              ? ExploreSectionHeader(
                  title: selected?.label(l10n) ?? l10n.exploreProducts,
                  subtitle: selected?.descriptionText(l10n),
                  actionLabel: l10n.marketAllItems,
                  onAction: () => _selectCategory(null),
                )
              : ExploreSectionHeader(title: l10n.catalogAllProducts),
        ),
        ProductListSliver(
          request: productRequestFor(filter),
          section: inCategory ? 'in-category' : 'all',
          sort: filter.sort,
          empty: inCategory && filter.query.trim().isEmpty && !filter.hasOptions
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      l10n.catalogNoProductsInCategory,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : _noResults(),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
