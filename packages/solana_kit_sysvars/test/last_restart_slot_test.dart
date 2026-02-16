import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('last restart slot', () {
    test('decode', () {
      // From TS test: last-restart-slot-test.ts
      final lastRestartSlotState = Uint8List.fromList([
        119,
        233,
        246,
        16,
        0,
        0,
        0,
        0,
      ]);

      final result = getSysvarLastRestartSlotCodec().decode(
        lastRestartSlotState,
      );
      expect(result.lastRestartSlot, equals(BigInt.from(284617079)));
    });

    test('encode roundtrip', () {
      final lastRestartSlot = SysvarLastRestartSlot(
        lastRestartSlot: BigInt.from(284617079),
      );

      final codec = getSysvarLastRestartSlotCodec();
      final encoded = codec.encode(lastRestartSlot);
      final decoded = codec.decode(encoded);

      expect(decoded.lastRestartSlot, equals(lastRestartSlot.lastRestartSlot));
    });

    test('encoder has correct fixed size', () {
      final encoder = getSysvarLastRestartSlotEncoder();
      expect(encoder.fixedSize, equals(sysvarLastRestartSlotSize));
      expect(encoder.fixedSize, equals(8));
      expect(isFixedSize(encoder), isTrue);
    });

    test('SysvarLastRestartSlot equality', () {
      final a = SysvarLastRestartSlot(lastRestartSlot: BigInt.from(100));
      final b = SysvarLastRestartSlot(lastRestartSlot: BigInt.from(100));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
