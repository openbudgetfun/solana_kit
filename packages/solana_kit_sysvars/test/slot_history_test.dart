import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('slot history', () {
    test('decode', () {
      // From TS test: slot-history-test.ts
      final codec = getSysvarSlotHistoryCodec();
      final slotHistoryState = Uint8List(codec.fixedSize);
      // Fill all with 1s (for the bitvector data section).
      slotHistoryState.fillRange(0, slotHistoryState.length, 1);

      var offset = 0;
      // Discriminator
      slotHistoryState[offset] = bitvecDiscriminator;
      offset += 1;
      // Bitvector length: 0x4000 = 16384
      slotHistoryState.setAll(offset, [0, 64, 0, 0, 0, 0, 0, 0]);
      offset += 8;
      // Let the 1s represent the bits.
      offset += bitvecLength * 8;
      // Number of bits: 0x100000 = 1048576
      slotHistoryState.setAll(offset, [0, 0, 16, 0, 0, 0, 0, 0]);
      offset += 8;
      // Next slot: 150150
      slotHistoryState.setAll(offset, [134, 74, 2, 0, 0, 0, 0, 0]);

      final result = codec.decode(slotHistoryState);

      // Each u64 block is 0x0101010101010101 = 72340172838076673
      expect(result.bits, contains(BigInt.parse('72340172838076673')));
      expect(result.nextSlot, equals(BigInt.from(150150)));
    });

    test('encode roundtrip', () {
      // Create a minimal slot history with all zeros in bits.
      final bits = List<BigInt>.filled(bitvecLength, BigInt.zero);
      bits[0] = BigInt.from(0xff); // First block has first 8 bits set.
      final history = SysvarSlotHistory(bits: bits, nextSlot: BigInt.from(42));

      final codec = getSysvarSlotHistoryCodec();
      final encoded = codec.encode(history);
      final decoded = codec.decode(encoded);

      expect(decoded.bits[0], equals(BigInt.from(0xff)));
      expect(decoded.bits[1], equals(BigInt.zero));
      expect(decoded.nextSlot, equals(BigInt.from(42)));
      expect(decoded.bits.length, equals(bitvecLength));
    });

    test('encoder has correct fixed size', () {
      final encoder = getSysvarSlotHistoryEncoder();
      expect(encoder.fixedSize, equals(sysvarSlotHistorySize));
      expect(encoder.fixedSize, equals(131097));
      expect(isFixedSize(encoder), isTrue);
    });

    test('decoder has correct fixed size', () {
      final decoder = getSysvarSlotHistoryDecoder();
      expect(decoder.fixedSize, equals(sysvarSlotHistorySize));
      expect(isFixedSize(decoder), isTrue);
    });

    test('constants are correct', () {
      expect(bitvecDiscriminator, equals(1));
      expect(bitvecNumBits, equals(1048576));
      expect(bitvecLength, equals(16384));
      expect(sysvarSlotHistorySize, equals(131097));
    });

    test('SysvarSlotHistory equality', () {
      final bits1 = List<BigInt>.filled(bitvecLength, BigInt.zero);
      final bits2 = List<BigInt>.filled(bitvecLength, BigInt.zero);
      final a = SysvarSlotHistory(bits: bits1, nextSlot: BigInt.from(100));
      final b = SysvarSlotHistory(bits: bits2, nextSlot: BigInt.from(100));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
