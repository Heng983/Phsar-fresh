import 'dart:convert';

import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryLocationStorage {
  DeliveryLocationStorage(this.preferences);

  final SharedPreferences preferences;
  static const key = 'phsar_fresh.delivery_location.v1';

  DeliveryLocation read() {
    try {
      final saved = jsonDecode(preferences.getString(key) ?? 'null');
      if (saved is! Map || saved['label'] is! String) {
        return DeliveryLocation.initial;
      }
      final label = (saved['label'] as String).trim();
      if (label.isEmpty || label.characters.length > 200) {
        return DeliveryLocation.initial;
      }
      final lat = saved['latitude'];
      final lon = saved['longitude'];
      final valid =
          lat is num &&
          lon is num &&
          lat.isFinite &&
          lon.isFinite &&
          lat >= -90 &&
          lat <= 90 &&
          lon >= -180 &&
          lon <= 180;
      String detail(String name, int maxLength) {
        final value = saved[name];
        return value is String && value.characters.length <= maxLength
            ? value.trim()
            : '';
      }

      final addressLabel = DeliveryAddressLabel.values
          .where((value) => value.name == saved['addressLabel'])
          .firstOrNull;
      return DeliveryLocation(
        label: label,
        latitude: valid ? lat.toDouble() : null,
        longitude: valid ? lon.toDouble() : null,
        houseNumber: detail('houseNumber', 40),
        street: detail('street', 120),
        note: detail('note', 300),
        addressLabel: addressLabel,
        customLabel: addressLabel == DeliveryAddressLabel.other
            ? detail('customLabel', 30)
            : '',
      );
    } catch (_) {
      return DeliveryLocation.initial;
    }
  }

  Future<void> write(DeliveryLocation location) async {
    final saved = await preferences.setString(
      key,
      jsonEncode({
        'label': location.label,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'houseNumber': location.houseNumber,
        'street': location.street,
        'note': location.note,
        'addressLabel': location.addressLabel?.name,
        'customLabel': location.customLabel,
      }),
    );
    if (!saved) throw StateError('Unable to save delivery location.');
  }
}
