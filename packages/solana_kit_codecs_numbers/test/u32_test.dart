import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('u32', () {
    const be = NumberCodecConfig(endian: Endian.big);

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getU32Encoder();
        expect(encoder.fixedSize, equals(4));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getU32Encoder();
        assertValidEncode(encoder, 0, '00000000');
        assertValidEncode(encoder, 1, '01000000');
        assertValidEncode(encoder, 42, '2a000000');
        assertValidEncode(encoder, 0xffff, 'ffff0000');
        assertValidEncode(encoder, 4294967295, 'ffffffff');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getU32Encoder(be);
        assertValidEncode(encoder, 0, '00000000');
        assertValidEncode(encoder, 1, '00000001');
        assertValidEncode(encoder, 42, '0000002a');
        assertValidEncode(encoder, 0xffff, '0000ffff');
        assertValidEncode(encoder, 4294967295, 'ffffffff');
      });

      test('throws on out-of-range values', () {
        final encoder = getU32Encoder();
        assertRangeError(encoder, -1);
        assertRangeError(encoder, 4294967296);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getU32Decoder();
        expect(decoder.fixedSize, equals(4));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getU32Decoder();
        expect(decoder.decode(b('00000000')), equals(0));
        expect(decoder.decode(b('01000000')), equals(1));
        expect(decoder.decode(b('2a000000')), equals(42));
        expect(decoder.decode(b('ffff0000')), equals(0xffff));
        expect(decoder.decode(b('ffffffff')), equals(4294967295));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getU32Decoder(be);
        expect(decoder.decode(b('00000000')), equals(0));
        expect(decoder.decode(b('00000001')), equals(1));
        expect(decoder.decode(b('0000002a')), equals(42));
        expect(decoder.decode(b('0000ffff')), equals(0xffff));
        expect(decoder.decode(b('ffffffff')), equals(4294967295));
      });

      test('decodes with offset', () {
        final decoder = getU32Decoder();
        final (value, offset) = decoder.read(b('ffffff2a000000'), 3);
        expect(value, equals(42));
        expect(offset, equals(7));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getU32Codec();
        expect(codec.fixedSize, equals(4));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getU32Codec();
        assertValidInt(codec, 0, '00000000');
        assertValidInt(codec, 1, '01000000');
        assertValidInt(codec, 42, '2a000000');
        assertValidInt(codec, 0xffff, 'ffff0000');
        assertValidInt(codec, 4294967295, 'ffffffff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getU32Codec(be);
        assertValidInt(codec, 0, '00000000');
        assertValidInt(codec, 1, '00000001');
        assertValidInt(codec, 42, '0000002a');
        assertValidInt(codec, 0xffff, '0000ffff');
        assertValidInt(codec, 4294967295, 'ffffffff');
      });

      test('roundtrips boundary values', () {
        final codec = getU32Codec();
        assertValidInt(codec, 0, '00000000');
        assertValidInt(codec, 4294967295, 'ffffffff');
        assertValidInt(codec, 1, '01000000');
        assertValidInt(codec, 4294967294, 'feffffff');
      });
    });
  });
}
