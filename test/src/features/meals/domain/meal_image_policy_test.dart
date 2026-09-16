import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_image_policy.dart';

void main() {
  test('retention bounds accept the boundary and reject invalid media', () {
    final bytes = Uint8List(MealImagePolicy.maximumBytes);
    bytes.setAll(0, [0xff, 0xd8, 0xff]);
    bool accepts({
      List<int>? data,
      int width = 512,
      int height = 512,
      String mime = 'image/jpeg',
    }) => MealImagePolicy.accepts(
      bytes: data ?? bytes,
      width: width,
      height: height,
      mime: mime,
    );
    expect(accepts(), isTrue);
    expect(accepts(data: [...bytes, 0]), isFalse);
    expect(accepts(width: 513), isFalse);
    expect(accepts(height: 513), isFalse);
    expect(accepts(width: 0), isFalse);
    expect(accepts(height: -1), isFalse);
    expect(accepts(mime: 'image/png'), isFalse);
    expect(accepts(data: [0xff, 0xd8]), isFalse);
    expect(accepts(data: [1, 2, 3]), isFalse);
  });
}
