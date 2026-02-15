import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('u8', () {
    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getU8Encoder();
        expect(encoder.fixedSize, equals(1));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes values correctly', () {
        final encoder = getU8Encoder();
        assertValidEncode(encoder, 0, '00');
        assertValidEncode(encoder, 1, '01');
        assertValidEncode(encoder, 42, '2a');
        assertValidEncode(encoder, 255, 'ff');
      });

      test('throws on out-of-range values', () {
        final encoder = getU8Encoder();
        assertRangeError(encoder, -1);
        assertRangeError(encoder, 256);
        assertRangeError(encoder, -100);
        assertRangeError(encoder, 1000);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getU8Decoder();
        expect(decoder.fixedSize, equals(1));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes values correctly', () {
        final decoder = getU8Decoder();
        expect(decoder.decode(b('00')), equals(0));
        expect(decoder.decode(b('01')), equals(1));
        expect(decoder.decode(b('2a')), equals(42));
        expect(decoder.decode(b('ff')), equals(255));
      });

      test('decodes with offset', () {
        final decoder = getU8Decoder();
        final (value, offset) = decoder.read(b('ffffff2a'), 3);
        expect(value, equals(42));
        expect(offset, equals(4));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getU8Codec();
        expect(codec.fixedSize, equals(1));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips values correctly', () {
        final codec = getU8Codec();
        assertValidInt(codec, 0, '00');
        assertValidInt(codec, 1, '01');
        assertValidInt(codec, 42, '2a');
        assertValidInt(codec, 255, 'ff');
      });

      test('roundtrips boundary values', () {
        final codec = getU8Codec();
        // min boundary
        assertValidInt(codec, 0, '00');
        // max boundary
        assertValidInt(codec, 255, 'ff');
        // near boundaries
        assertValidInt(codec, 1, '01');
        assertValidInt(codec, 254, 'fe');
      });
    });
  });
}
