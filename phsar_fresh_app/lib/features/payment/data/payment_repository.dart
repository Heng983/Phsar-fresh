import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/features/payment/domain/khqr_payment.dart';

class PaymentException implements Exception {
  const PaymentException([this.message]);

  /// The server's words when it gave any (e.g. PayWay not set up).
  final String? message;
}

/// `GET/POST /orders/:id/payment` on the backend, which talks to ABA PayWay.
class PaymentRepository {
  const PaymentRepository(this._client);

  final ApiClient _client;

  /// The order's latest KHQR; the server asks PayWay while it is pending.
  Future<KhqrPayment> status(String orderId) =>
      _call(() => _client.dio.get<dynamic>('/orders/$orderId/payment'));

  /// A new KHQR, e.g. after the old one expired.
  Future<KhqrPayment> renew(String orderId) =>
      _call(() => _client.dio.post<dynamic>('/orders/$orderId/payment'));

  /// Test mode only: pays the current QR as if the customer scanned it.
  Future<KhqrPayment> testPay(String orderId) => _call(
    () => _client.dio.post<dynamic>('/orders/$orderId/payment/test-pay'),
  );

  Future<KhqrPayment> _call(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send().timeout(const Duration(seconds: 25));
      final payment = KhqrPayment.tryParse(response.data);
      if (payment == null) throw const PaymentException();
      return payment;
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map && body['message'] is String
          ? body['message'] as String
          : null;
      if (kDebugMode) {
        debugPrint(
          'Payment request failed: ${e.response?.statusCode} $message',
        );
      }
      throw PaymentException(message);
    } on TimeoutException {
      throw const PaymentException();
    }
  }
}
