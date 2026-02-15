import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('u128', () {
    const be = NumberCodecConfig(endian: Endian.big);
    final u128Max = BigInt.parse('340282366920938463463374607431768211455');

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getU128Encoder();
        expect(encoder.fixedSize, equals(16));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getU128Encoder();
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
          BigInt.parse('ffffffffffffffff', radix: 16),
          'ffffffffffffffff0000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          u128Max,
          'ffffffffffffffffffffffffffffffff',
        );
      });

      test('encodes big-endian values correctly', () {
        final encoder = getU128Encoder(be);
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
          BigInt.parse('ffffffffffffffff', radix: 16),
          '0000000000000000ffffffffffffffff',
        );
        assertValidEncodeBigInt(
          encoder,
          u128Max,
          'ffffffffffffffffffffffffffffffff',
        );
      });

      test('throws on out-of-range values', () {
        final encoder = getU128Encoder();
        assertRangeErrorBigInt(encoder, -BigInt.one);
        assertRangeErrorBigInt(encoder, u128Max + BigInt.one);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getU128Decoder();
        expect(decoder.fixedSize, equals(16));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getU128Decoder();
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
          decoder.decode(b('ffffffffffffffff0000000000000000')),
          equals(BigInt.parse('ffffffffffffffff', radix: 16)),
        );
        expect(
          decoder.decode(b('ffffffffffffffffffffffffffffffff')),
          equals(u128Max),
        );
      });

      test('decodes big-endian values correctly', () {
        final decoder = getU128Decoder(be);
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
          decoder.decode(b('0000000000000000ffffffffffffffff')),
          equals(BigInt.parse('ffffffffffffffff', radix: 16)),
        );
        expect(
          decoder.decode(b('ffffffffffffffffffffffffffffffff')),
          equals(u128Max),
        );
      });

      test('decodes with offset', () {
        final decoder = getU128Decoder();
        final (value, offset) = decoder.read(
          b('ffffff2a000000000000000000000000000000'),
          3,
        );
        expect(value, equals(BigInt.from(42)));
        expect(offset, equals(19));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getU128Codec();
        expect(codec.fixedSize, equals(16));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getU128Codec();
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
          BigInt.parse('ffffffffffffffff', radix: 16),
          'ffffffffffffffff0000000000000000',
        );
        assertValidBigInt(codec, u128Max, 'ffffffffffffffffffffffffffffffff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getU128Codec(be);
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
          BigInt.parse('ffffffffffffffff', radix: 16),
          '0000000000000000ffffffffffffffff',
        );
        assertValidBigInt(codec, u128Max, 'ffffffffffffffffffffffffffffffff');
      });

      test('roundtrips boundary values', () {
        final codec = getU128Codec();
        assertValidBigInt(
          codec,
          BigInt.zero,
          '00000000000000000000000000000000',
        );
        assertValidBigInt(codec, u128Max, 'ffffffffffffffffffffffffffffffff');
        assertValidBigInt(
          codec,
          BigInt.one,
          '01000000000000000000000000000000',
        );
        assertValidBigInt(
          codec,
          u128Max - BigInt.one,
          'feffffffffffffffffffffffffffffff',
        );
      });
    });
  });
}
