import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/payment/domain/khqr_payment.dart';

/// [awaitingPayment]: an ABA KHQR order the customer hasn't paid yet.
enum OrderStatus {
  awaitingPayment,
  confirmed,
  packed,
  onTheWay,
  delivered,
  cancelled,
}

class MarketOrder {
  final String id;
  final DateTime placedAt;
  final DateTime? deliveredAt;
  final DateTime? estimatedArrival;
  final OrderStatus status;
  final List<MarketCartItem> items;
  final String address;
  final CheckoutPayment payment;
  final int deliveryInCents;
  final int discountInCents;
  final String? courierName;
  final bool leftAtReception;
  final bool isDemo;

  /// The server's order id (uuid); null for preview orders. [id] is the
  /// short reference shown to people, e.g. "PF-3F9A2C".
  final String? serverId;

  /// Today's version of each product (current price, in stock), by product
  /// id, so "Order again" never uses an old price.
  final Map<String, MarketProduct> reorderProducts;

  /// The latest ABA KHQR, for "Pay now" on an unpaid order.
  final KhqrPayment? khqr;

  const MarketOrder({
    required this.id,
    required this.placedAt,
    required this.status,
    required this.items,
    required this.address,
    required this.payment,
    this.deliveredAt,
    this.estimatedArrival,
    this.deliveryInCents = 100,
    this.discountInCents = 0,
    this.courierName,
    this.leftAtReception = false,
    this.isDemo = false,
    this.serverId,
    this.reorderProducts = const {},
    this.khqr,
  });

  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  int get itemCount => items.fold(0, (count, item) => count + item.quantity);

  int get subtotalInCents =>
      items.fold(0, (sum, item) => sum + item.priceInCents * item.quantity);

  int get totalInCents => subtotalInCents + deliveryInCents - discountInCents;
}
