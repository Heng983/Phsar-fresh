import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/location/data/device_location_service.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/address_details_fields.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/delivery_location_map.dart';

class MarketLocationSheet extends ConsumerStatefulWidget {
  const MarketLocationSheet({super.key, required this.location});
  final DeliveryLocation location;

  static Future<DeliveryLocation?> show(
    BuildContext context,
    DeliveryLocation location,
  ) => showModalBottomSheet<DeliveryLocation>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => MarketLocationSheet(location: location),
  );

  @override
  ConsumerState<MarketLocationSheet> createState() =>
      _MarketLocationSheetState();
}

class _MarketLocationSheetState extends ConsumerState<MarketLocationSheet>
    with WidgetsBindingObserver {
  LatLng? _cameraTarget;
  final _form = GlobalKey<FormState>();
  late DeliveryLocation _details;
  late final TextEditingController _controller;
  late final LatLng _initialCenter;
  LatLng? _selected;
  LatLng? _current;
  StreamSubscription<LocationFix>? _positions;
  Timer? _addressTimer;
  bool _locating = false;
  bool _searching = false;
  bool _following = false;
  bool _resolving = false;
  double? _accuracy;
  String? _error;
  LocationProblem? _problem;
  int _request = 0;
  int _addressRequest = 0;

  DeviceLocationService get _service => ref.read(deviceLocationServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = TextEditingController(text: widget.location.label);
    _details = widget.location;
    if (widget.location.hasCoordinates) {
      _selected = LatLng(widget.location.latitude!, widget.location.longitude!);
    }
    _initialCenter = _selected ?? const LatLng(11.5564, 104.9282);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _following) {
      unawaited(_locate());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _request++;
      _locating = false;
      unawaited(_positions?.cancel());
      _positions = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _request++;
    _addressRequest++;
    _addressTimer?.cancel();
    unawaited(_positions?.cancel());
    _controller.dispose();
    super.dispose();
  }

  void _stopFollowing() {
    _request++;
    _following = false;
    _locating = false;
    unawaited(_positions?.cancel());
    _positions = null;
  }

  void _move(LatLng point) {
    setState(() => _cameraTarget = point);
  }

  void _select(LatLng point, {bool fromGps = false}) {
    if (!fromGps) _stopFollowing();
    final request = ++_addressRequest;
    _addressTimer?.cancel();
    setState(() {
      _selected = point;
      _error = null;
      _problem = null;
      _resolving = true;
      // Never keep the previous pin's address while a lookup is pending.
      _controller.text =
          '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    });
    _addressTimer = Timer(const Duration(milliseconds: 650), () async {
      String? address;
      try {
        address = await _service.addressFor(
          point.latitude,
          point.longitude,
          Localizations.localeOf(context),
        );
      } catch (_) {
        // Coordinates remain usable when native geocoding is unavailable.
      }
      if (!mounted || request != _addressRequest) return;
      setState(() {
        if (address?.isNotEmpty == true) _controller.text = address!;
        _resolving = false;
      });
    });
  }

  void _onFix(LocationFix fix) {
    if (!mounted || !_following) return;
    final point = LatLng(fix.latitude, fix.longitude);
    setState(() {
      _current = point;
      _accuracy = fix.accuracy;
      _locating = false;
    });
    _select(point, fromGps: true);
    _move(point);
  }

  Future<void> _locate() async {
    if (_locating) return;
    _stopFollowing();
    final request = ++_request;
    setState(() {
      _locating = true;
      _following = true;
      _error = null;
      _problem = null;
    });
    try {
      await _service.requestAccess();
      if (!mounted || request != _request) return;
      final fix = await _service.current();
      if (!mounted || request != _request) return;
      _onFix(fix);
      _positions = _service.watch().listen(
        (fix) {
          if (mounted && request == _request) _onFix(fix);
        },
        onError: (Object error) {
          if (mounted && request == _request) _locationError(error);
        },
      );
    } catch (error) {
      if (mounted && request == _request) _locationError(error);
    }
  }

  void _locationError(Object error) {
    _stopFollowing();
    final problem = error is LocationFailure ? error.problem : null;
    final l10n = context.l10n;
    setState(() {
      _problem = problem;
      _error = switch (problem) {
        LocationProblem.permissionDenied => l10n.locationPermissionDenied,
        LocationProblem.permissionBlocked => l10n.locationPermissionBlocked,
        LocationProblem.servicesDisabled => l10n.locationServicesDisabled,
        null => l10n.locationUnavailable,
      };
    });
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _searching) return;
    _stopFollowing();
    final request = ++_addressRequest;
    _addressTimer?.cancel();
    setState(() {
      _searching = true;
      _resolving = false;
      _error = null;
    });
    try {
      final result = await _service.search(
        query,
        Localizations.localeOf(context),
      );
      if (!mounted || request != _addressRequest) return;
      setState(() {
        if (result == null) {
          _error = context.l10n.locationSearchFailed;
        } else {
          _selected = LatLng(result.latitude, result.longitude);
        }
      });
      if (result != null) {
        _move(_selected!);
        FocusScope.of(context).unfocus();
      }
    } catch (_) {
      if (mounted && request == _addressRequest) {
        setState(() => _error = context.l10n.locationSearchFailed);
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _editAddress(String _) {
    _stopFollowing();
    _addressRequest++;
    _addressTimer?.cancel();
    setState(() {
      _selected = null;
      _resolving = false;
    });
  }

  void _save() {
    final invalid = _form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      unawaited(
        Scrollable.ensureVisible(
          invalid.first.context,
          duration: const Duration(milliseconds: 200),
          alignment: .2,
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      _details
          .copyWith(
            label: _controller.text.trim(),
            latitude: _selected?.latitude,
            longitude: _selected?.longitude,
            clearCoordinates: _selected == null,
          )
          .normalized(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        height: availableHeight * .9,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.marketDeliveryLocation,
                          style: const TextStyle(
                            fontSize: AppFontSize.headline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.locationMapHint,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: (availableHeight * .38).clamp(180.0, 340.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: DeliveryLocationMap(
                        initialCenter: _initialCenter,
                        selected: _selected,
                        current: _current,
                        cameraTarget: _cameraTarget,
                        onSelect: _select,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('location-use-current'),
                    onPressed: _locating ? null : _locate,
                    icon: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                    label: Text(
                      _locating
                          ? l10n.locationFinding
                          : l10n.locationUseCurrent,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  if (_following && _accuracy != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n.locationLiveAccuracy(_accuracy!.round()),
                        key: const Key('location-live'),
                        style: const TextStyle(
                          fontSize: AppFontSize.caption,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _error!,
                        key: const Key('location-error'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (_problem == LocationProblem.permissionBlocked ||
                      _problem == LocationProblem.servicesDisabled)
                    TextButton(
                      onPressed: () async {
                        try {
                          final opened =
                              _problem == LocationProblem.servicesDisabled
                              ? await _service.openLocationSettings()
                              : await _service.openAppSettings();
                          if (!opened && mounted) {
                            setState(() => _error = l10n.locationUnavailable);
                          }
                        } catch (_) {
                          if (mounted) {
                            setState(() => _error = l10n.locationUnavailable);
                          }
                        }
                      },
                      child: Text(l10n.locationOpenSettings),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('location-address-input'),
                    controller: _controller,
                    maxLength: 200,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: l10n.marketLocationLabel,
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        key: const Key('location-search'),
                        tooltip: l10n.locationSearch,
                        onPressed: _searching ? null : _search,
                        icon: _searching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                      ),
                    ),
                    onChanged: _editAddress,
                    onSubmitted: (_) => _search(),
                  ),
                  if (_resolving) const LinearProgressIndicator(minHeight: 2),
                  AddressDetailsFields(
                    value: _details,
                    onChanged: (details) => setState(() => _details = details),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('location-save'),
                    onPressed: _controller.text.trim().isEmpty ? null : _save,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.marketSaveLocation),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
