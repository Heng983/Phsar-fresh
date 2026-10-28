import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/features/location/data/delivery_location_storage.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';

final deliveryLocationStorageProvider = Provider<DeliveryLocationStorage?>(
  (ref) => null,
);

class DeliveryLocationNotifier extends Notifier<DeliveryLocation> {
  @override
  DeliveryLocation build() =>
      ref.watch(deliveryLocationStorageProvider)?.read() ??
      DeliveryLocation.initial;

  Future<void> select(DeliveryLocation location) async {
    final saved = location.normalized();
    await ref.read(deliveryLocationStorageProvider)?.write(saved);
    state = saved;
  }
}

final deliveryLocationProvider =
    NotifierProvider<DeliveryLocationNotifier, DeliveryLocation>(
      DeliveryLocationNotifier.new,
    );

class MarketLocationNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(deliveryLocationProvider).label;

  Future<void> update(String location) {
    final current = ref.read(deliveryLocationProvider);
    return ref
        .read(deliveryLocationProvider.notifier)
        .select(
          current.label == location
              ? current
              : current.copyWith(label: location, clearCoordinates: true),
        );
  }
}

final marketLocationProvider = NotifierProvider<MarketLocationNotifier, String>(
  MarketLocationNotifier.new,
);
