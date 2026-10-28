import 'dart:convert';

import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class CartStorage {
  List<MarketCartItem> read();
  Future<void> write(List<MarketCartItem> items);
}

/// Saves the basket on the device.
///
/// Preview-catalog products are always restored from the catalog, so a stored
/// price is never trusted. Server products are restored from a saved snapshot
/// for an instant basket; their prices are display-only and checkout must be
/// priced by the server.
class LocalCartStorage implements CartStorage {
  LocalCartStorage(this._preferences);

  final SharedPreferences _preferences;
  static const storageKey = 'phsar_fresh.cart.v1';
  static const _version = 2;

  @override
  List<MarketCartItem> read() {
    final saved = _preferences.get(storageKey);
    if (saved is! String) return const [];
    final dynamic decoded;
    try {
      decoded = jsonDecode(saved);
    } on FormatException {
      return const [];
    }
    if (decoded is! Map ||
        (decoded['version'] != 1 && decoded['version'] != _version) ||
        decoded['items'] is! List) {
      return const [];
    }

    final items = <String, MarketCartItem>{};
    for (final value in decoded['items']) {
      final item = value is Map ? _readItem(value) : null;
      if (item == null) continue;
      final key = '${item.product.id}:${item.pack?.size.name ?? 'default'}';
      items[key] = item.withQuantity(
        (items[key]?.quantity ?? 0) + item.quantity,
      );
    }
    return List.unmodifiable(items.values);
  }

  MarketCartItem? _readItem(Map<dynamic, dynamic> value) {
    final quantity = value['quantity'];
    if (quantity is! int || quantity <= 0) return null;
    final stored = value['product'];
    final id = stored is Map ? stored['id'] : stored;
    if (id is! String) return null;

    final preview = marketProducts.where((p) => p.id == id).firstOrNull;
    final MarketProduct product;
    if (preview != null) {
      product = preview;
    } else if (stored is Map<String, dynamic>) {
      try {
        product = MarketProduct.fromJson(stored);
      } on FormatException {
        return null;
      }
    } else {
      return null;
    }

    final packName = value['pack'];
    if (packName == null) {
      return MarketCartItem(product: product, quantity: quantity);
    }
    final pack = productDetailFor(
      product,
    ).packs.where((p) => p.size.name == packName).firstOrNull;
    if (pack == null) return null;
    return MarketCartItem(
      product: product,
      quantity: quantity,
      pack: pack.isDefault ? null : pack,
    );
  }

  @override
  Future<void> write(List<MarketCartItem> items) async {
    final saved = jsonEncode({
      'version': _version,
      'items': [
        for (final item in items)
          {
            'product': item.product.toJson(),
            'pack': item.pack?.size.name,
            'quantity': item.quantity,
          },
      ],
    });
    if (!await _preferences.setString(storageKey, saved)) {
      throw StateError('Unable to save the basket on this device.');
    }
  }
}
