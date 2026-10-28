import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/data/cart_storage.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Fresh installs start with an empty basket', () async {
    final storage = LocalCartStorage(await SharedPreferences.getInstance());
    final container = ProviderContainer(
      overrides: [cartStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    expect(container.read(marketCartProvider), isEmpty);
  });

  test(
    'Latest quantities and selected packs survive a restart, including removal',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final storage = LocalCartStorage(preferences);
      final container = ProviderContainer(
        overrides: [cartStorageProvider.overrideWithValue(storage)],
      );
      final cart = container.read(marketCartProvider.notifier);
      final halfKg = productDetailFor(greensProduct).packs[1];
      cart.add(greensProduct, pack: halfKg);
      cart.add(greensProduct, pack: halfKg, quantity: 2);
      cart.add(fruitsProduct);
      cart.setQuantity(greensProduct.id, 4, packSize: halfKg.size);
      await cart.flush();
      container.dispose();

      final restarted = ProviderContainer(
        overrides: [
          cartStorageProvider.overrideWithValue(LocalCartStorage(preferences)),
        ],
      );
      addTearDown(restarted.dispose);
      final restored = restarted.read(marketCartProvider);
      expect(restored, hasLength(2));
      expect(restored.first.quantity, 4);
      expect(restored.first.pack?.size, halfKg.size);
      expect(restored.first.priceInCents, halfKg.priceInCents);
      final next = restarted.read(marketCartProvider.notifier);
      for (final item in restored) {
        next.setQuantity(item.product.id, 0, packSize: item.pack?.size);
      }
      await next.flush();
      expect(LocalCartStorage(preferences).read(), isEmpty);
    },
  );

  test(
    'Invalid stored entries are ignored and catalog prices are authoritative',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final storage = LocalCartStorage(preferences);
      for (final malformed in ['{', '[]', '{"version":2,"items":[]}']) {
        await preferences.setString(LocalCartStorage.storageKey, malformed);
        expect(storage.read(), isEmpty);
      }
      await preferences.setString(
        LocalCartStorage.storageKey,
        jsonEncode({
          'version': 1,
          'items': [
            {'product': 'missing', 'quantity': 1},
            {'product': 'greens', 'pack': 'missing', 'quantity': 1},
            {'product': 'greens', 'quantity': -1},
            {'product': 'greens', 'quantity': '2'},
            {'product': 'greens', 'quantity': 2, 'priceInCents': 1},
            {'product': 'greens', 'pack': 'kilogram', 'quantity': 1},
            {
              'product': 'eggs',
              'pack': 'dozenEggs',
              'quantity': 2,
              'priceInCents': 1,
            },
          ],
        }),
      );
      final items = storage.read();
      expect(items, hasLength(2));
      // Preview products ignore any stored price.
      expect(items.first.product.id, 'greens');
      expect(items.first.quantity, 3);
      expect(items.first.pack, isNull);
      expect(items.first.priceInCents, greensProduct.priceInCents);
      expect(items.last.priceInCents, greaterThan(1));
    },
  );

  test(
    'Server products are restored from their snapshot; preview prices are not',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final storage = LocalCartStorage(preferences);
      const pepper = MarketProduct(
        id: '9f1c2b7e-0000-4000-8000-000000000001',
        name: 'Kampot Pepper',
        nameKm: 'ម្រេចកំពត',
        origin: 'Kampot',
        unit: '100 g',
        priceInCents: 450,
        imageUrl: 'http://api.test:3000/uploads/pepper.jpg',
        category: ProductCategory(id: 'c1', name: 'Spices'),
      );
      await storage.write(const [
        MarketCartItem(product: pepper, quantity: 2),
        MarketCartItem(product: greensProduct),
      ]);
      // Tamper with the stored preview price; it must not be trusted.
      final saved = preferences
          .getString(LocalCartStorage.storageKey)!
          .replaceFirst('"priceCents":180', '"priceCents":1');
      await preferences.setString(LocalCartStorage.storageKey, saved);

      final restored = storage.read();
      expect(restored, hasLength(2));
      final server = restored.first;
      expect(server.product.id, pepper.id);
      expect(server.product.nameKm, 'ម្រេចកំពត');
      expect(server.product.category.name, 'Spices');
      expect(server.product.imageUrl, pepper.imageUrl);
      expect(server.quantity, 2);
      expect(server.priceInCents, 450);
      expect(restored.last.priceInCents, greensProduct.priceInCents);
    },
  );
}
