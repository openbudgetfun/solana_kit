import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('i16', () {
    const be = NumberCodecConfig(endian: Endian.big);

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getI16Encoder();
        expect(encoder.fixedSize, equals(2));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getI16Encoder();
        assertValidEncode(encoder, 0, '0000');
        assertValidEncode(encoder, 1, '0100');
        assertValidEncode(encoder, 42, '2a00');
        assertValidEncode(encoder, -1, 'ffff');
        assertValidEncode(encoder, -42, 'd6ff');
        assertValidEncode(encoder, -32768, '0080');
        assertValidEncode(encoder, 32767, 'ff7f');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getI16Encoder(be);
        assertValidEncode(encoder, 0, '0000');
        assertValidEncode(encoder, 1, '0001');
        assertValidEncode(encoder, 42, '002a');
        assertValidEncode(encoder, -1, 'ffff');
        assertValidEncode(encoder, -42, 'ffd6');
        assertValidEncode(encoder, -32768, '8000');
        assertValidEncode(encoder, 32767, '7fff');
      });

      test('throws on out-of-range values', () {
        final encoder = getI16Encoder();
        assertRangeError(encoder, -32769);
        assertRangeError(encoder, 32768);
        assertRangeError(encoder, -100000);
        assertRangeError(encoder, 100000);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getI16Decoder();
        expect(decoder.fixedSize, equals(2));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getI16Decoder();
        expect(decoder.decode(b('0000')), equals(0));
        expect(decoder.decode(b('0100')), equals(1));
        expect(decoder.decode(b('2a00')), equals(42));
        expect(decoder.decode(b('ffff')), equals(-1));
        expect(decoder.decode(b('d6ff')), equals(-42));
        expect(decoder.decode(b('0080')), equals(-32768));
        expect(decoder.decode(b('ff7f')), equals(32767));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getI16Decoder(be);
        expect(decoder.decode(b('0000')), equals(0));
        expect(decoder.decode(b('0001')), equals(1));
        expect(decoder.decode(b('002a')), equals(42));
        expect(decoder.decode(b('ffff')), equals(-1));
        expect(decoder.decode(b('ffd6')), equals(-42));
        expect(decoder.decode(b('8000')), equals(-32768));
        expect(decoder.decode(b('7fff')), equals(32767));
      });

      test('decodes with offset', () {
        final decoder = getI16Decoder();
        final (value, offset) = decoder.read(b('ffffffd6ff'), 3);
        expect(value, equals(-42));
        expect(offset, equals(5));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getI16Codec();
        expect(codec.fixedSize, equals(2));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getI16Codec();
        assertValidInt(codec, 0, '0000');
        assertValidInt(codec, 1, '0100');
        assertValidInt(codec, 42, '2a00');
        assertValidInt(codec, -1, 'ffff');
        assertValidInt(codec, -42, 'd6ff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getI16Codec(be);
        assertValidInt(codec, 0, '0000');
        assertValidInt(codec, 1, '0001');
        assertValidInt(codec, 42, '002a');
        assertValidInt(codec, -1, 'ffff');
        assertValidInt(codec, -42, 'ffd6');
      });

      test('roundtrips boundary values', () {
        final codec = getI16Codec();
        assertValidInt(codec, -32768, '0080');
        assertValidInt(codec, 32767, 'ff7f');
        assertValidInt(codec, -32767, '0180');
        assertValidInt(codec, 32766, 'fe7f');
      });
    });
  });
}
