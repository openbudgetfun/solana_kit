import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('slot hashes', () {
    test('decode', () {
      // From TS test: slot-hashes-test.ts
      final slotHashesState = Uint8List.fromList([
        // array length (u32)
        2, 0, 0, 0,
        // entry 1: slot
        134, 74, 2, 0, 0, 0, 0, 0,
        // entry 1: hash (32 bytes of 0x01)
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        // entry 2: slot
        134, 74, 2, 0, 0, 0, 0, 0,
        // entry 2: hash (32 bytes of 0x02)
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
      ]);

      final result = getSysvarSlotHashesCodec().decode(slotHashesState);
      expect(result, hasLength(2));
      expect(result[0].slot, equals(BigInt.from(150150)));
      expect(
        result[0].hash.value,
        equals('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
      );
      expect(result[1].slot, equals(BigInt.from(150150)));
      expect(
        result[1].hash.value,
        equals('8qbHbw2BbbTHBW1sbeqakYXVKRQM8Ne7pLK7m6CVfeR'),
      );
    });

    test('encode roundtrip', () {
      final entries = [
        SlotHashEntry(
          slot: BigInt.from(150150),
          hash: const Blockhash('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
        ),
        SlotHashEntry(
          slot: BigInt.from(150150),
          hash: const Blockhash('8qbHbw2BbbTHBW1sbeqakYXVKRQM8Ne7pLK7m6CVfeR'),
        ),
      ];

      final codec = getSysvarSlotHashesCodec();
      final encoded = codec.encode(entries);
      final decoded = codec.decode(encoded);

      expect(decoded, hasLength(2));
      expect(decoded[0].slot, equals(entries[0].slot));
      expect(decoded[0].hash.value, equals(entries[0].hash.value));
      expect(decoded[1].slot, equals(entries[1].slot));
      expect(decoded[1].hash.value, equals(entries[1].hash.value));
    });

    test('codec is variable-size', () {
      final codec = getSysvarSlotHashesCodec();
      expect(isFixedSize(codec), isFalse);
    });

    test('SlotHashEntry equality', () {
      final a = SlotHashEntry(
        slot: BigInt.from(100),
        hash: const Blockhash('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
      );
      final b = SlotHashEntry(
        slot: BigInt.from(100),
        hash: const Blockhash('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
