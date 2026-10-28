import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/voucher_rule.dart';

/// Why a code was refused.
enum VoucherProblem {
  invalid,
  notStarted,
  expired,
  minSubtotal,

  /// Welcome and once-per-customer codes need a signed-in account.
  loginRequired,

  /// Welcome code, but this account has already ordered.
  notNewCustomer,

  /// Once-per-customer code this account already used.
  alreadyUsed,
  network,
}

/// Maps the server's `reason` (see the backend's discount-rules.ts).
VoucherProblem voucherProblemFromReason(Object? reason) => switch (reason) {
  'NOT_STARTED' => VoucherProblem.notStarted,
  'EXPIRED' => VoucherProblem.expired,
  'MIN_SUBTOTAL' => VoucherProblem.minSubtotal,
  'LOGIN_REQUIRED' => VoucherProblem.loginRequired,
  'NOT_NEW_CUSTOMER' => VoucherProblem.notNewCustomer,
  'ALREADY_USED' => VoucherProblem.alreadyUsed,
  _ => VoucherProblem.invalid,
};

class VoucherCheck {
  const VoucherCheck.ok(VoucherRule this.rule)
    : problem = null,
      minSubtotalInCents = null;
  const VoucherCheck.refused(this.problem, {this.minSubtotalInCents})
    : rule = null;

  final VoucherRule? rule;
  final VoucherProblem? problem;

  /// Set when [problem] is [VoucherProblem.minSubtotal].
  final int? minSubtotalInCents;

  bool get isOk => rule != null;
}

/// `POST /discount-codes/check` — guests may call it; the server answers
/// whether the code works for this subtotal (and account) right now.
class VoucherRepository {
  const VoucherRepository(this._client);

  final ApiClient _client;

  Future<VoucherCheck> check(String code, int subtotalInCents) async {
    try {
      final response = await _client.dio
          .post<dynamic>(
            '/discount-codes/check',
            // Sent with the customer's token when signed in, so welcome codes
            // can be checked against their account.
            data: {'code': code, 'subtotalCents': subtotalInCents},
          )
          // Never leave the Apply button spinning, whatever the network does.
          .timeout(const Duration(seconds: 20));
      final raw = response.data;
      final data = raw is Map<String, dynamic> ? raw : null;
      if (data == null || data['code'] is! String || data['value'] is! num) {
        return const VoucherCheck.refused(VoucherProblem.network);
      }
      return VoucherCheck.ok(VoucherRule.fromJson(data));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      // A refusal carries a `reason`. A bare 404 means the server doesn't
      // have this endpoint yet (old backend still running) — not a bad code.
      if (status == 422 || (body is Map && body['reason'] != null)) {
        final reason = body is Map ? body['reason'] : null;
        final min = body is Map ? body['minSubtotalCents'] : null;
        return VoucherCheck.refused(
          voucherProblemFromReason(reason),
          minSubtotalInCents: min is num ? min.toInt() : null,
        );
      }
      if (kDebugMode) {
        debugPrint('Voucher check failed: ${status ?? e.type} ${e.message}');
      }
      return const VoucherCheck.refused(VoucherProblem.network);
    } on TimeoutException {
      if (kDebugMode) debugPrint('Voucher check timed out');
      return const VoucherCheck.refused(VoucherProblem.network);
    } on Object catch (e) {
      // e.g. an unexpected response shape: report it instead of hanging.
      if (kDebugMode) debugPrint('Voucher check error: $e');
      return const VoucherCheck.refused(VoucherProblem.network);
    }
  }
}
