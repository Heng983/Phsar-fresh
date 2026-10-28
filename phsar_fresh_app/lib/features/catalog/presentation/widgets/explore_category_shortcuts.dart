import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/pressable.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Category photos on Explore; a skeleton while loading, hidden if loading
/// fails.
class ExploreCategoryShortcuts extends ConsumerWidget {
  final ValueChanged<String> onSelected;

  const ExploreCategoryShortcuts({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesProvider);
    // Skeleton only on the first load; a refresh keeps the current photos.
    final loading = async.isLoading && !async.hasValue;
    final categories = loading
        ? marketCategories
        : async.value ?? const <ProductCategory>[];
    if (categories.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    return Skeletonizer(
      key: loading ? const Key('explore-categories-loading') : null,
      enabled: loading,
      child: SizedBox(
        height: 72 + 36 * scale,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = categories[index];
            final label = category.label(context.l10n);
            return SizedBox(
              width: 96 * scale,
              child: Pressable(
                scale: .94,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: ValueKey('explore-category-${category.id}'),
                    onTap: () => onSelected(category.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.leaf(26),
                          // Tile colour shows through cut-out (transparent) photos.
                          child: ColoredBox(
                            color: AppColors.productCard,
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              // White photo backgrounds blend into the tile.
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  AppColors.productCard,
                                  BlendMode.multiply,
                                ),
                                child: MarketImage(path: category.imageUrl),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppFontSize.badge,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
