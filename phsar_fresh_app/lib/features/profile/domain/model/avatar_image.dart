import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class PreparedAvatar {
  const PreparedAvatar({
    required this.bytes,
    required this.width,
    required this.height,
  });
  final Uint8List bytes;
  final int width;
  final int height;
}

class AvatarCropRequest {
  const AvatarCropRequest({
    required this.photo,
    required this.zoom,
    required this.offsetX,
    required this.offsetY,
  });
  final PreparedAvatar photo;
  final double zoom;
  // Drag offsets expressed as fractions of the square preview width.
  final double offsetX;
  final double offsetY;
}

img.Image _decode(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
    throw const FormatException('Invalid image size');
  }
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (info == null ||
      info.width <= 0 ||
      info.height <= 0 ||
      info.width * info.height > 24000000) {
    throw const FormatException('Unsupported image');
  }
  final image = decoder!.decodeFrame(0);
  if (image == null) throw const FormatException('Unsupported image');
  return img.bakeOrientation(image);
}

// Copy pixels to a new image so EXIF/GPS and other source metadata are not saved.
Uint8List _jpeg(img.Image source) {
  final clean = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 3,
  );
  img.fill(clean, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(clean, source);
  return img.encodeJpg(clean, quality: 88);
}

PreparedAvatar prepareAvatar(Uint8List bytes) {
  var source = _decode(bytes);
  if (math.max(source.width, source.height) > 2048) {
    source = img.copyResize(
      source,
      width: source.width >= source.height ? 2048 : null,
      height: source.height > source.width ? 2048 : null,
    );
  }
  return PreparedAvatar(
    bytes: _jpeg(source),
    width: source.width,
    height: source.height,
  );
}

Uint8List cropAvatar(AvatarCropRequest request) {
  if (!request.zoom.isFinite ||
      request.zoom < 1 ||
      request.zoom > 4 ||
      !request.offsetX.isFinite ||
      !request.offsetY.isFinite) {
    throw ArgumentError('Invalid crop');
  }
  final source = _decode(request.photo.bytes);
  final side = (math.min(source.width, source.height) / request.zoom)
      .round()
      .clamp(1, math.min(source.width, source.height))
      .toInt();
  final x = ((source.width - side) / 2 - request.offsetX * side)
      .round()
      .clamp(0, source.width - side)
      .toInt();
  final y = ((source.height - side) / 2 - request.offsetY * side)
      .round()
      .clamp(0, source.height - side)
      .toInt();
  final cropped = img.copyCrop(source, x: x, y: y, width: side, height: side);
  return _jpeg(
    img.copyResize(
      cropped,
      width: 512,
      height: 512,
      interpolation: img.Interpolation.average,
    ),
  );
}
