import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';

/// Preview records only. Replace the orders provider with authenticated API data
/// before displaying real purchase history or live courier updates.
List<MarketOrder> sampleMarketOrders(DateTime now) => [
  MarketOrder(
    id: 'PF-88219',
    placedAt: now.subtract(const Duration(minutes: 45)),
    estimatedArrival: now.add(const Duration(minutes: 20)),
    status: OrderStatus.onTheWay,
    items: const [
      MarketCartItem(product: greensProduct, quantity: 2),
      MarketCartItem(product: fruitsProduct),
      MarketCartItem(product: eggsProduct, quantity: 2),
    ],
    address: 'Street 302, BKK1, Phnom Penh',
    payment: CheckoutPayment.abaPay,
    courierName: 'Sokha',
    isDemo: true,
  ),
  MarketOrder(
    id: 'PF-79102',
    placedAt: now.subtract(const Duration(days: 1, hours: 1)),
    deliveredAt: now.subtract(const Duration(days: 1)),
    status: OrderStatus.delivered,
    items: [
      const MarketCartItem(product: riceProduct, quantity: 2),
      const MarketCartItem(product: spicesProduct),
      const MarketCartItem(product: fruitsProduct),
    ],
    address: 'Street 302, BKK1, Phnom Penh',
    payment: CheckoutPayment.abaPay,
    discountInCents: 150,
    leftAtReception: true,
    isDemo: true,
  ),
  MarketOrder(
    id: 'PF-74023',
    placedAt: now.subtract(const Duration(days: 7, hours: 1)),
    deliveredAt: now.subtract(const Duration(days: 7)),
    status: OrderStatus.delivered,
    items: [
      const MarketCartItem(product: fishProduct, quantity: 2),
      const MarketCartItem(product: citrusDealProduct),
      const MarketCartItem(product: greensProduct, quantity: 2),
    ],
    address: 'Street 302, BKK1, Phnom Penh',
    payment: CheckoutPayment.cash,
    isDemo: true,
  ),
];
