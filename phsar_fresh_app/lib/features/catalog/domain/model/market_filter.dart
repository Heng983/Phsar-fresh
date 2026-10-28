enum MarketSort { curated, name, itemCount }

class MarketFilter {
  final String query;

  /// Null shows every category.
  final String? categoryId;
  final bool inStockOnly;
  final MarketSort sort;

  const MarketFilter({
    this.query = '',
    this.categoryId,
    this.inStockOnly = false,
    this.sort = MarketSort.curated,
  });

  MarketFilter copyWith({
    String? query,
    String? Function()? categoryId,
    bool? inStockOnly,
    MarketSort? sort,
  }) => MarketFilter(
    query: query ?? this.query,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    inStockOnly: inStockOnly ?? this.inStockOnly,
    sort: sort ?? this.sort,
  );

  bool get hasOptions => inStockOnly || sort != MarketSort.curated;
}
