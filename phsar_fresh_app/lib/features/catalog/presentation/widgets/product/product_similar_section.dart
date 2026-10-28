import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_product_card.dart';

/// "You may also like": other products from the same category in a
/// horizontal row. Hidden while loading, on error, or when there are none.
class ProductSimilarSection extends ConsumerWidget {
  final MarketProduct product;

  const ProductSimilarSection({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (
      search: '',
      categoryId: product.category.id,
      inStockOnly: false,
    );
    final items = ref
        .watch(productListProvider(request))
        .maybeWhen(
          data: (state) => state.items
              .where((item) => item.id != product.id)
              .take(10)
              .toList(),
          orElse: () => const <MarketProduct>[],
        );
    if (items.isEmpty) return const SizedBox.shrink();

    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final width = 156.0 * scale.clamp(1.0, 1.3);
    final imageHeight = width * .8;
    return Column(
      key: const Key('product-similar'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(height: 1, thickness: 1, color: AppColors.divider),
        ),
        Text(
          context.l10n.productMoreLikeThis,
          style: const TextStyle(
            fontSize: AppFontSize.body,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: imageHeight + 120 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final heroTag = 'product-similar-${product.id}-${item.id}';
              return SizedBox(
                width: width,
                child: MarketProductCard(
                  key: ValueKey('product-similar-${item.id}'),
                  product: item,
                  imageHeight: imageHeight,
                  heroTag: heroTag,
                  onTap: () =>
                      ProductDetailPage.open(context, item, heroTag: heroTag),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
