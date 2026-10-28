import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_detail.dart';

enum _PreviewUnit { kilogram, pack, halfDozen }

const _previewUnits = {
  'greens': _PreviewUnit.kilogram,
  'mangoes': _PreviewUnit.kilogram,
  'citrus': _PreviewUnit.kilogram,
  'fish': _PreviewUnit.kilogram,
  'rice': _PreviewUnit.kilogram,
  'spices': _PreviewUnit.pack,
  'eggs': _PreviewUnit.halfDozen,
};

const _previewFarms = {
  'greens': ('Battambang Farm C', 'Ek Phnom, Battambang'),
  'mangoes': ('Kampong Speu Fruit Cooperative', 'Chbar Mon, Kampong Speu'),
  'eggs': ('Free-Range Family Farm', 'Kandal'),
  'citrus': ('Pursat Citrus Cooperative', 'Pursat'),
  'spices': ('Kampot Pepper Cooperative', 'Kampot'),
  'fish': ('Tonle Sap Fishing Cooperative', 'Tonle Sap'),
  'rice': ('Phka Rumduol Rice Cooperative', 'Battambang'),
};

/// Detail for the product page. Preview products get demonstration packs,
/// farms and reviews; server products have one price and no
/// invented details until the API provides them.
ProductDetail productDetailFor(MarketProduct product) {
  final unit = _previewUnits[product.id];
  final farm = _previewFarms[product.id];
  if (unit == null || farm == null) {
    return ProductDetail(
      product: product,
      images: [?product.imageUrl],
      packs: const [],
    );
  }
  final price = product.priceInCents;
  final packs = switch (unit) {
    _PreviewUnit.kilogram => [
      ProductPackOption(
        size: ProductPackSize.quarterKg,
        priceInCents: (price / 4).round(),
      ),
      ProductPackOption(
        size: ProductPackSize.halfKg,
        priceInCents: (price / 2).round(),
        isPopular: true,
      ),
      ProductPackOption(
        size: ProductPackSize.kilogram,
        priceInCents: price,
        isDefault: true,
      ),
    ],
    _PreviewUnit.pack => [
      ProductPackOption(
        size: ProductPackSize.standardPack,
        priceInCents: price,
        isDefault: true,
      ),
      ProductPackOption(
        size: ProductPackSize.doublePack,
        priceInCents: price * 2,
      ),
    ],
    _PreviewUnit.halfDozen => [
      ProductPackOption(
        size: ProductPackSize.sixEggs,
        priceInCents: price,
        isDefault: true,
      ),
      ProductPackOption(
        size: ProductPackSize.dozenEggs,
        priceInCents: price * 2,
      ),
    ],
  };
  return ProductDetail(
    product: product,
    images: [?product.imageUrl],
    packs: packs,
    farmName: farm.$1,
    farmAddress: farm.$2,
  );
}
