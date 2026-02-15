import 'dart:math' as math;
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('f32', () {
    const be = NumberCodecConfig(endian: Endian.big);

    // f32 pi has reduced precision compared to f64 pi.
    // The single-precision representation of pi decodes as:
    const f32Pi = 3.1415927410125732;

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getF32Encoder();
        expect(encoder.fixedSize, equals(4));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getF32Encoder();
        assertValidEncode(encoder, 0, '00000000');
        assertValidEncode(encoder, 1, '0000803f');
        assertValidEncode(encoder, 42, '00002842');
        assertValidEncode(encoder, math.pi, 'db0f4940');
        assertValidEncode(encoder, -1, '000080bf');
        assertValidEncode(encoder, -42, '000028c2');
        assertValidEncode(encoder, -math.pi, 'db0f49c0');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getF32Encoder(be);
        assertValidEncode(encoder, 0, '00000000');
        assertValidEncode(encoder, 1, '3f800000');
        assertValidEncode(encoder, 42, '42280000');
        assertValidEncode(encoder, math.pi, '40490fdb');
        assertValidEncode(encoder, -1, 'bf800000');
        assertValidEncode(encoder, -42, 'c2280000');
        assertValidEncode(encoder, -math.pi, 'c0490fdb');
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getF32Decoder();
        expect(decoder.fixedSize, equals(4));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getF32Decoder();
        expect(decoder.decode(b('00000000')), equals(0.0));
        expect(decoder.decode(b('0000803f')), equals(1.0));
        expect(decoder.decode(b('00002842')), equals(42.0));
        expect(decoder.decode(b('db0f4940')), closeTo(math.pi, 0.0001));
        expect(decoder.decode(b('000080bf')), equals(-1.0));
        expect(decoder.decode(b('000028c2')), equals(-42.0));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getF32Decoder(be);
        expect(decoder.decode(b('00000000')), equals(0.0));
        expect(decoder.decode(b('3f800000')), equals(1.0));
        expect(decoder.decode(b('42280000')), equals(42.0));
        expect(decoder.decode(b('40490fdb')), closeTo(math.pi, 0.0001));
      });

      test('decodes with offset', () {
        final decoder = getF32Decoder();
        final (value, offset) = decoder.read(b('ffffff0000803f'), 3);
        expect(value, equals(1.0));
        expect(offset, equals(7));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getF32Codec();
        expect(codec.fixedSize, equals(4));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getF32Codec();
        assertValidFloat(codec, 0, '00000000');
        assertValidFloat(codec, 1, '0000803f');
        assertValidFloat(codec, 42, '00002842');
        assertValidFloat(codec, -1, '000080bf');
        assertValidFloat(codec, -42, '000028c2');
        // Pi loses precision through f32 round-trip
        assertValidFloat(codec, math.pi, 'db0f4940', f32Pi);
        assertValidFloat(codec, -math.pi, 'db0f49c0', -f32Pi);
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getF32Codec(be);
        assertValidFloat(codec, 0, '00000000');
        assertValidFloat(codec, 1, '3f800000');
        assertValidFloat(codec, 42, '42280000');
        assertValidFloat(codec, -1, 'bf800000');
        assertValidFloat(codec, -42, 'c2280000');
        assertValidFloat(codec, math.pi, '40490fdb', f32Pi);
        assertValidFloat(codec, -math.pi, 'c0490fdb', -f32Pi);
      });
    });
  });
}
