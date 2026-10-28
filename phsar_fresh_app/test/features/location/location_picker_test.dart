import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phsar_fresh_app/core/config/google_maps_config.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/location/data/delivery_location_storage.dart';
import 'package:phsar_fresh_app/features/location/data/device_location_service.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/delivery_location_map.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/market_location_sheet.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/location_test_fixtures.dart';

class FakeDeviceLocation extends DeviceLocationService {
  final updates = StreamController<LocationFix>.broadcast();
  Object? accessError;
  int accessRequests = 0;
  int settingsOpened = 0;
  bool failAddress = false;
  Completer<String?>? pendingAddress;

  @override
  Future<void> requestAccess() async {
    accessRequests++;
    if (accessError != null) throw accessError!;
  }

  @override
  Future<LocationFix> current() async => const LocationFix(11.55, 104.92, 8);
  @override
  Stream<LocationFix> watch() => updates.stream;
  @override
  Future<String?> addressFor(double lat, double lon, Locale locale) async {
    if (failAddress) throw StateError('No geocoder');
    return pendingAddress?.future ??
        'Street ${lat.toStringAsFixed(3)}, Phnom Penh';
  }

  @override
  Future<LocationFix?> search(String address, Locale locale) async =>
      address == 'Missing' ? null : const LocationFix(11.57, 104.91, 0);
  @override
  Future<bool> openAppSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    settingsOpened++;
    return true;
  }
}

