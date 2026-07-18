import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idGeneratorProvider = Provider<IdGenerator>((ref) => RandomIdGenerator());
