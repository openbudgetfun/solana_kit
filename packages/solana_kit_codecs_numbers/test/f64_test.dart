import 'dart:math' as math;
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('f64', () {
    const be = NumberCodecConfig(endian: Endian.big);

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getF64Encoder();
        expect(encoder.fixedSize, equals(8));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getF64Encoder();
        assertValidEncode(encoder, 0, '0000000000000000');
        assertValidEncode(encoder, 1, '000000000000f03f');
        assertValidEncode(encoder, 42, '0000000000004540');
        assertValidEncode(encoder, math.pi, '182d4454fb210940');
        assertValidEncode(encoder, -1, '000000000000f0bf');
        assertValidEncode(encoder, -42, '00000000000045c0');
        assertValidEncode(encoder, -math.pi, '182d4454fb2109c0');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getF64Encoder(be);
        assertValidEncode(encoder, 0, '0000000000000000');
        assertValidEncode(encoder, 1, '3ff0000000000000');
        assertValidEncode(encoder, 42, '4045000000000000');
        assertValidEncode(encoder, math.pi, '400921fb54442d18');
        assertValidEncode(encoder, -1, 'bff0000000000000');
        assertValidEncode(encoder, -42, 'c045000000000000');
        assertValidEncode(encoder, -math.pi, 'c00921fb54442d18');
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getF64Decoder();
        expect(decoder.fixedSize, equals(8));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getF64Decoder();
        expect(decoder.decode(b('0000000000000000')), equals(0.0));
        expect(decoder.decode(b('000000000000f03f')), equals(1.0));
        expect(decoder.decode(b('0000000000004540')), equals(42.0));
        expect(decoder.decode(b('182d4454fb210940')), equals(math.pi));
        expect(decoder.decode(b('000000000000f0bf')), equals(-1.0));
        expect(decoder.decode(b('00000000000045c0')), equals(-42.0));
        expect(decoder.decode(b('182d4454fb2109c0')), equals(-math.pi));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getF64Decoder(be);
        expect(decoder.decode(b('0000000000000000')), equals(0.0));
        expect(decoder.decode(b('3ff0000000000000')), equals(1.0));
        expect(decoder.decode(b('4045000000000000')), equals(42.0));
        expect(decoder.decode(b('400921fb54442d18')), equals(math.pi));
        expect(decoder.decode(b('bff0000000000000')), equals(-1.0));
        expect(decoder.decode(b('c045000000000000')), equals(-42.0));
        expect(decoder.decode(b('c00921fb54442d18')), equals(-math.pi));
      });

      test('decodes with offset', () {
        final decoder = getF64Decoder();
        final (value, offset) =
            decoder.read(b('ffffff000000000000f03f'), 3);
        expect(value, equals(1.0));
        expect(offset, equals(11));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getF64Codec();
        expect(codec.fixedSize, equals(8));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getF64Codec();
        assertValidFloat(codec, 0, '0000000000000000');
        assertValidFloat(codec, 1, '000000000000f03f');
        assertValidFloat(codec, 42, '0000000000004540');
        assertValidFloat(codec, math.pi, '182d4454fb210940');
        assertValidFloat(codec, -1, '000000000000f0bf');
        assertValidFloat(codec, -42, '00000000000045c0');
        assertValidFloat(codec, -math.pi, '182d4454fb2109c0');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getF64Codec(be);
        assertValidFloat(codec, 0, '0000000000000000');
        assertValidFloat(codec, 1, '3ff0000000000000');
        assertValidFloat(codec, 42, '4045000000000000');
        assertValidFloat(codec, math.pi, '400921fb54442d18');
        assertValidFloat(codec, -1, 'bff0000000000000');
        assertValidFloat(codec, -42, 'c045000000000000');
        assertValidFloat(codec, -math.pi, 'c00921fb54442d18');
      });
    });
  });
}
