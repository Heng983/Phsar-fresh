/// When an order should arrive: express (as soon as possible) or a booked slot.
class DeliverySlot {
  const DeliverySlot.express() : start = null;
  const DeliverySlot(DateTime this.start);

  /// Null for express.
  final DateTime? start;

  bool get isExpress => start == null;
  DateTime? get end => start?.add(DeliverySchedule.slotLength);

  /// Plain text for the order note, e.g. "2026-10-27 10:00–12:00".
  String get noteLabel {
    final start = this.start;
    if (start == null) return 'Express (ASAP)';
    String two(int value) => value.toString().padLeft(2, '0');
    String time(DateTime value) => '${two(value.hour)}:${two(value.minute)}';
    return '${start.year}-${two(start.month)}-${two(start.day)} '
        '${time(start)}–${time(end!)}';
  }

  @override
  bool operator ==(Object other) =>
      other is DeliverySlot && other.start == start;

  @override
  int get hashCode => start.hashCode;
}

/// Shop hours and booking rules. Times are the shop's local time.
abstract final class DeliverySchedule {
  static const firstSlotHour = 8;
  static const lastSlotEndHour = 20;
  static const slotLength = Duration(hours: 2);

  /// Packing and riding time needed before a booked slot can start.
  static const leadTime = Duration(hours: 1);
  static const expressTime = Duration(minutes: 30);
  static const bookableDays = 3;

  static DateTime _at(DateTime day, int hour) =>
      DateTime(day.year, day.month, day.day, hour);

  /// Express runs while a rider can still arrive before closing.
  static bool expressOpen(DateTime now) =>
      now.hour >= firstSlotHour &&
      !now.add(expressTime).isAfter(_at(now, lastSlotEndHour));

  /// Slot start times on [day] that can still be booked at [now].
  static List<DateTime> slotsOn(DateTime day, DateTime now) {
    final earliest = now.add(leadTime);
    return [
      for (
        var hour = firstSlotHour;
        hour + slotLength.inHours <= lastSlotEndHour;
        hour += slotLength.inHours
      )
        if (!_at(day, hour).isBefore(earliest)) _at(day, hour),
    ];
  }

  /// The next [bookableDays] days that still have a free slot.
  static List<DateTime> days(DateTime now) {
    final result = <DateTime>[];
    for (var offset = 0; result.length < bookableDays; offset++) {
      final day = DateTime(now.year, now.month, now.day + offset);
      if (slotsOn(day, now).isNotEmpty) result.add(day);
    }
    return result;
  }

  static DateTime firstSlot(DateTime now) =>
      slotsOn(days(now).first, now).first;

  /// [chosen] while it can still be delivered; otherwise express when open,
  /// or the soonest slot.
  static DeliverySlot resolve(DeliverySlot? chosen, DateTime now) {
    final start = chosen?.start;
    if (start != null) {
      return start.isBefore(now.add(leadTime))
          ? DeliverySlot(firstSlot(now))
          : chosen!;
    }
    return expressOpen(now)
        ? const DeliverySlot.express()
        : DeliverySlot(firstSlot(now));
  }
}

enum CheckoutPayment { abaPay, card, cash }

class CheckoutPreferences {
  /// Null until the customer picks; see [DeliverySchedule.resolve].
  final DeliverySlot? delivery;
  final CheckoutPayment payment;
  final String instructions;
  final String recipient;
  final String phone;

  const CheckoutPreferences({
    this.delivery,
    this.payment = CheckoutPayment.abaPay,
    this.instructions = '',
    this.recipient = '',
    this.phone = '',
  });

  CheckoutPreferences copyWith({
    DeliverySlot? delivery,
    CheckoutPayment? payment,
    String? instructions,
    String? recipient,
    String? phone,
  }) => CheckoutPreferences(
    delivery: delivery ?? this.delivery,
    payment: payment ?? this.payment,
    instructions: instructions ?? this.instructions,
    recipient: recipient ?? this.recipient,
    phone: phone ?? this.phone,
  );
}
