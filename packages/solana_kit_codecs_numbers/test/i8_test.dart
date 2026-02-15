import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('i8', () {
    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getI8Encoder();
        expect(encoder.fixedSize, equals(1));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes values correctly', () {
        final encoder = getI8Encoder();
        assertValidEncode(encoder, 0, '00');
        assertValidEncode(encoder, 1, '01');
        assertValidEncode(encoder, 42, '2a');
        assertValidEncode(encoder, -1, 'ff');
        assertValidEncode(encoder, -42, 'd6');
        assertValidEncode(encoder, -128, '80');
        assertValidEncode(encoder, 127, '7f');
      });

      test('throws on out-of-range values', () {
        final encoder = getI8Encoder();
        assertRangeError(encoder, -129);
        assertRangeError(encoder, 128);
        assertRangeError(encoder, -200);
        assertRangeError(encoder, 1000);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getI8Decoder();
        expect(decoder.fixedSize, equals(1));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes values correctly', () {
        final decoder = getI8Decoder();
        expect(decoder.decode(b('00')), equals(0));
        expect(decoder.decode(b('01')), equals(1));
        expect(decoder.decode(b('2a')), equals(42));
        expect(decoder.decode(b('ff')), equals(-1));
        expect(decoder.decode(b('d6')), equals(-42));
        expect(decoder.decode(b('80')), equals(-128));
        expect(decoder.decode(b('7f')), equals(127));
      });

      test('decodes with offset', () {
        final decoder = getI8Decoder();
        final (value, offset) = decoder.read(b('ffffffd6'), 3);
        expect(value, equals(-42));
        expect(offset, equals(4));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getI8Codec();
        expect(codec.fixedSize, equals(1));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips values correctly', () {
        final codec = getI8Codec();
        assertValidInt(codec, 0, '00');
        assertValidInt(codec, 1, '01');
        assertValidInt(codec, 42, '2a');
        assertValidInt(codec, -1, 'ff');
        assertValidInt(codec, -42, 'd6');
      });

      test('roundtrips boundary values', () {
        final codec = getI8Codec();
        // min boundary
        assertValidInt(codec, -128, '80');
        // max boundary
        assertValidInt(codec, 127, '7f');
        // near boundaries
        assertValidInt(codec, -127, '81');
        assertValidInt(codec, 126, '7e');
      });
    });
  });
}
