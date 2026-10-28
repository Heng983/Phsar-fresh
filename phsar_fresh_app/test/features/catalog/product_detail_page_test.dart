import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/product_favorites_provider.dart';

import '../../support/market_test_fixtures.dart';
import '../../support/pump_helpers.dart';

void main() {
  for (final language in ['en', 'km']) {
    for (final width in [320.0, 375.0, 720.0]) {
      testWidgets('Product detail fits $language at $width', (tester) async {
        await pumpDetail(
          tester,
          width: width,
          language: language,
          scale: width == 320 ? 1.4 : 1,
        );
        expect(tester.takeException(), isNull);
        for (final key in [
          'product-view-farm',
          'product-pack-halfKg',
          'product-quantity-plus',
        ]) {
          await tester.ensureVisible(find.byKey(Key(key)));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  for (final language in ['en', 'km']) {
    testWidgets('Product detail names the category above the title in '
        '$language', (tester) async {
      await pumpDetail(tester, language: language, product: riceProduct);
      final eyebrow = tester.widget<Text>(
        find.byKey(const Key('product-detail-eyebrow')),
      );
      expect(
        eyebrow.data,
        language == 'km' ? riceCategory.nameKm : riceCategory.name,
      );
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('Explore taps open the selected product and preserve search', (
    tester,
  ) async {
    await pumpMarket(tester, explore: true);
    await tester.enterText(find.byKey(const Key('market-search')), 'rice');
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('explore-results-rice'));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ProductDetailPage>(find.byType(ProductDetailPage))
          .product
          .id,
      'rice',
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailPage), findsNothing);
    expect(card, findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('market-search')))
          .controller!
          .text,
      'rice',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Selected pack and quantity update subtotal and basket', (
    tester,
  ) async {
    await pumpDetail(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductDetailPage)),
    );
    await tester.ensureVisible(find.byKey(const Key('product-pack-halfKg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-pack-halfKg')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('product-quantity-plus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-quantity-plus')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('product-detail-total'))).data,
      '\$1.80',
    );
    await tester.tap(find.byKey(const Key('product-detail-add')));
    await tester.pumpAndSettle();
    final lines = container.read(marketCartProvider);
    final halfKilo = lines.singleWhere(
      (item) => item.pack?.size == ProductPackSize.halfKg,
    );
    expect(halfKilo.quantity, 2);
    expect(halfKilo.priceInCents, 90);
    expect(
      lines
          .singleWhere(
            (item) => item.product.id == 'greens' && item.pack == null,
          )
          .quantity,
      1,
    );
    expect(container.read(marketCartCountProvider), 5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Favorite and farm actions work', (tester) async {
    await pumpDetail(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductDetailPage)),
    );
    await tester.tap(find.byKey(const Key('product-detail-favorite')));
    await tester.pumpAndSettle();
    expect(container.read(productFavoritesProvider), contains('greens'));
    await tester.ensureVisible(find.byKey(const Key('product-view-farm')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-view-farm')));
    await tester.pumpAndSettle();
    expect(find.text('From the farm to your kitchen'), findsOneWidget);
    Navigator.of(
      tester.element(find.text('From the farm to your kitchen')),
    ).pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('Pack variants merge and remove independently from default packs', () {
    final container = ProviderContainer(overrides: [seededCartOverride]);
    addTearDown(container.dispose);
    final cart = container.read(marketCartProvider.notifier);
    final packs = productDetailFor(greensProduct).packs;
    final half = packs.singleWhere(
      (pack) => pack.size == ProductPackSize.halfKg,
    );
    cart.add(
      greensProduct,
      pack: packs.singleWhere((pack) => pack.isDefault),
      quantity: 2,
    );
    cart.add(greensProduct, pack: half, quantity: 3);
    cart.add(greensProduct, pack: half);
    final greens = container
        .read(marketCartProvider)
        .where((item) => item.product.id == 'greens')
        .toList();
    expect(greens.length, 2);
    expect(greens.singleWhere((item) => item.pack == null).quantity, 3);
    expect(greens.singleWhere((item) => item.pack != null).quantity, 4);
    cart.setQuantity('greens', 0, packSize: ProductPackSize.halfKg);
    expect(
      container
          .read(marketCartProvider)
          .where((item) => item.product.id == 'greens')
          .single
          .quantity,
      3,
    );
  });
}
