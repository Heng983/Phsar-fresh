import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';

class MarketCategoryChips extends StatelessWidget {
  final List<ProductCategory> categories;

  /// Null means "All items".
  final String? selected;
  final ValueChanged<String?> onChanged;

  const MarketCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        for (final category in <ProductCategory?>[null, ...categories])
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: ValueKey('category-${category?.id ?? 'all'}'),
              label: Text(
                category?.label(context.l10n) ?? context.l10n.marketAllItems,
              ),
              selected: selected == category?.id,
              showCheckmark: false,
              onSelected: (_) => onChanged(category?.id),
              backgroundColor: AppColors.inputBackground,
              selectedColor: AppColors.loginButton,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              labelPadding: const EdgeInsets.symmetric(horizontal: 7),
              labelStyle: TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: FontWeight.w500,
                color: selected == category?.id
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    ),
  );
}
