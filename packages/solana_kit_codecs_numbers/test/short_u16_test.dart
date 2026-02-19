import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('shortU16', () {
    group('encoder', () {
      test('is variable-size', () {
        final encoder = getShortU16Encoder();
        expect(isVariableSize(encoder), isTrue);
        expect(isFixedSize(encoder), isFalse);
      });

      test('has maxSize of 3', () {
        final encoder = getShortU16Encoder();
        expect(encoder.maxSize, equals(3));
      });

      test('returns correct size from value', () {
        final encoder = getShortU16Encoder();
        // 1-byte values: 0-127
        expect(encoder.getSizeFromValue(0), equals(1));
        expect(encoder.getSizeFromValue(1), equals(1));
        expect(encoder.getSizeFromValue(42), equals(1));
        expect(encoder.getSizeFromValue(127), equals(1));
        // 2-byte values: 128-16383
        expect(encoder.getSizeFromValue(128), equals(2));
        expect(encoder.getSizeFromValue(16383), equals(2));
        // 3-byte values: 16384-65535
        expect(encoder.getSizeFromValue(16384), equals(3));
        expect(encoder.getSizeFromValue(65535), equals(3));
      });

      test('encodes 1-byte values correctly', () {
        final encoder = getShortU16Encoder();
        assertValidEncode(encoder, 0, '00');
        assertValidEncode(encoder, 1, '01');
        assertValidEncode(encoder, 42, '2a');
        assertValidEncode(encoder, 127, '7f');
      });

      test('encodes 2-byte values correctly', () {
        final encoder = getShortU16Encoder();
        assertValidEncode(encoder, 128, '8001');
        assertValidEncode(encoder, 16383, 'ff7f');
      });

      test('encodes 3-byte values correctly', () {
        final encoder = getShortU16Encoder();
        assertValidEncode(encoder, 16384, '808001');
        assertValidEncode(encoder, 65534, 'feff03');
        assertValidEncode(encoder, 65535, 'ffff03');
      });

      test('throws on out-of-range values', () {
        final encoder = getShortU16Encoder();
        assertRangeError(encoder, -1);
        assertRangeError(encoder, 65536);
        assertRangeError(encoder, -100);
        assertRangeError(encoder, 100000);
      });
    });

    group('decoder', () {
      test('is variable-size', () {
        final decoder = getShortU16Decoder();
        expect(isVariableSize(decoder), isTrue);
        expect(isFixedSize(decoder), isFalse);
      });

      test('has maxSize of 3', () {
        final decoder = getShortU16Decoder();
        expect(decoder.maxSize, equals(3));
      });

      test('decodes 1-byte values correctly', () {
        final decoder = getShortU16Decoder();
        expect(decoder.decode(b('00')), equals(0));
        expect(decoder.decode(b('01')), equals(1));
        expect(decoder.decode(b('2a')), equals(42));
        expect(decoder.decode(b('7f')), equals(127));
      });

      test('decodes 2-byte values correctly', () {
        final decoder = getShortU16Decoder();
        expect(decoder.decode(b('8001')), equals(128));
        expect(decoder.decode(b('ff7f')), equals(16383));
      });

      test('decodes 3-byte values correctly', () {
        final decoder = getShortU16Decoder();
        expect(decoder.decode(b('808001')), equals(16384));
        expect(decoder.decode(b('feff03')), equals(65534));
        expect(decoder.decode(b('ffff03')), equals(65535));
      });

      test('decodes with offset', () {
        final decoder = getShortU16Decoder();
        // 1-byte with offset
        final (v1, o1) = decoder.read(b('ffffff2a'), 3);
        expect(v1, equals(42));
        expect(o1, equals(4));
        // 2-byte with offset
        final (v2, o2) = decoder.read(b('ffffff8001'), 3);
        expect(v2, equals(128));
        expect(o2, equals(5));
        // 3-byte with offset
        final (v3, o3) = decoder.read(b('ffffff808001'), 3);
        expect(v3, equals(16384));
        expect(o3, equals(6));
      });

      test('returns correct offset for variable sizes', () {
        final decoder = getShortU16Decoder();
        // 1-byte
        final (_, offset1) = decoder.read(b('00'), 0);
        expect(offset1, equals(1));
        // 2-byte
        final (_, offset2) = decoder.read(b('8001'), 0);
        expect(offset2, equals(2));
        // 3-byte
        final (_, offset3) = decoder.read(b('808001'), 0);
        expect(offset3, equals(3));
      });

      test('throws SolanaError on truncated input with continuation bit', () {
        final decoder = getShortU16Decoder();
        // 0x80 has continuation bit set but no following byte.
        expect(
          () => decoder.decode(Uint8List.fromList([0x80])),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              equals(SolanaErrorCode.codecsInvalidByteLength),
            ),
          ),
        );
      });

      test('throws SolanaError on too many continuation bytes', () {
        final decoder = getShortU16Decoder();
        // 4 bytes with continuation bits: [0x80, 0x80, 0x80, 0x01]
        // shortU16 only supports up to 3 bytes.
        expect(
          () => decoder.decode(Uint8List.fromList([0x80, 0x80, 0x80, 0x01])),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              equals(SolanaErrorCode.codecsNumberOutOfRange),
            ),
          ),
        );
      });
    });

    group('codec', () {
      test('is variable-size', () {
        final codec = getShortU16Codec();
        expect(isVariableSize(codec), isTrue);
        expect(isFixedSize(codec), isFalse);
      });

      test('roundtrips known values', () {
        final codec = getShortU16Codec();

        // 1-byte range
        for (final value in [0, 1, 42, 127]) {
          final encoded = codec.encode(value);
          final decoded = codec.decode(encoded);
          expect(decoded, equals(value));
        }

        // 2-byte range
        for (final value in [128, 255, 1000, 16383]) {
          final encoded = codec.encode(value);
          final decoded = codec.decode(encoded);
          expect(decoded, equals(value));
        }

        // 3-byte range
        for (final value in [16384, 32767, 65534, 65535]) {
          final encoded = codec.encode(value);
          final decoded = codec.decode(encoded);
          expect(decoded, equals(value));
        }
      });

      test('roundtrips all values from 0 to 65535', () {
        final codec = getShortU16Codec();
        for (var i = 0; i <= 65535; i++) {
          final encoded = codec.encode(i);
          final decoded = codec.decode(encoded);
          expect(decoded, equals(i), reason: 'Failed roundtrip for value $i');
        }
      });

      test('encodes to expected hex values', () {
        final codec = getShortU16Codec();
        expect(h(codec.encode(0)), equals('00'));
        expect(h(codec.encode(1)), equals('01'));
        expect(h(codec.encode(42)), equals('2a'));
        expect(h(codec.encode(127)), equals('7f'));
        expect(h(codec.encode(128)), equals('8001'));
        expect(h(codec.encode(16383)), equals('ff7f'));
        expect(h(codec.encode(16384)), equals('808001'));
        expect(h(codec.encode(65534)), equals('feff03'));
        expect(h(codec.encode(65535)), equals('ffff03'));
      });
    });
  });
}
