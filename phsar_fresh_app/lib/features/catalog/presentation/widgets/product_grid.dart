import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/empty_state.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_filter.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_product_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Product cards in a grid sized for the screen width and text scale.
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.products,
    required this.section,
  });

  final List<MarketProduct> products;

  /// Prefix for card keys, e.g. `explore-results-<id>`.
  final String section;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: SliverLayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = (constraints.crossAxisExtent / (140 * scale))
            .floor()
            .clamp(1, 3);
        final width =
            (constraints.crossAxisExtent - 12 * (columns - 1)) / columns;
        final imageHeight = width * .8;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // Room for a two-line name, the origin and a two-line price.
            mainAxisExtent: imageHeight + 120 * scale,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = products[index];
            // Skeleton grids can appear twice at once, so they get no hero.
            final heroTag = section == 'skeleton'
                ? null
                : 'product-$section-${product.id}';
            return MarketProductCard(
              key: ValueKey('explore-$section-${product.id}'),
              product: product,
              imageHeight: imageHeight,
              heroTag: heroTag,
              onTap: () =>
                  ProductDetailPage.open(context, product, heroTag: heroTag),
            );
          }, childCount: products.length),
        );
      },
    ),
  );
}

/// Shimmering placeholder cards, shaped like the preview catalog, shown while
/// products load.
class SliverProductGridSkeleton extends StatelessWidget {
  const SliverProductGridSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) => Skeletonizer.sliver(
    key: const Key('catalog-loading'),
    child: SliverProductGrid(
      products: marketProducts.take(count).toList(growable: false),
      section: 'skeleton',
    ),
  );
}

/// Loads [request] from the catalog and shows it, with loading, error,
/// empty and "load more" states.
class ProductListSliver extends ConsumerWidget {
  const ProductListSliver({
    super.key,
    required this.request,
    required this.section,
    required this.empty,
    this.sort = MarketSort.curated,
    this.where,
    this.maxItems,
  });

  final ProductRequest request;
  final String section;
  final Widget empty;
  final MarketSort sort;

  /// Optional extra filter on loaded products (e.g. new arrivals).
  final bool Function(MarketProduct)? where;

  /// Shows a preview instead of the full paged list.
  final int? maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productListProvider(request);
    final language = ref.watch(localeProvider).languageCode;
    return ref
        .watch(provider)
        .when(
          loading: () => SliverProductGridSkeleton(count: maxItems ?? 6),
          error: (_, _) => SliverToBoxAdapter(
            child: CatalogErrorState(onRetry: () => ref.invalidate(provider)),
          ),
          data: (list) {
            var products = sortProducts(list.items, sort, language);
            if (where != null) products = products.where(where!).toList();
            if (maxItems != null) products = products.take(maxItems!).toList();
            if (products.isEmpty) return SliverToBoxAdapter(child: empty);
            final canLoadMore = maxItems == null && list.hasMore;
            return SliverMainAxisGroup(
              slivers: [
                SliverProductGrid(products: products, section: section),
                if (canLoadMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: list.loadingMore
                            ? const CircularProgressIndicator(
                                color: AppColors.primary,
                              )
                            : OutlinedButton(
                                key: const Key('catalog-load-more'),
                                onPressed: () =>
                                    ref.read(provider.notifier).loadMore(),
                                child: Text(context.l10n.catalogLoadMore),
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
  }
}

/// Shown when products or categories cannot be loaded.
class CatalogErrorState extends StatelessWidget {
  const CatalogErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const Key('catalog-error'),
    height: 280,
    child: EmptyState(
      icon: Icons.cloud_off_outlined,
      title: context.l10n.catalogLoadError,
      description: context.l10n.catalogLoadErrorBody,
      actionLabel: context.l10n.catalogRetry,
      onAction: onRetry,
    ),
  );
}
