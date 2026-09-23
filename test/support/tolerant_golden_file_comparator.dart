import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Allows small renderer differences between Windows baselines and Linux CI.
void setUpTolerantGoldenFileComparator(
  String testFileName, {
  required double precisionTolerance,
}) {
  setUp(() {
    final previousComparator = goldenFileComparator;
    if (previousComparator is LocalFileComparator) {
      goldenFileComparator = _TolerantGoldenFileComparator(
        previousComparator,
        testFileName: testFileName,
        precisionTolerance: precisionTolerance,
      );
      addTearDown(() => goldenFileComparator = previousComparator);
    }
  });
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    LocalFileComparator original, {
    required String testFileName,
    required double precisionTolerance,
  }) : assert(
         precisionTolerance >= 0 && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       ),
       _precisionTolerance = precisionTolerance,
       super(original.basedir.resolve(testFileName));

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
