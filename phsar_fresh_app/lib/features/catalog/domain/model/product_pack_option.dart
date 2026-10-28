enum ProductPackSize {
  quarterKg,
  halfKg,
  kilogram,
  standardPack,
  doublePack,
  sixEggs,
  dozenEggs,
}

class ProductPackOption {
  final ProductPackSize size;
  final int priceInCents;
  final bool isDefault;
  final bool isPopular;

  const ProductPackOption({
    required this.size,
    required this.priceInCents,
    this.isDefault = false,
    this.isPopular = false,
  });
}
