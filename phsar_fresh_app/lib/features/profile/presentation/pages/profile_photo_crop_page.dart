import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/profile/domain/model/avatar_image.dart';

class ProfilePhotoCropPage extends StatefulWidget {
  const ProfilePhotoCropPage({super.key, required this.photo});
  final PreparedAvatar photo;

  static Future<Uint8List?> open(BuildContext context, PreparedAvatar photo) =>
      Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(builder: (_) => ProfilePhotoCropPage(photo: photo)),
      );

  @override
  State<ProfilePhotoCropPage> createState() => _ProfilePhotoCropPageState();
}

class _ProfilePhotoCropPageState extends State<ProfilePhotoCropPage> {
  double _zoom = 1;
  double _startZoom = 1;
  double _side = 1;
  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;
  bool _saving = false;
  String? _error;

  Offset _clampOffset(Offset offset, double zoom) {
    final scale =
        _side / math.min(widget.photo.width, widget.photo.height) * zoom;
    final maxX = math.max(0.0, (widget.photo.width * scale - _side) / 2);
    final maxY = math.max(0.0, (widget.photo.height * scale - _side) / 2);
    return Offset(offset.dx.clamp(-maxX, maxX), offset.dy.clamp(-maxY, maxY));
  }

  void _zoomTo(double zoom) => setState(() {
    _offset = _clampOffset(_offset * (zoom / _zoom), zoom);
    _zoom = zoom;
  });

  Future<void> _usePhoto() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final jpeg = await compute(
        cropAvatar,
        AvatarCropRequest(
          photo: widget.photo,
          zoom: _zoom,
          offsetX: _offset.dx / _side,
          offsetY: _offset.dy / _side,
        ),
      );
      if (mounted) Navigator.pop(context, jpeg);
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.profilePhotoInvalid);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.profileCropPhoto,
            style: const TextStyle(
              fontSize: AppFontSize.title,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.profileCropHint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSize.bodySmall,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final previous = _side;
                    _side = math.min(constraints.maxWidth, 360);
                    if (previous != _side) {
                      _offset = _clampOffset(
                        _offset * (_side / previous),
                        _zoom,
                      );
                    }
                    final scale =
                        _side /
                        math.min(widget.photo.width, widget.photo.height) *
                        _zoom;
                    final width = widget.photo.width * scale;
                    final height = widget.photo.height * scale;
                    return Center(
                      child: GestureDetector(
                        key: const Key('profile-crop-viewport'),
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _saving
                            ? null
                            : (details) {
                                _startZoom = _zoom;
                                _startOffset = _offset;
                                _startFocal =
                                    details.localFocalPoint -
                                    Offset(_side / 2, _side / 2);
                              },
                        onScaleUpdate: _saving
                            ? null
                            : (details) {
                                final zoom = (_startZoom * details.scale).clamp(
                                  1.0,
                                  4.0,
                                );
                                final focal =
                                    details.localFocalPoint -
                                    Offset(_side / 2, _side / 2);
                                setState(() {
                                  _offset = _clampOffset(
                                    focal -
                                        (_startFocal - _startOffset) *
                                            (zoom / _startZoom),
                                    zoom,
                                  );
                                  _zoom = zoom;
                                });
                              },
                        child: SizedBox(
                          width: _side,
                          height: _side,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Positioned(
                                  left: (_side - width) / 2 + _offset.dx,
                                  top: (_side - height) / 2 + _offset.dy,
                                  width: width,
                                  height: height,
                                  child: Image.memory(
                                    widget.photo.bytes,
                                    fit: BoxFit.fill,
                                    excludeFromSemantics: true,
                                  ),
                                ),
                                const Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(painter: _CropOverlay()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Icon(
                      Icons.zoom_out_rounded,
                      color: AppColors.primary,
                    ),
                    Expanded(
                      child: Slider(
                        key: const Key('profile-crop-zoom'),
                        value: _zoom,
                        min: 1,
                        max: 4,
                        label: '${_zoom.toStringAsFixed(1)}×',
                        semanticFormatterCallback: (value) =>
                            '${l10n.profilePhotoZoom} ${value.toStringAsFixed(1)}×',
                        onChanged: _saving ? null : _zoomTo,
                      ),
                    ),
                    const Icon(Icons.zoom_in_rounded, color: AppColors.primary),
                  ],
                ),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                          _zoom = 1;
                          _offset = Offset.zero;
                        }),
                  child: Text(l10n.profileResetCrop),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  key: const Key('profile-use-photo'),
                  onPressed: _saving ? null : _usePhoto,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(l10n.profileUsePhoto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropOverlay extends CustomPainter {
  const _CropOverlay();
  @override
  void paint(Canvas canvas, Size size) {
    final circle = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addOval(circle),
    );
    canvas.drawPath(
      outside,
      Paint()..color = Colors.black.withValues(alpha: .45),
    );
    canvas.drawOval(
      circle,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlay oldDelegate) => false;
}
