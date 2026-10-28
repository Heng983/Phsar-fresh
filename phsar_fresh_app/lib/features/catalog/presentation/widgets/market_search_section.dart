import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_filter.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_filter_sheet.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_search_bar.dart';

/// Shared search controller and filter actions for the two catalog pages.
class MarketSearchSection extends ConsumerStatefulWidget {
  final bool forProducts;

  const MarketSearchSection({super.key, this.forProducts = false});

  @override
  ConsumerState<MarketSearchSection> createState() =>
      _MarketSearchSectionState();
}

class _MarketSearchSectionState extends ConsumerState<MarketSearchSection> {
  late final TextEditingController _controller;

  NotifierProvider<MarketFilterNotifier, MarketFilter> get _filterProvider =>
      widget.forProducts ? exploreFilterProvider : marketFilterProvider;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(_filterProvider).query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFilters() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => MarketFilterSheet(
      forProducts: widget.forProducts,
      filter: ref.read(_filterProvider),
      onApply: (filter) => ref
          .read(_filterProvider.notifier)
          .applyOptions(inStockOnly: filter.inStockOnly, sort: filter.sort),
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.listen(_filterProvider.select((filter) => filter.query), (_, query) {
      if (_controller.text != query) {
        _controller.value = TextEditingValue(
          text: query,
          selection: TextSelection.collapsed(offset: query.length),
        );
      }
    });
    final filter = ref.watch(_filterProvider);
    return MarketSearchBar(
      controller: _controller,
      onChanged: (value) => ref.read(_filterProvider.notifier).search(value),
      onFilters: _openFilters,
      hasActiveFilters: filter.hasOptions,
      onVoiceSearch: () => AppSnackBar.show(
        context,
        message: context.l10n.marketVoiceSearchHelp,
      ),
    );
  }
}
