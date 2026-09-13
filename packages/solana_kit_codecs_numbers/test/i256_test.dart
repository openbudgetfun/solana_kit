import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('i256', () {
    const be = NumberCodecConfig(endian: Endian.big);
    final i256Max = BigInt.parse(
      '7fffffffffffffffffffffffffffffff'
      'ffffffffffffffffffffffffffffffff',
      radix: 16,
    );
    final i256Min = -i256Max - BigInt.one;
    const minHex =
        '00000000000000000000000000000000'
        '00000000000000000000000000000080';
    const maxHex =
        'ffffffffffffffffffffffffffffffff'
        'ffffffffffffffffffffffffffffff7f';

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getI256Encoder();
        expect(encoder.fixedSize, equals(32));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getI256Encoder();
        assertValidEncodeBigInt(
          encoder,
          BigInt.zero,
          '00000000000000000000000000000000'
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          -BigInt.from(42),
          'd6ffffffffffffffffffffffffffffff'
          'ffffffffffffffffffffffffffffffff',
        );
        assertValidEncodeBigInt(encoder, i256Min, minHex);
        assertValidEncodeBigInt(encoder, i256Max, maxHex);
      });

      test('encodes big-endian values correctly', () {
        final encoder = getI256Encoder(be);
        assertValidEncodeBigInt(
          encoder,
          -BigInt.from(42),
          'ffffffffffffffffffffffffffffffff'
          'ffffffffffffffffffffffffffffffd6',
        );
        assertValidEncodeBigInt(
          encoder,
          i256Min,
          '80000000000000000000000000000000'
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          i256Max,
          '7fffffffffffffffffffffffffffffff'
          'ffffffffffffffffffffffffffffffff',
        );
      });

      test('throws on out-of-range values', () {
        final encoder = getI256Encoder();
        assertRangeErrorBigInt(encoder, i256Min - BigInt.one);
        assertRangeErrorBigInt(encoder, i256Max + BigInt.one);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getI256Decoder();
        expect(decoder.fixedSize, equals(32));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getI256Decoder();
        expect(
          decoder.decode(
            b(
              'd6ffffffffffffffffffffffffffffff'
              'ffffffffffffffffffffffffffffffff',
            ),
          ),
          equals(-BigInt.from(42)),
        );
        expect(decoder.decode(b(minHex)), equals(i256Min));
        expect(decoder.decode(b(maxHex)), equals(i256Max));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getI256Decoder(be);
        expect(
          decoder.decode(
            b(
              'ffffffffffffffffffffffffffffffff'
              'ffffffffffffffffffffffffffffffd6',
            ),
          ),
          equals(-BigInt.from(42)),
        );
        expect(
          decoder.decode(
            b(
              '80000000000000000000000000000000'
              '00000000000000000000000000000000',
            ),
          ),
          equals(i256Min),
        );
      });
    });

    test('codec round-trips signed boundaries', () {
      final codec = getI256Codec();
      expect(codec.encode(i256Min).length, equals(32));
      assertValidBigInt(codec, i256Min, minHex);
      assertValidBigInt(codec, i256Max, maxHex);
      assertValidBigInt(codec, -BigInt.one, 'ff' * 32);
      assertValidBigInt(codec, BigInt.zero, '00' * 32);
    });
  });
}
