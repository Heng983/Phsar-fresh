enum KhqrPaymentStatus { pending, approved, failed, expired }

/// One ABA PayWay KHQR for an order, as the backend returns it.
class KhqrPayment {
  const KhqrPayment({
    required this.orderId,
    required this.tranId,
    required this.status,
    required this.amountInCents,
    required this.currency,
    required this.expiresAt,
    this.qrString,
    this.deeplink,
    this.paymentType,
    this.testMode = false,
  });

  final String orderId;
  final String tranId;
  final KhqrPaymentStatus status;
  final int amountInCents;
  final String currency;
  final DateTime expiresAt;

  /// The KHQR payload: scannable by ABA Mobile and any KHQR bank app.
  final String? qrString;

  /// `abamobilebank://…` opens ABA Mobile on this phone with the payment ready.
  final String? deeplink;

  /// "ABA Pay" or "KHQR" once paid.
  final String? paymentType;

  /// The backend runs with PAYWAY_MOCK=true: the QR is fake and the payment
  /// is simulated with a button. No money moves.
  final bool testMode;

  bool get isPaid => status == KhqrPaymentStatus.approved;

  /// Still payable right now.
  bool isOpenAt(DateTime now) =>
      status == KhqrPaymentStatus.pending && expiresAt.isAfter(now);

  static KhqrPayment? tryParse(Object? json) {
    if (json is! Map) return null;
    final orderId = json['orderId'];
    final tranId = json['tranId'];
    final amount = json['amountCents'];
    final expires = DateTime.tryParse('${json['expiresAt']}');
    if (orderId is! String || tranId is! String || amount is! num) return null;
    if (expires == null) return null;
    return KhqrPayment(
      orderId: orderId,
      tranId: tranId,
      status: switch (json['status']) {
        'APPROVED' => KhqrPaymentStatus.approved,
        'FAILED' => KhqrPaymentStatus.failed,
        'EXPIRED' => KhqrPaymentStatus.expired,
        _ => KhqrPaymentStatus.pending,
      },
      amountInCents: amount.toInt(),
      currency: json['currency'] is String ? json['currency'] as String : 'USD',
      expiresAt: expires.toLocal(),
      qrString: json['qrString'] is String ? json['qrString'] as String : null,
      deeplink: json['deeplink'] is String ? json['deeplink'] as String : null,
      paymentType: json['paymentType'] is String
          ? json['paymentType'] as String
          : null,
      testMode: json['testMode'] == true,
    );
  }
}
