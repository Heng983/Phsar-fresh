import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phsar_fresh_app/core/config/google_maps_config.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';

/// Allows widget tests to inspect map configuration without a native map view.
final deliveryGoogleMapBuilderProvider = Provider<Widget Function(GoogleMap)>(
  (ref) =>
      (map) => map,
);

class DeliveryLocationMap extends ConsumerStatefulWidget {
  const DeliveryLocationMap({
    super.key,
    required this.initialCenter,
    required this.selected,
    required this.current,
    required this.cameraTarget,
    required this.onSelect,
  });

  final LatLng initialCenter;
  final LatLng? selected;
  final LatLng? current;
  final LatLng? cameraTarget;
  final ValueChanged<LatLng> onSelect;

  @override
  ConsumerState<DeliveryLocationMap> createState() =>
      _DeliveryLocationMapState();
}

class _DeliveryLocationMapState extends ConsumerState<DeliveryLocationMap> {
  GoogleMapController? _controller;

  Future<void> _moveTo(LatLng? point) async {
    final controller = _controller;
    if (point == null || controller == null) return;
    try {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
    } catch (_) {
      // The map may have been closed before the camera animation completed.
    }
  }

  @override
  void didUpdateWidget(DeliveryLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cameraTarget != oldWidget.cameraTarget) {
      _moveTo(widget.cameraTarget);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(googleMapsConfiguredProvider)) {
      return ColoredBox(
        key: const Key('google-map-unavailable'),
        color: AppColors.inputBackground,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.locationMapUnavailable,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final map = GoogleMap(
      key: const Key('delivery-google-map'),
      initialCameraPosition: CameraPosition(
        target: widget.initialCenter,
        zoom: widget.selected == null ? 13 : 16,
      ),
      mapType: MapType.normal,
      minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
      onMapCreated: (controller) {
        _controller = controller;
        _moveTo(widget.cameraTarget);
      },
      onTap: widget.onSelect,
      // GPS is requested explicitly by the picker, never by creating the map.
      myLocationEnabled: widget.current != null,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: false,
      // Let the embedded map receive pan/pinch gestures inside the sheet.
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      markers: {
        if (widget.selected != null)
          Marker(
            markerId: const MarkerId('delivery-pin'),
            position: widget.selected!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            draggable: true,
            onDragEnd: widget.onSelect,
          ),
      },
    );
    return ref.watch(deliveryGoogleMapBuilderProvider)(map);
  }
}
