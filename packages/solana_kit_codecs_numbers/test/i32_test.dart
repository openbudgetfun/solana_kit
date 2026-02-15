import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('i32', () {
    const be = NumberCodecConfig(endian: Endian.big);

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getI32Encoder();
        expect(encoder.fixedSize, equals(4));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getI32Encoder();
        assertValidEncode(encoder, 0, '00000000');
        assertValidEncode(encoder, 1, '01000000');
        assertValidEncode(encoder, 42, '2a000000');
        assertValidEncode(encoder, -1, 'ffffffff');
        assertValidEncode(encoder, -42, 'd6ffffff');
        assertValidEncode(encoder, -2147483648, '00000080');
        assertValidEncode(encoder, 2147483647, 'ffffff7f');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getI32Encoder(be);
        assertValidEncode(encoder, 0, '00000000');
        assertValidEncode(encoder, 1, '00000001');
        assertValidEncode(encoder, 42, '0000002a');
        assertValidEncode(encoder, -1, 'ffffffff');
        assertValidEncode(encoder, -42, 'ffffffd6');
        assertValidEncode(encoder, -2147483648, '80000000');
        assertValidEncode(encoder, 2147483647, '7fffffff');
      });

      test('throws on out-of-range values', () {
        final encoder = getI32Encoder();
        assertRangeError(encoder, -2147483649);
        assertRangeError(encoder, 2147483648);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getI32Decoder();
        expect(decoder.fixedSize, equals(4));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getI32Decoder();
        expect(decoder.decode(b('00000000')), equals(0));
        expect(decoder.decode(b('01000000')), equals(1));
        expect(decoder.decode(b('2a000000')), equals(42));
        expect(decoder.decode(b('ffffffff')), equals(-1));
        expect(decoder.decode(b('d6ffffff')), equals(-42));
        expect(decoder.decode(b('00000080')), equals(-2147483648));
        expect(decoder.decode(b('ffffff7f')), equals(2147483647));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getI32Decoder(be);
        expect(decoder.decode(b('00000000')), equals(0));
        expect(decoder.decode(b('00000001')), equals(1));
        expect(decoder.decode(b('0000002a')), equals(42));
        expect(decoder.decode(b('ffffffff')), equals(-1));
        expect(decoder.decode(b('ffffffd6')), equals(-42));
        expect(decoder.decode(b('80000000')), equals(-2147483648));
        expect(decoder.decode(b('7fffffff')), equals(2147483647));
      });

      test('decodes with offset', () {
        final decoder = getI32Decoder();
        final (value, offset) = decoder.read(b('ffffffd6ffffff'), 3);
        expect(value, equals(-42));
        expect(offset, equals(7));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getI32Codec();
        expect(codec.fixedSize, equals(4));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getI32Codec();
        assertValidInt(codec, 0, '00000000');
        assertValidInt(codec, 1, '01000000');
        assertValidInt(codec, 42, '2a000000');
        assertValidInt(codec, -1, 'ffffffff');
        assertValidInt(codec, -42, 'd6ffffff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getI32Codec(be);
        assertValidInt(codec, 0, '00000000');
        assertValidInt(codec, 1, '00000001');
        assertValidInt(codec, 42, '0000002a');
        assertValidInt(codec, -1, 'ffffffff');
        assertValidInt(codec, -42, 'ffffffd6');
      });

      test('roundtrips boundary values', () {
        final codec = getI32Codec();
        assertValidInt(codec, -2147483648, '00000080');
        assertValidInt(codec, 2147483647, 'ffffff7f');
        assertValidInt(codec, -2147483647, '01000080');
        assertValidInt(codec, 2147483646, 'feffff7f');
      });
    });
  });
}
