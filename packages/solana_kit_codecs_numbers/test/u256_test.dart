import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('u256', () {
    const be = NumberCodecConfig(endian: Endian.big);
    final u256Max = BigInt.parse(
      'ffffffffffffffffffffffffffffffff'
      'ffffffffffffffffffffffffffffffff',
      radix: 16,
    );
    const maxHex =
        'ffffffffffffffffffffffffffffffff'
        'ffffffffffffffffffffffffffffffff';

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getU256Encoder();
        expect(encoder.fixedSize, equals(32));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getU256Encoder();
        assertValidEncodeBigInt(
          encoder,
          BigInt.zero,
          '00000000000000000000000000000000'
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.from(42),
          '2a000000000000000000000000000000'
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.parse('ffffffffffffffff', radix: 16),
          'ffffffffffffffff0000000000000000'
          '00000000000000000000000000000000',
        );
        assertValidEncodeBigInt(encoder, u256Max, maxHex);
      });

      test('encodes big-endian values correctly', () {
        final encoder = getU256Encoder(be);
        assertValidEncodeBigInt(
          encoder,
          BigInt.from(42),
          '00000000000000000000000000000000'
          '0000000000000000000000000000002a',
        );
        assertValidEncodeBigInt(
          encoder,
          BigInt.parse('ffffffffffffffff', radix: 16),
          '00000000000000000000000000000000'
          '0000000000000000ffffffffffffffff',
        );
        assertValidEncodeBigInt(encoder, u256Max, maxHex);
      });

      test('throws on out-of-range values', () {
        final encoder = getU256Encoder();
        assertRangeErrorBigInt(encoder, -BigInt.one);
        assertRangeErrorBigInt(encoder, u256Max + BigInt.one);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getU256Decoder();
        expect(decoder.fixedSize, equals(32));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getU256Decoder();
        expect(
          decoder.decode(
            b(
              '2a000000000000000000000000000000'
              '00000000000000000000000000000000',
            ),
          ),
          equals(BigInt.from(42)),
        );
        expect(decoder.decode(b(maxHex)), equals(u256Max));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getU256Decoder(be);
        expect(
          decoder.decode(
            b(
              '00000000000000000000000000000000'
              '0000000000000000000000000000002a',
            ),
          ),
          equals(BigInt.from(42)),
        );
        expect(decoder.decode(b(maxHex)), equals(u256Max));
      });
    });

    test('codec round-trips the full range', () {
      final codec = getU256Codec();
      expect(codec.encode(u256Max).length, equals(32));
      assertValidBigInt(codec, u256Max, maxHex);
      assertValidBigInt(codec, BigInt.zero, '00' * 32);
      assertValidBigInt(
        codec,
        BigInt.one << 255,
        '${'00' * 31}80',
      );
    });
  });
}
