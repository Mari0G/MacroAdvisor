import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/image_meal_photo_normalizer.dart';

void main() {
  final normalizer = ImageMealPhotoNormalizer();

  test('normalizes a source image to a bounded metadata-free JPEG', () async {
    final source = image.Image(width: 4096, height: 2048)
      ..clear(image.ColorRgb8(20, 30, 40));
    final marker = utf8.encode('source-path-and-metadata-must-not-survive');
    final sourceBytes = Uint8List.fromList([
      ...image.encodeJpg(source),
      ...marker,
    ]);

    final photo = await normalizer.normalize(sourceBytes);
    final decoded = image.decodeJpg(photo.jpegBytes);

    expect(photo.jpegBytes.length, lessThanOrEqualTo(MealPhoto.maximumBytes));
    expect(photo.width, 2048);
    expect(photo.height, 1024);
    expect(decoded, isNotNull);
    expect(decoded!.exif.isEmpty, isTrue);
    expect(
      utf8.decode(photo.jpegBytes, allowMalformed: true),
      isNot(contains('source-path-and-metadata-must-not-survive')),
    );
  });

  test('rejects unreadable source data before provider analysis', () async {
    await expectLater(
      normalizer.normalize(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<UnsupportedMealPhoto>()),
    );
  });

  test('derives an independent bounded retention JPEG at quality 70', () async {
    final source = image.Image(width: 1800, height: 1200)
      ..clear(image.ColorRgb8(90, 80, 70));
    final normalized = await normalizer.normalize(
      Uint8List.fromList(image.encodeJpg(source)),
    );

    final candidate = await normalizer.deriveRetentionCandidate(normalized);
    final decoded = image.decodeJpg(candidate.jpegBytes);

    expect(MealPhotoRetentionCandidate.mimeType, 'image/jpeg');
    expect(candidate.width, lessThanOrEqualTo(512));
    expect(candidate.height, lessThanOrEqualTo(512));
    expect(candidate.jpegBytes.length, lessThanOrEqualTo(256 * 1024));
    expect(decoded, isNotNull);
    expect(decoded!.exif.isEmpty, isTrue);
    expect(identical(candidate.jpegBytes, normalized.jpegBytes), isFalse);
  });
}
