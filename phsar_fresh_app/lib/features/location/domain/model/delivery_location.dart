enum DeliveryAddressLabel { home, work, partner, other }

class DeliveryLocation {
  const DeliveryLocation({
    required this.label,
    this.latitude,
    this.longitude,
    this.houseNumber = '',
    this.street = '',
    this.note = '',
    this.addressLabel,
    this.customLabel = '',
  });

  static const initial = DeliveryLocation(label: 'Phnom Penh, BKK1');

  final String label;
  final double? latitude;
  final double? longitude;
  final String houseNumber;
  final String street;
  final String note;
  final DeliveryAddressLabel? addressLabel;
  final String customLabel;

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasDetails =>
      houseNumber.isNotEmpty ||
      street.isNotEmpty ||
      note.isNotEmpty ||
      addressLabel != null;

  String get fullAddress => [
    [houseNumber, street].where((part) => part.trim().isNotEmpty).join(', '),
    label,
  ].where((part) => part.trim().isNotEmpty).join('\n');

  DeliveryLocation copyWith({
    String? label,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
    String? houseNumber,
    String? street,
    String? note,
    DeliveryAddressLabel? addressLabel,
    bool clearAddressLabel = false,
    String? customLabel,
  }) => DeliveryLocation(
    label: label ?? this.label,
    latitude: clearCoordinates ? null : latitude ?? this.latitude,
    longitude: clearCoordinates ? null : longitude ?? this.longitude,
    houseNumber: houseNumber ?? this.houseNumber,
    street: street ?? this.street,
    note: note ?? this.note,
    addressLabel: clearAddressLabel ? null : addressLabel ?? this.addressLabel,
    customLabel: customLabel ?? this.customLabel,
  );

  DeliveryLocation normalized() => copyWith(
    label: label.trim(),
    houseNumber: houseNumber.trim(),
    street: street.trim(),
    note: note.trim(),
    customLabel: addressLabel == DeliveryAddressLabel.other
        ? customLabel.trim()
        : '',
  );

  DeliveryLocation withLabel(String value) => copyWith(label: value);
}
