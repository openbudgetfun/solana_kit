import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('u16', () {
    const be = NumberCodecConfig(endian: Endian.big);

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getU16Encoder();
        expect(encoder.fixedSize, equals(2));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getU16Encoder();
        assertValidEncode(encoder, 0, '0000');
        assertValidEncode(encoder, 1, '0100');
        assertValidEncode(encoder, 42, '2a00');
        assertValidEncode(encoder, 0xff, 'ff00');
        assertValidEncode(encoder, 65535, 'ffff');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getU16Encoder(be);
        assertValidEncode(encoder, 0, '0000');
        assertValidEncode(encoder, 1, '0001');
        assertValidEncode(encoder, 42, '002a');
        assertValidEncode(encoder, 0xff, '00ff');
        assertValidEncode(encoder, 65535, 'ffff');
      });

      test('throws on out-of-range values', () {
        final encoder = getU16Encoder();
        assertRangeError(encoder, -1);
        assertRangeError(encoder, 65536);
        assertRangeError(encoder, -100);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getU16Decoder();
        expect(decoder.fixedSize, equals(2));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getU16Decoder();
        expect(decoder.decode(b('0000')), equals(0));
        expect(decoder.decode(b('0100')), equals(1));
        expect(decoder.decode(b('2a00')), equals(42));
        expect(decoder.decode(b('ff00')), equals(255));
        expect(decoder.decode(b('ffff')), equals(65535));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getU16Decoder(be);
        expect(decoder.decode(b('0000')), equals(0));
        expect(decoder.decode(b('0001')), equals(1));
        expect(decoder.decode(b('002a')), equals(42));
        expect(decoder.decode(b('00ff')), equals(255));
        expect(decoder.decode(b('ffff')), equals(65535));
      });

      test('decodes with offset', () {
        final decoder = getU16Decoder();
        final (value, offset) = decoder.read(b('ffffff2a00'), 3);
        expect(value, equals(42));
        expect(offset, equals(5));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getU16Codec();
        expect(codec.fixedSize, equals(2));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getU16Codec();
        assertValidInt(codec, 0, '0000');
        assertValidInt(codec, 1, '0100');
        assertValidInt(codec, 42, '2a00');
        assertValidInt(codec, 0xff, 'ff00');
        assertValidInt(codec, 65535, 'ffff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getU16Codec(be);
        assertValidInt(codec, 0, '0000');
        assertValidInt(codec, 1, '0001');
        assertValidInt(codec, 42, '002a');
        assertValidInt(codec, 0xff, '00ff');
        assertValidInt(codec, 65535, 'ffff');
      });

      test('roundtrips boundary values', () {
        final codec = getU16Codec();
        assertValidInt(codec, 0, '0000');
        assertValidInt(codec, 65535, 'ffff');
        assertValidInt(codec, 1, '0100');
        assertValidInt(codec, 65534, 'feff');
      });
    });
  });
}
