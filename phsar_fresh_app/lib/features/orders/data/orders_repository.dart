import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/payment/domain/khqr_payment.dart';

enum OrdersProblem { signIn, network }

class OrdersException implements Exception {
  const OrdersException(this.problem);

  final OrdersProblem problem;
}

/// `GET /orders` — the signed-in customer's last 50 orders, newest first.
class OrdersRepository {
  const OrdersRepository(this._client);

  final ApiClient _client;

  Future<List<MarketOrder>> mine() async {
    try {
      final response = await _client.dio
          .get<dynamic>('/orders')
          .timeout(const Duration(seconds: 20));
      final data = response.data;
      if (data is! List) throw const OrdersException(OrdersProblem.network);
      return [for (final item in data) ?_parse(item)];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const OrdersException(OrdersProblem.signIn);
      }
      if (kDebugMode) {
        debugPrint('Orders failed: ${e.response?.statusCode ?? e.type}');
      }
      throw const OrdersException(OrdersProblem.network);
    } on TimeoutException {
      throw const OrdersException(OrdersProblem.network);
    }
  }

  /// One server order → the app's [MarketOrder]; null if it can't be read.
  MarketOrder? _parse(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    try {
      final id = raw['id'] as String;
      final method = raw['paymentMethod'];
      final khqr = KhqrPayment.tryParse(raw['payment']);
      final items = <MarketCartItem>[];
      final current = <String, MarketProduct>{};
      for (final item in raw['items'] as List) {
        final row = item as Map<String, dynamic>;
        final product = MarketProduct.fromJson(
          row['product'] as Map<String, dynamic>,
          resolveUrl: _client.resolveUrl,
        );
        current[product.id] = product;
        items.add(
          MarketCartItem(
            // What they bought, at the price they paid.
            product: MarketProduct(
              id: product.id,
              name: row['name'] is String
                  ? row['name'] as String
                  : product.name,
              nameKm: product.nameKm,
              origin: product.origin,
              unit: product.unit,
              unitKm: product.unitKm,
              priceInCents: (row['priceCents'] as num).toInt(),
              imageUrl: product.imageUrl,
              inStock: product.inStock,
              category: product.category,
            ),
            quantity: (row['qty'] as num).toInt(),
          ),
        );
      }
      final address = raw['address'];
      return MarketOrder(
        id: 'PF-${id.substring(0, 6).toUpperCase()}',
        serverId: id,
        placedAt: DateTime.parse(raw['createdAt'] as String).toLocal(),
        deliveredAt: raw['deliveredAt'] is String
            ? DateTime.parse(raw['deliveredAt'] as String).toLocal()
            : null,
        status: _status(raw['status'], method, khqr),
        items: items,
        address: address is Map && address['text'] is String
            ? address['text'] as String
            : '',
        payment: switch (method) {
          'ABA_PAY' => CheckoutPayment.abaPay,
          'CARD' => CheckoutPayment.card,
          _ => CheckoutPayment.cash,
        },
        deliveryInCents: (raw['deliveryCents'] as num?)?.toInt() ?? 0,
        discountInCents: (raw['discountCents'] as num?)?.toInt() ?? 0,
        courierName: raw['courierName'] is String
            ? raw['courierName'] as String
            : null,
        reorderProducts: current,
        khqr: khqr,
      );
    } on Object catch (e) {
      if (kDebugMode) debugPrint('Skipped an order the app could not read: $e');
      return null;
    }
  }

  static OrderStatus _status(
    Object? status,
    Object? method,
    KhqrPayment? khqr,
  ) => switch (status) {
    'PENDING' when method == 'ABA_PAY' && !(khqr?.isPaid ?? false) =>
      OrderStatus.awaitingPayment,
    'PENDING' || 'PAID' => OrderStatus.confirmed,
    'PREPARING' => OrderStatus.packed,
    'DELIVERING' => OrderStatus.onTheWay,
    'DELIVERED' => OrderStatus.delivered,
    _ => OrderStatus.cancelled,
  };
}
