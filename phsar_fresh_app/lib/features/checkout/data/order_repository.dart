import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/features/cart/data/voucher_repository.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:phsar_fresh_app/features/payment/domain/khqr_payment.dart';

/// What the server saved.
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.totalInCents,
    this.payment,
    this.paymentError,
  });

  final String id;
  final int totalInCents;

  /// The ABA KHQR to pay, for ABA Pay orders.
  final KhqrPayment? payment;

  /// Why the KHQR couldn't be created (the order itself is saved).
  final String? paymentError;

  /// "PF-3F9A2C", the same short id the admin panel shows.
  String get code => 'PF-${id.substring(0, 6).toUpperCase()}';
}

enum OrderFailureKind { signInRequired, voucher, unavailable, network }

class OrderFailure implements Exception {
  const OrderFailure(this.kind, {this.voucher, this.message});

  final OrderFailureKind kind;

  /// Why the code was refused, when [kind] is [OrderFailureKind.voucher].
  final VoucherCheck? voucher;

  /// The server's own words, e.g. "Only 2 kg of Mango left".
  final String? message;
}

/// `POST /orders` — the server prices the basket, re-checks the voucher and
/// records its use in the same transaction as the order.
class OrderRepository {
  const OrderRepository(this._client);

  final ApiClient _client;

  Future<PlacedOrder> place({
    required List<MarketCartItem> items,
    required DeliveryLocation location,
    required CheckoutPreferences preferences,
    String? voucherCode,
  }) async {
    final note = [
      'Delivery: ${DeliverySchedule.resolve(preferences.delivery, DateTime.now()).noteLabel}',
      if (location.note.trim().isNotEmpty) location.note.trim(),
      if (preferences.instructions.trim().isNotEmpty)
        preferences.instructions.trim(),
    ].join(' · ');
    try {
      final response = await _client.dio
          .post<dynamic>(
            '/orders',
            data: {
              'items': [
                for (final item in items)
                  {'productId': item.product.id, 'qty': item.quantity},
              ],
              'address': {
                'lat': location.latitude,
                'lng': location.longitude,
                'text': location.fullAddress.replaceAll('\n', ', '),
              },
              'paymentMethod': switch (preferences.payment) {
                CheckoutPayment.abaPay => 'ABA_PAY',
                CheckoutPayment.card => 'CARD',
                CheckoutPayment.cash => 'CASH',
              },
              'voucherCode': ?voucherCode,
              if (preferences.recipient.isNotEmpty)
                'recipientName': preferences.recipient,
              if (preferences.phone.isNotEmpty)
                'recipientPhone': preferences.phone,
              'note': note,
            },
          )
          .timeout(const Duration(seconds: 30));
      final raw = response.data;
      final data = raw is Map<String, dynamic> ? raw : null;
      final id = data?['id'];
      final total = data?['totalCents'];
      if (id is! String || total is! num) {
        throw const OrderFailure(OrderFailureKind.network);
      }
      return PlacedOrder(
        id: id,
        totalInCents: total.toInt(),
        payment: KhqrPayment.tryParse(data?['payment']),
        paymentError: data?['paymentError'] is String
            ? data!['paymentError'] as String
            : null,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final message = body is Map && body['message'] is String
          ? body['message'] as String
          : null;
      if (status == 401) {
        throw const OrderFailure(OrderFailureKind.signInRequired);
      }
      if (status == 422 && body is Map && body['reason'] != null) {
        final min = body['minSubtotalCents'];
        throw OrderFailure(
          OrderFailureKind.voucher,
          voucher: VoucherCheck.refused(
            voucherProblemFromReason(body['reason']),
            minSubtotalInCents: min is num ? min.toInt() : null,
          ),
        );
      }
      if (status == 409 || status == 400) {
        throw OrderFailure(OrderFailureKind.unavailable, message: message);
      }
      if (kDebugMode) {
        debugPrint('Order failed: ${status ?? e.type} ${e.message}');
      }
      throw const OrderFailure(OrderFailureKind.network);
    } on OrderFailure {
      rethrow;
    } on Object catch (e) {
      if (kDebugMode) debugPrint('Order error: $e');
      throw const OrderFailure(OrderFailureKind.network);
    }
  }

  /// `POST /orders/:id/cancel` — the customer left the KHQR without paying,
  /// so the order gives back its stock and voucher. False when it turned out
  /// to be paid after all.
  Future<bool> cancelUnpaid(String orderId) async {
    try {
      await _client.dio
          .post<dynamic>('/orders/$orderId/cancel')
          .timeout(const Duration(seconds: 25));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return false;
      if (kDebugMode) debugPrint('Cancel failed: ${e.response?.statusCode}');
    } on TimeoutException {
      if (kDebugMode) debugPrint('Cancel timed out');
    }
    return true;
  }
}
