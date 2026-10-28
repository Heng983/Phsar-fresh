import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';

class MarketCartItem {
  final MarketProduct product;
  final int quantity;
  final ProductPackOption? pack;

  const MarketCartItem({required this.product, this.quantity = 1, this.pack});

  int get priceInCents => pack?.priceInCents ?? product.priceInCents;

  MarketCartItem withQuantity(int value) =>
      MarketCartItem(product: product, quantity: value, pack: pack);
}
