import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/presentation/pages/cart_page.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/orders/presentation/pages/orders_page.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/order_details_sheet.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/orders_help_sheet.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/pump_helpers.dart';

Future<ProviderContainer> pumpOrders(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  String language = 'en',
  AppCurrency currency = AppCurrency.usd,
  List<MarketOrder>? orders,
  VoidCallback? onShop,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      ordersReferenceTimeProvider.overrideWithValue(DateTime(2026, 10, 16, 10)),
      if (orders != null) marketOrdersProvider.overrideWithValue(orders),
    ],
  );
  addTearDown(container.dispose);
  container.read(currencyProvider.notifier).select(currency);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightThemeFor(isKhmer: language == 'km'),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: OrdersPage(
                  onContinueShopping: onShop ?? () {},
                  onViewCart: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  test(
    'Orders separate active deliveries from history and totals match items',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final active = container.read(activeOrdersProvider);
      final past = container.read(pastOrdersProvider);
      expect(active.length, 1);
      expect(active.single.itemCount, 5);
      expect(active.single.totalInCents, 1280);
      expect(past.map((order) => order.totalInCents), [1160, 1860]);
      expect(past.first.placedAt.isAfter(past.last.placedAt), isTrue);
    },
  );

  test('Reorder uses current catalog prices and preserves pack quantities', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final oldOrder = MarketOrder(
      id: 'OLD',
      placedAt: DateTime(2025),
      status: OrderStatus.delivered,
      items: const [
        MarketCartItem(
          product: MarketProduct(
            id: 'greens',
            name: 'Greens (old price)',
            unit: 'kg',
            priceInCents: 999,
            category: vegetablesCategory,
          ),
          quantity: 3,
          pack: ProductPackOption(
            size: ProductPackSize.halfKg,
            priceInCents: 45,
          ),
        ),
      ],
      address: 'Phnom Penh',
      payment: CheckoutPayment.cash,
    );
    expect(container.read(reorderProvider)(oldOrder), 3);
    final item = container
        .read(marketCartProvider)
        .singleWhere((item) => item.pack?.size == ProductPackSize.halfKg);
    expect(item.quantity, 3);
    expect(item.priceInCents, 90);
    expect(oldOrder.items.single.priceInCents, 45);
  });

  testWidgets('Tracking, history, receipt and help open the correct content', (
    tester,
  ) async {
    final container = await pumpOrders(tester);
    expect(find.text('Sample orders · Tracking preview'), findsOneWidget);
    await reveal(tester, find.byKey(const Key('order-details-PF-88219')));
    await tester.tap(find.byKey(const Key('order-details-PF-88219')));
    await tester.pumpAndSettle();
    expect(find.byType(OrderDetailsSheet), findsOneWidget);
    expect(find.text('Order #PF-88219').hitTestable(), findsOneWidget);
    Navigator.of(tester.element(find.byType(OrderDetailsSheet))).pop();
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('orders-see-history')));
    await tester.tap(find.byKey(const Key('orders-see-history')));
    await tester.pumpAndSettle();
    expect(find.text('My orders').hitTestable(), findsOneWidget);
    expect(container.read(ordersViewProvider), OrdersView.history);
    expect(find.byKey(const Key('active-order-PF-88219')), findsNothing);
    await reveal(tester, find.byKey(const Key('order-receipt-PF-79102')));
    await tester.tap(find.byKey(const Key('order-receipt-PF-79102')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<OrderDetailsSheet>(find.byType(OrderDetailsSheet)).order.id,
      'PF-79102',
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('order-receipt-total')),
        matching: find.text(r'$11.60'),
      ),
      findsOneWidget,
    );
    Navigator.of(tester.element(find.byType(OrderDetailsSheet))).pop();
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const Key('orders-help')));
    await tester.tap(find.byKey(const Key('orders-help')));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersHelpSheet), findsOneWidget);
    await tester.tap(find.text('Where is my delivery?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Open order details to review'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reorder opens the basket with the original quantities added', (
    tester,
  ) async {
    await pumpMarket(tester);
    await tester.tap(find.byKey(const Key('market-tab-orders')));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OrdersPage)),
    );
    await reveal(tester, find.byKey(const Key('order-reorder-PF-79102')));
    await tester.tap(find.byKey(const Key('order-reorder-PF-79102')));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(container.read(marketCartCountProvider), 7);
    expect(
      container
          .read(marketCartProvider)
          .singleWhere((item) => item.product.id == 'rice')
          .quantity,
      2,
    );
    expect(container.read(marketOrdersProvider).length, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty history and active states can continue shopping', (
    tester,
  ) async {
    var shopped = false;
    await pumpOrders(tester, orders: [], onShop: () => shopped = true);
    expect(find.text('No orders yet'), findsOneWidget);
    expect(find.text('Sample orders · Tracking preview'), findsNothing);
    await reveal(tester, find.text('Continue shopping'));
    await tester.tap(find.text('Continue shopping'));
    expect(shopped, isTrue);
    await reveal(tester, find.byKey(const Key('orders-tab-history')));
    await tester.tap(find.byKey(const Key('orders-tab-history')));
    await tester.pumpAndSettle();
    expect(find.text('Your story starts with a basket'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'km']) {
    for (final currency in AppCurrency.values) {
      for (final width in [320.0, 720.0]) {
        testWidgets(
          'Orders fit $language ${currency.name} at $width with larger text',
          (tester) async {
            await pumpOrders(
              tester,
              width: width,
              language: language,
              currency: currency,
              scale: 1.5,
            );
            await reveal(
              tester,
              find.byKey(const Key('order-details-PF-88219')),
            );
            expect(tester.takeException(), isNull);
            await tester.tap(find.byKey(const Key('order-details-PF-88219')));
            await tester.pumpAndSettle();
            await reveal(tester, find.byKey(const Key('order-receipt-total')));
            expect(
              find.descendant(
                of: find.byKey(const Key('order-receipt-total')),
                matching: find.text(currency.format(1280, language)),
              ),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
            Navigator.of(tester.element(find.byType(OrderDetailsSheet))).pop();
            await tester.pumpAndSettle();
            await reveal(
              tester,
              find.byKey(const Key('order-receipt-PF-79102')),
            );
            expect(tester.takeException(), isNull);
            await reveal(tester, find.byKey(const Key('orders-help')));
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
