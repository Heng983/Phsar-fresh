import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_filter.dart';

class MarketFilterSheet extends StatefulWidget {
  final MarketFilter filter;
  final ValueChanged<MarketFilter> onApply;
  final bool forProducts;

  const MarketFilterSheet({
    super.key,
    required this.filter,
    required this.onApply,
    this.forProducts = false,
  });

  @override
  State<MarketFilterSheet> createState() => _MarketFilterSheetState();
}

class _MarketFilterSheetState extends State<MarketFilterSheet> {
  late bool _inStockOnly;
  late MarketSort _sort;

  @override
  void initState() {
    super.initState();
    _inStockOnly = widget.filter.inStockOnly;
    _sort = widget.filter.sort;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.marketSortCurated,
      l10n.marketSortName,
      widget.forProducts ? l10n.explorePopularFirst : l10n.marketSortCount,
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.marketFilters,
                    style: const TextStyle(
                      fontSize: AppFontSize.headline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.marketClose,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            CheckboxListTile(
              key: const Key('market-in-stock-filter'),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text(l10n.marketInStockOnly),
              value: _inStockOnly,
              onChanged: (value) =>
                  setState(() => _inStockOnly = value ?? false),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.marketSortBy,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final sort in MarketSort.values)
                  ChoiceChip(
                    label: Text(labels[sort.index]),
                    selected: _sort == sort,
                    onSelected: (_) => setState(() => _sort = sort),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('market-apply-filters'),
              onPressed: () {
                widget.onApply(
                  widget.filter.copyWith(
                    inStockOnly: _inStockOnly,
                    sort: _sort,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(l10n.marketApplyFilters),
            ),
            TextButton(
              onPressed: () => setState(() {
                _inStockOnly = false;
                _sort = MarketSort.curated;
              }),
              child: Text(l10n.marketResetFilters),
            ),
          ],
        ),
      ),
    );
  }
}