Future<void> pumpPicker(
  WidgetTester tester,
  FakeDeviceLocation service, {
  ValueChanged<DeliveryLocation?>? onSaved,
  String language = 'en',
  double scale = 1,
  double width = 390,
  bool mapsConfigured = true,
  ValueChanged<GoogleMap>? onMapBuild,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deviceLocationServiceProvider.overrideWithValue(service),
        googleMapsConfiguredProvider.overrideWithValue(mapsConfigured),
        deliveryGoogleMapBuilderProvider.overrideWithValue((map) {
          onMapBuild?.call(map);
          return buildTestGoogleMap(map);
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.lightThemeFor(isKhmer: language == 'km'),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () async {
                  final result = await MarketLocationSheet.show(
                    context,
                    DeliveryLocation.initial,
                  );
                  onSaved?.call(result);
                },
                child: const Text('Open map'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open map'));
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  final save = find.byKey(const Key('location-save'));
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  late FakeDeviceLocation service;
  setUp(() => service = FakeDeviceLocation());
  tearDown(() => service.updates.close());

  testWidgets(
    'GPS is opt-in, follows live updates, and stops after confirmation',
    (tester) async {
      DeliveryLocation? saved;
      GoogleMap? nativeMap;
      await pumpPicker(
        tester,
        service,
        onSaved: (value) => saved = value,
        onMapBuild: (map) => nativeMap = map,
      );
      expect(service.accessRequests, 0);
      expect(nativeMap?.myLocationEnabled, isFalse);
      await tester.tap(find.byKey(const Key('location-use-current')));
      await tester.pump();
      expect(service.updates.hasListener, isTrue);
      expect(find.byKey(const Key('location-live')), findsOneWidget);
      service.updates.add(const LocationFix(11.551, 104.921, 6));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(nativeMap?.myLocationEnabled, isTrue);
      expect(nativeMap?.markers.single.position, const LatLng(11.551, 104.921));
      expect(nativeMap?.markers.single.draggable, isTrue);
      await tapSave(tester);
      expect(saved?.latitude, 11.551);
      expect(saved?.longitude, 104.921);
      expect(saved?.label, contains('Street 11.551'));
      expect(service.updates.hasListener, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Address details survive GPS and manual pin updates, and save trimmed',
    (tester) async {
      DeliveryLocation? saved;
      await pumpPicker(tester, service, onSaved: (value) => saved = value);
      Future<void> enter(String key, String value) async {
        final field = find.byKey(Key(key));
        await tester.ensureVisible(field);
        await tester.enterText(field, value);
        await tester.pumpAndSettle();
      }

      await tester.ensureVisible(find.byKey(const Key('location-label-other')));
      await tester.tap(find.byKey(const Key('location-label-other')));
      await tester.pumpAndSettle();
      await tapSave(tester);
      expect(saved, isNull);
      expect(find.text('Enter a name for this address.'), findsOneWidget);
      await enter('location-custom-label', ' Family house ');
      await enter('location-house-number', ' 12B ');
      await enter('location-street', ' Street 310 ');
      await enter('location-note', ' Second floor, ring the bell ');
      await tester.ensureVisible(find.byKey(const Key('location-use-current')));
      await tester.tap(find.byKey(const Key('location-use-current')));
      await tester.pump(const Duration(seconds: 1));
      expect(service.updates.hasListener, isTrue);
      tester
          .widget<DeliveryLocationMap>(find.byType(DeliveryLocationMap))
          .onSelect(const LatLng(11.58, 104.91));
      await tester.pump(const Duration(seconds: 1));
      await tapSave(tester);
      expect(saved?.latitude, 11.58);
      expect(saved?.longitude, 104.91);
      expect(saved?.addressLabel, DeliveryAddressLabel.other);
      expect(saved?.customLabel, 'Family house');
      expect(saved?.fullAddress, '12B, Street 310\nStreet 11.580, Phnom Penh');
      expect(saved?.note, 'Second floor, ring the bell');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('A missing Maps key keeps GPS and manual addresses usable', (
    tester,
  ) async {
    DeliveryLocation? saved;
    var createdNativeMap = false;
    await pumpPicker(
      tester,
      service,
      mapsConfigured: false,
      onMapBuild: (_) => createdNativeMap = true,
      onSaved: (value) => saved = value,
    );
    expect(find.byKey(const Key('google-map-unavailable')), findsOneWidget);
    expect(createdNativeMap, isFalse);
    await tester.tap(find.byKey(const Key('location-use-current')));
    await tester.pump(const Duration(seconds: 1));
    await tapSave(tester);
    expect(saved?.latitude, 11.55);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Manual pin selection stops GPS and survives a failed address lookup',
    (tester) async {
      DeliveryLocation? saved;
      service.failAddress = true;
      await pumpPicker(tester, service, onSaved: (value) => saved = value);
      await tester.tap(find.byKey(const Key('location-use-current')));
      await tester.pump();
      final map = tester.widget<DeliveryLocationMap>(
        find.byType(DeliveryLocationMap),
      );
      map.onSelect(const LatLng(11.6, 104.8));
      await tester.pump(const Duration(seconds: 1));
      service.updates.add(const LocationFix(11.9, 104.9, 5));
      await tester.pump();
      expect(service.updates.hasListener, isFalse);
      await tapSave(tester);
      expect(saved?.latitude, 11.6);
      expect(saved?.longitude, 104.8);
      expect(saved?.label, '11.60000, 104.80000');
      expect(tester.takeException(), isNull);
    },
  );

  for (final problem in LocationProblem.values) {
    testWidgets('$problem keeps manual selection available', (tester) async {
      service.accessError = LocationFailure(problem);
      await pumpPicker(tester, service);
      await tester.tap(find.byKey(const Key('location-use-current')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('location-error')), findsOneWidget);
      expect(service.updates.hasListener, isFalse);
      if (problem != LocationProblem.permissionDenied) {
        await tester.ensureVisible(find.text('Open settings'));
        await tester.tap(find.text('Open settings'));
        await tester.pumpAndSettle();
        expect(service.settingsOpened, 1);
      }
      tester
          .widget<DeliveryLocationMap>(find.byType(DeliveryLocationMap))
          .onSelect(const LatLng(11.58, 104.9));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('location-error')), findsNothing);
      await tapSave(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Old reverse-geocoding replies cannot overwrite a typed address',
    (tester) async {
      service.pendingAddress = Completer<String?>();
      DeliveryLocation? saved;
      await pumpPicker(tester, service, onSaved: (value) => saved = value);
      tester
          .widget<DeliveryLocationMap>(find.byType(DeliveryLocationMap))
          .onSelect(const LatLng(11.6, 104.8));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(
        find.byKey(const Key('location-address-input')),
        'My new address',
      );
      service.pendingAddress!.complete('Outdated address');
      await tester.pump();
      await tapSave(tester);
      expect(saved?.label, 'My new address');
      expect(saved?.hasCoordinates, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Address search locates a pin without requesting GPS permission',
    (tester) async {
      DeliveryLocation? saved;
      await pumpPicker(tester, service, onSaved: (value) => saved = value);
      await tester.enterText(
        find.byKey(const Key('location-address-input')),
        'Royal Palace, Phnom Penh',
      );
      await tester.ensureVisible(find.byKey(const Key('location-search')));
      await tester.tap(find.byKey(const Key('location-search')));
      await tester.pumpAndSettle();
      await tapSave(tester);
      expect(saved?.latitude, 11.57);
      expect(service.accessRequests, 0);
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['en', 'km']) {
    testWidgets('$language map picker fits narrow screens with larger text', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        service,
        language: language,
        width: 320,
        scale: 1.5,
      );
      await tester.ensureVisible(find.byKey(const Key('location-label-other')));
      await tester.tap(find.byKey(const Key('location-label-other')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('location-custom-label')),
      );
      await tester.enterText(
        find.byKey(const Key('location-custom-label')),
        language == 'km' ? 'ផ្ទះគ្រួសារ' : 'Family house',
      );
      await tester.ensureVisible(find.byKey(const Key('location-note')));
      await tester.enterText(
        find.byKey(const Key('location-note')),
        'Second floor, green gate by the market',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('location-save')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('location-save')).hitTestable(),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byKey(const Key('location-save'))).bottom,
        lessThanOrEqualTo(544),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  test(
    'Detailed addresses round trip and older records stay compatible',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = DeliveryLocationStorage(preferences);
      final container = ProviderContainer(
        overrides: [deliveryLocationStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);
      await container
          .read(deliveryLocationProvider.notifier)
          .select(
            const DeliveryLocation(
              label: ' Phnom Penh ',
              latitude: 11.55,
              longitude: 104.92,
              houseNumber: ' 12B ',
              street: ' Street 310 ',
              note: ' Green gate ',
              addressLabel: DeliveryAddressLabel.other,
              customLabel: ' Family house ',
            ),
          );
      final restored = storage.read();
      expect(restored.fullAddress, '12B, Street 310\nPhnom Penh');
      expect(restored.note, 'Green gate');
      expect(restored.customLabel, 'Family house');
      expect(restored.addressLabel, DeliveryAddressLabel.other);
      expect(restored.latitude, 11.55);
      final khmerNote = 'កា' * 300;
      await storage.write(
        DeliveryLocation(label: 'Phnom Penh', note: khmerNote),
      );
      expect(storage.read().note, khmerNote);

      await preferences.setString(
        DeliveryLocationStorage.key,
        jsonEncode({
          'label': 'Old address',
          'latitude': 11.55,
          'longitude': 104.92,
        }),
      );
      expect(storage.read().fullAddress, 'Old address');
      expect(storage.read().hasDetails, isFalse);
      expect(storage.read().hasCoordinates, isTrue);
      await preferences.setString(
        DeliveryLocationStorage.key,
        jsonEncode({
          'label': 'Old address',
          'addressLabel': 'unknown',
          'houseNumber': 42,
          'note': 'x' * 301,
        }),
      );
      expect(storage.read().addressLabel, isNull);
      expect(storage.read().houseNumber, isEmpty);
      expect(storage.read().note, isEmpty);
    },
  );

  test(
    'Confirmed pins persist and manual address changes clear old coordinates',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = DeliveryLocationStorage(preferences);
      final container = ProviderContainer(
        overrides: [deliveryLocationStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);
      await container
          .read(deliveryLocationProvider.notifier)
          .select(
            const DeliveryLocation(
              label: 'Home',
              houseNumber: '12B',
              street: 'Street 310',
              note: 'Green gate',
              addressLabel: DeliveryAddressLabel.home,
              latitude: 11.55,
              longitude: 104.92,
            ),
          );
      expect(storage.read().latitude, 11.55);
      expect(container.read(marketLocationProvider), 'Home');
      await container
          .read(marketLocationProvider.notifier)
          .update('New address');
      expect(storage.read().hasCoordinates, isFalse);
      expect(storage.read().houseNumber, '12B');
      expect(storage.read().street, 'Street 310');
      expect(storage.read().note, 'Green gate');
      expect(storage.read().addressLabel, DeliveryAddressLabel.home);
      final restored = ProviderContainer(
        overrides: [deliveryLocationStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(restored.dispose);
      expect(restored.read(marketLocationProvider), 'New address');
      await preferences.setString(
        DeliveryLocationStorage.key,
        jsonEncode({'label': 'Home', 'latitude': 999, 'longitude': 104.9}),
      );
      expect(storage.read().hasCoordinates, isFalse);
      await preferences.setString(DeliveryLocationStorage.key, 'broken');
      expect(storage.read().label, DeliveryLocation.initial.label);
    },
  );
}
