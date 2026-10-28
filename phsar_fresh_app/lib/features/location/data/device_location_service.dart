import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationProblem { permissionDenied, permissionBlocked, servicesDisabled }

class LocationFailure implements Exception {
  const LocationFailure(this.problem);
  final LocationProblem problem;
}

class LocationFix {
  const LocationFix(this.latitude, this.longitude, this.accuracy);
  final double latitude;
  final double longitude;
  final double accuracy;
}

class DeviceLocationService {
  LocationSettings _settings({Duration? timeLimit}) =>
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS
      ? AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
          timeLimit: timeLimit,
          allowBackgroundLocationUpdates: false,
        )
      : LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
          timeLimit: timeLimit,
        );

  Future<void> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(LocationProblem.servicesDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationProblem.permissionBlocked);
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw const LocationFailure(LocationProblem.permissionDenied);
    }
  }

  Future<LocationFix> current() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: _settings(timeLimit: const Duration(seconds: 15)),
    );
    return LocationFix(
      position.latitude,
      position.longitude,
      position.accuracy,
    );
  }

  Stream<LocationFix> watch() => Geolocator.getPositionStream(
    locationSettings: _settings(),
  ).map((p) => LocationFix(p.latitude, p.longitude, p.accuracy));

  Future<String?> addressFor(
    double latitude,
    double longitude,
    Locale locale,
  ) async {
    final places = await Geocoding()
        .placemarkFromCoordinates(latitude, longitude, locale: locale)
        .timeout(const Duration(seconds: 8));
    if (places.isEmpty) return null;
    final place = places.first;
    final parts = <String>{
      if (place.street?.isNotEmpty == true) place.street!,
      if (place.subLocality?.isNotEmpty == true) place.subLocality!,
      if (place.locality?.isNotEmpty == true) place.locality!,
      if (place.administrativeArea?.isNotEmpty == true &&
          place.administrativeArea != place.locality)
        place.administrativeArea!,
    };
    return parts.isEmpty ? null : parts.join(', ');
  }

  Future<LocationFix?> search(String address, Locale locale) async {
    final results = await Geocoding()
        .locationFromAddress(address, locale: locale)
        .timeout(const Duration(seconds: 10));
    if (results.isEmpty) return null;
    return LocationFix(results.first.latitude, results.first.longitude, 0);
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}

final deviceLocationServiceProvider = Provider<DeviceLocationService>(
  (ref) => DeviceLocationService(),
);
