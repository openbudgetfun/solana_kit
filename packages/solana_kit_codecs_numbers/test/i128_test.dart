import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('i128', () {
    const be = NumberCodecConfig(endian: Endian.big);
    final i128Min = -BigInt.parse('170141183460469231731687303715884105728');
    final i128Max = BigInt.parse('170141183460469231731687303715884105727');

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getI128Encoder();
        expect(encoder.fixedSize, equals(16));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getI128Encoder();
        assertValidEncodeBigInt(
          encoder,
          BigInt.zero,
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.one,
          '01000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.from(42),
          '2a000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          -BigInt.one,
          'ffffffffffffffffffffffffffffffff',
        );
        assertValidEncodeBigInt(
          encoder,
          -BigInt.from(42),
          'd6ffffffffffffffffffffffffffffff',
        );
        assertValidEncodeBigInt(
          encoder,
          i128Min,
          '00000000000000000000000000000080',
        );
        assertValidEncodeBigInt(
          encoder,
          i128Max,
          'ffffffffffffffffffffffffffffff7f',
        );
      });

      test('encodes big-endian values correctly', () {
        final encoder = getI128Encoder(be);
        assertValidEncodeBigInt(
          encoder,
          BigInt.zero,
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.one,
          '00000000000000000000000000000001',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.from(42),
          '0000000000000000000000000000002a',
        );
        assertValidEncodeBigInt(
          encoder,
          -BigInt.one,
          'ffffffffffffffffffffffffffffffff',
        );
        assertValidEncodeBigInt(
          encoder,
          -BigInt.from(42),
          'ffffffffffffffffffffffffffffffd6',
        );
        assertValidEncodeBigInt(
          encoder,
          i128Min,
          '80000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          i128Max,
          '7fffffffffffffffffffffffffffffff',
        );
      });

      test('throws on out-of-range values', () {
        final encoder = getI128Encoder();
        assertRangeErrorBigInt(encoder, i128Min - BigInt.one);
        assertRangeErrorBigInt(encoder, i128Max + BigInt.one);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getI128Decoder();
        expect(decoder.fixedSize, equals(16));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getI128Decoder();
        expect(
          decoder.decode(b('00000000000000000000000000000000')),
          equals(BigInt.zero),
        );
        expect(
          decoder.decode(b('01000000000000000000000000000000')),
          equals(BigInt.one),
        );
        expect(
          decoder.decode(b('2a000000000000000000000000000000')),
          equals(BigInt.from(42)),
        );
        expect(
          decoder.decode(b('ffffffffffffffffffffffffffffffff')),
          equals(-BigInt.one),
        );
        expect(
          decoder.decode(b('d6ffffffffffffffffffffffffffffff')),
          equals(-BigInt.from(42)),
        );
        expect(
          decoder.decode(b('00000000000000000000000000000080')),
          equals(i128Min),
        );
        expect(
          decoder.decode(b('ffffffffffffffffffffffffffffff7f')),
          equals(i128Max),
        );
      });

      test('decodes big-endian values correctly', () {
        final decoder = getI128Decoder(be);
        expect(
          decoder.decode(b('00000000000000000000000000000000')),
          equals(BigInt.zero),
        );
        expect(
          decoder.decode(b('00000000000000000000000000000001')),
          equals(BigInt.one),
        );
        expect(
          decoder.decode(b('0000000000000000000000000000002a')),
          equals(BigInt.from(42)),
        );
        expect(
          decoder.decode(b('ffffffffffffffffffffffffffffffff')),
          equals(-BigInt.one),
        );
        expect(
          decoder.decode(b('ffffffffffffffffffffffffffffffd6')),
          equals(-BigInt.from(42)),
        );
        expect(
          decoder.decode(b('80000000000000000000000000000000')),
          equals(i128Min),
        );
        expect(
          decoder.decode(b('7fffffffffffffffffffffffffffffff')),
          equals(i128Max),
        );
      });

      test('decodes with offset', () {
        final decoder = getI128Decoder();
        final (value, offset) = decoder.read(
          b('ffffffd6ffffffffffffffffffffffffffffff'),
          3,
        );
        expect(value, equals(-BigInt.from(42)));
        expect(offset, equals(19));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getI128Codec();
        expect(codec.fixedSize, equals(16));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getI128Codec();
        assertValidBigInt(
          codec,
          BigInt.zero,
          '00000000000000000000000000000000',
        );
        assertValidBigInt(
          codec,
          BigInt.one,
          '01000000000000000000000000000000',
        );
        assertValidBigInt(
          codec,
          BigInt.from(42),
          '2a000000000000000000000000000000',
        );
        assertValidBigInt(
          codec,
          -BigInt.one,
          'ffffffffffffffffffffffffffffffff',
        );
        assertValidBigInt(
          codec,
          -BigInt.from(42),
          'd6ffffffffffffffffffffffffffffff',
        );
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getI128Codec(be);
        assertValidBigInt(
          codec,
          BigInt.zero,
          '00000000000000000000000000000000',
        );
        assertValidBigInt(
          codec,
          BigInt.one,
          '00000000000000000000000000000001',
        );
        assertValidBigInt(
          codec,
          BigInt.from(42),
          '0000000000000000000000000000002a',
        );
        assertValidBigInt(
          codec,
          -BigInt.one,
          'ffffffffffffffffffffffffffffffff',
        );
        assertValidBigInt(
          codec,
          -BigInt.from(42),
          'ffffffffffffffffffffffffffffffd6',
        );
      });

      test('roundtrips boundary values', () {
        final codec = getI128Codec();
        assertValidBigInt(codec, i128Min, '00000000000000000000000000000080');
        assertValidBigInt(codec, i128Max, 'ffffffffffffffffffffffffffffff7f');
        assertValidBigInt(
          codec,
          i128Min + BigInt.one,
          '01000000000000000000000000000080',
        );
        assertValidBigInt(
          codec,
          i128Max - BigInt.one,
          'feffffffffffffffffffffffffffff7f',
        );
      });
    });
  });
}
