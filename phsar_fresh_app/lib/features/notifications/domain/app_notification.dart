/// What happened to an order, as the bell tells it.
enum OrderUpdate { placed, paid, preparing, delivering, delivered, cancelled }

enum AppNotificationType { order, promotion, message }

/// What a note from the market team is about.
enum StaffMessageKind { info, problem, cancelled }

/// One item of `GET /notifications`: an order update or a live promotion.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.at,
    this.orderId,
    this.orderCode,
    this.orderUpdate,
    this.title,
    this.titleKm,
    this.body,
    this.bodyKm,
    this.messageKind,
  });

  final String id;
  final AppNotificationType type;
  final DateTime at;

  final String? orderId;

  /// "PF-3F9A2C"
  final String? orderCode;
  final OrderUpdate? orderUpdate;

  /// A staff message's kind; its text is in [body].
  final StaffMessageKind? messageKind;

  /// A promotion's own words (or a staff message's text in [body]).
  final String? title;
  final String? titleKm;
  final String? body;
  final String? bodyKm;

  /// Worth a pop-up when it arrives. Placing and paying already show their
  /// own confirmation in checkout.
  bool get alerts =>
      orderUpdate != OrderUpdate.placed && orderUpdate != OrderUpdate.paid;

  static AppNotification? tryParse(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final id = value['id'];
    final at = DateTime.tryParse('${value['at']}')?.toLocal();
    if (id is! String || at == null) return null;
    String? text(Map<String, dynamic> json, String key) =>
        json[key] is String ? json[key] as String : null;

    final order = value['order'];
    if (value['type'] == 'ORDER' && order is Map<String, dynamic>) {
      final update = switch (order['status']) {
        'PENDING' => OrderUpdate.placed,
        'PAID' => OrderUpdate.paid,
        'PREPARING' => OrderUpdate.preparing,
        'DELIVERING' => OrderUpdate.delivering,
        'DELIVERED' => OrderUpdate.delivered,
        'CANCELLED' => OrderUpdate.cancelled,
        _ => null,
      };
      final orderId = text(order, 'id');
      final code = text(order, 'code');
      if (update == null || orderId == null || code == null) return null;
      return AppNotification(
        id: id,
        type: AppNotificationType.order,
        at: at,
        orderId: orderId,
        orderCode: code,
        orderUpdate: update,
      );
    }
    final message = value['message'];
    if (value['type'] == 'MESSAGE' &&
        order is Map<String, dynamic> &&
        message is Map<String, dynamic>) {
      final orderId = text(order, 'id');
      final code = text(order, 'code');
      final body = text(message, 'body');
      if (orderId == null || code == null || body == null) return null;
      return AppNotification(
        id: id,
        type: AppNotificationType.message,
        at: at,
        orderId: orderId,
        orderCode: code,
        body: body,
        messageKind: switch (message['kind']) {
          'PROBLEM' => StaffMessageKind.problem,
          'CANCELLED' => StaffMessageKind.cancelled,
          _ => StaffMessageKind.info,
        },
      );
    }
    final promotion = value['promotion'];
    if (value['type'] == 'PROMOTION' && promotion is Map<String, dynamic>) {
      final title = text(promotion, 'title');
      if (title == null) return null;
      return AppNotification(
        id: id,
        type: AppNotificationType.promotion,
        at: at,
        title: title,
        titleKm: text(promotion, 'titleKm'),
        body: text(promotion, 'body'),
        bodyKm: text(promotion, 'bodyKm'),
      );
    }
    return null;
  }
}
