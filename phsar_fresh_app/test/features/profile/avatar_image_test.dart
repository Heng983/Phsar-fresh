import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:phsar_fresh_app/features/profile/domain/model/avatar_image.dart';

void main() {
  test(
    'Preparation corrects camera orientation and removes location metadata',
    () {
      final source = img.Image(width: 120, height: 80);
      img.fill(source, color: img.ColorRgb8(40, 170, 80));
      source.exif.imageIfd.orientation = 6;
      source.exif.gpsIfd.gpsLatitude = 11.5;
      source.exif.gpsIfd.gpsLatitudeRef = 'N';
      final prepared = prepareAvatar(img.encodeJpg(source));
      expect(prepared.width, 80);
      expect(prepared.height, 120);
      final decoded = img.decodeJpg(prepared.bytes)!;
      expect(decoded.exif.imageIfd.orientation, isNull);
      expect(decoded.exif.gpsIfd.gpsLatitude, isNull);
    },
  );

  test(
    'Pan and zoom select the intended source region and produce a square JPEG',
    () {
      final source = img.Image(width: 400, height: 200);
      img.fill(source, color: img.ColorRgb8(255, 0, 0));
      img.fillRect(
        source,
        x1: 200,
        y1: 0,
        x2: 399,
        y2: 199,
        color: img.ColorRgb8(0, 0, 255),
      );
      final photo = prepareAvatar(img.encodePng(source));
      final left = img.decodeJpg(
        cropAvatar(
          AvatarCropRequest(photo: photo, zoom: 1, offsetX: .5, offsetY: 0),
        ),
      )!;
      final right = img.decodeJpg(
        cropAvatar(
          AvatarCropRequest(photo: photo, zoom: 2, offsetX: -1.5, offsetY: 0),
        ),
      )!;
      expect(left.width, 512);
      expect(left.height, 512);
      expect(left.getPixel(256, 256).r, greaterThan(230));
      expect(left.getPixel(256, 256).b, lessThan(30));
      expect(right.getPixel(256, 256).b, greaterThan(230));
      expect(right.getPixel(256, 256).r, lessThan(30));
    },
  );

  test(
    'Transparent input is composited on white rather than a black background',
    () {
      final source = img.Image(width: 12, height: 12, numChannels: 4);
      final photo = prepareAvatar(img.encodePng(source));
      final decoded = img.decodeJpg(photo.bytes)!;
      expect(decoded.getPixel(6, 6).r, greaterThan(245));
      expect(decoded.getPixel(6, 6).g, greaterThan(245));
      expect(decoded.getPixel(6, 6).b, greaterThan(245));
    },
  );

  test(
    'Malformed, oversized images and invalid crop parameters are rejected',
    () {
      expect(
        () => prepareAvatar(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
      expect(
        () => prepareAvatar(Uint8List(10 * 1024 * 1024 + 1)),
        throwsFormatException,
      );
      final source = img.Image(width: 8, height: 8);
      final photo = prepareAvatar(img.encodePng(source));
      expect(
        () => cropAvatar(
          AvatarCropRequest(photo: photo, zoom: 0, offsetX: 0, offsetY: 0),
        ),
        throwsArgumentError,
      );
      expect(
        () => cropAvatar(
          AvatarCropRequest(
            photo: photo,
            zoom: 1,
            offsetX: double.nan,
            offsetY: 0,
          ),
        ),
        throwsArgumentError,
      );
    },
  );
}
