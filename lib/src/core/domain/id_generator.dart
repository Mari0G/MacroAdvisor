import 'dart:math';

abstract interface class IdGenerator {
  String newId();
}

class RandomIdGenerator implements IdGenerator {
  RandomIdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String newId() {
    final parts = List<int>.generate(4, (_) => _random.nextInt(0x100000000));
    return '${_hex(parts[0], 8)}-${_hex(parts[1] >> 16, 4)}-'
        '${_hex(parts[1], 4)}-${_hex(parts[2] >> 16, 4)}-'
        '${_hex(parts[2], 4)}${_hex(parts[3], 8)}';
  }

  String _hex(int value, int width) => value
      .toUnsigned(32)
      .toRadixString(16)
      .padLeft(width, '0')
      .substring(0, width);
}
