import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('boolean codec', () {
    test('encodes false as 0x00', () {
      final encoder = getBooleanEncoder();
      expect(hex(encoder.encode(false)), equals('00'));
    });

    test('encodes true as 0x01', () {
      final encoder = getBooleanEncoder();
      expect(hex(encoder.encode(true)), equals('01'));
    });

    test('decodes 0x00 as false', () {
      final decoder = getBooleanDecoder();
      expect(decoder.decode(b('00')), isFalse);
    });

    test('decodes 0x01 as true', () {
      final decoder = getBooleanDecoder();
      expect(decoder.decode(b('01')), isTrue);
    });

    test('decodes non-1 values as false', () {
      final decoder = getBooleanDecoder();
      expect(decoder.decode(b('02')), isFalse);
      expect(decoder.decode(b('ff')), isFalse);
    });

    test('roundtrips with codec', () {
      final codec = getBooleanCodec();
      expect(codec.decode(codec.encode(true)), isTrue);
      expect(codec.decode(codec.encode(false)), isFalse);
    });

    test('uses custom number codec for size', () {
      final codec = getBooleanCodec(size: getU32Codec());
      expect(hex(codec.encode(false)), equals('00000000'));
      expect(hex(codec.encode(true)), equals('01000000'));
      expect(codec.decode(b('00000000')), isFalse);
      expect(codec.decode(b('01000000')), isTrue);
    });
  });
}
