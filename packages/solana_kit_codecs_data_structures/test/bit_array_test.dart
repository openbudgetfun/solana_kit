import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('bit array codec', () {
    test('encodes booleans as bits (MSB-first)', () {
      final encoder = getBitArrayEncoder(1);
      final result = encoder.encode([
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
      ]);
      expect(hex(result), equals('a0'));
    });

    test('decodes bits as booleans (MSB-first)', () {
      final decoder = getBitArrayDecoder(1);
      final result = decoder.decode(b('a0'));
      expect(result, [true, false, true, false, false, false, false, false]);
    });

    test('encodes booleans as bits (LSB-first / backward)', () {
      final encoder = getBitArrayEncoder(1, backward: true);
      final result = encoder.encode([
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
      ]);
      expect(hex(result), equals('05'));
    });

    test('decodes bits as booleans (LSB-first / backward)', () {
      final decoder = getBitArrayDecoder(1, backward: true);
      final result = decoder.decode(b('05'));
      expect(result, [true, false, true, false, false, false, false, false]);
    });

    test('has fixed size', () {
      final codec = getBitArrayCodec(3);
      expect(isFixedSize(codec), isTrue);
      expect((codec as FixedSizeCodec).fixedSize, equals(3));
    });

    test('roundtrips with 2 bytes', () {
      final codec = getBitArrayCodec(2);
      final input = [
        true, false, true, true, false, false, true, false, // byte 0
        false, true, false, false, true, true, false, true, // byte 1
      ];
      final decoded = codec.decode(codec.encode(input));
      expect(decoded, equals(input));
    });

    test('pads missing booleans with false', () {
      final encoder = getBitArrayEncoder(1);
      // Only provide 3 booleans for 8 bits
      final result = encoder.encode([true, true, true]);
      expect(hex(result), equals('e0')); // 11100000
    });
  });
}
