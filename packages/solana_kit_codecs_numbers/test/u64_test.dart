import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('u64', () {
    const be = NumberCodecConfig(endian: Endian.big);
    final u64Max = BigInt.parse('18446744073709551615');

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getU64Encoder();
        expect(encoder.fixedSize, equals(8));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getU64Encoder();
        assertValidEncodeBigInt(encoder, BigInt.zero, '0000000000000000');
        assertValidEncodeBigInt(encoder, BigInt.one, '0100000000000000');
        assertValidEncodeBigInt(encoder, BigInt.from(42), '2a00000000000000');
        assertValidEncodeBigInt(
          encoder,
          BigInt.from(0xffffffff),
          'ffffffff00000000',
        );
        assertValidEncodeBigInt(encoder, u64Max, 'ffffffffffffffff');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getU64Encoder(be);
        assertValidEncodeBigInt(encoder, BigInt.zero, '0000000000000000');
        assertValidEncodeBigInt(encoder, BigInt.one, '0000000000000001');
        assertValidEncodeBigInt(encoder, BigInt.from(42), '000000000000002a');
        assertValidEncodeBigInt(
          encoder,
          BigInt.from(0xffffffff),
          '00000000ffffffff',
        );
        assertValidEncodeBigInt(encoder, u64Max, 'ffffffffffffffff');
      });

      test('throws on out-of-range values', () {
        final encoder = getU64Encoder();
        assertRangeErrorBigInt(encoder, -BigInt.one);
        assertRangeErrorBigInt(encoder, u64Max + BigInt.one);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getU64Decoder();
        expect(decoder.fixedSize, equals(8));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getU64Decoder();
        expect(decoder.decode(b('0000000000000000')), equals(BigInt.zero));
        expect(decoder.decode(b('0100000000000000')), equals(BigInt.one));
        expect(decoder.decode(b('2a00000000000000')), equals(BigInt.from(42)));
        expect(
          decoder.decode(b('ffffffff00000000')),
          equals(BigInt.from(0xffffffff)),
        );
        expect(decoder.decode(b('ffffffffffffffff')), equals(u64Max));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getU64Decoder(be);
        expect(decoder.decode(b('0000000000000000')), equals(BigInt.zero));
        expect(decoder.decode(b('0000000000000001')), equals(BigInt.one));
        expect(decoder.decode(b('000000000000002a')), equals(BigInt.from(42)));
        expect(
          decoder.decode(b('00000000ffffffff')),
          equals(BigInt.from(0xffffffff)),
        );
        expect(decoder.decode(b('ffffffffffffffff')), equals(u64Max));
      });

      test('decodes with offset', () {
        final decoder = getU64Decoder();
        final (value, offset) = decoder.read(b('ffffff2a00000000000000'), 3);
        expect(value, equals(BigInt.from(42)));
        expect(offset, equals(11));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getU64Codec();
        expect(codec.fixedSize, equals(8));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getU64Codec();
        assertValidBigInt(codec, BigInt.zero, '0000000000000000');
        assertValidBigInt(codec, BigInt.one, '0100000000000000');
        assertValidBigInt(codec, BigInt.from(42), '2a00000000000000');
        assertValidBigInt(codec, BigInt.from(0xffffffff), 'ffffffff00000000');
        assertValidBigInt(codec, u64Max, 'ffffffffffffffff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getU64Codec(be);
        assertValidBigInt(codec, BigInt.zero, '0000000000000000');
        assertValidBigInt(codec, BigInt.one, '0000000000000001');
        assertValidBigInt(codec, BigInt.from(42), '000000000000002a');
        assertValidBigInt(codec, BigInt.from(0xffffffff), '00000000ffffffff');
        assertValidBigInt(codec, u64Max, 'ffffffffffffffff');
      });

      test('roundtrips boundary values', () {
        final codec = getU64Codec();
        assertValidBigInt(codec, BigInt.zero, '0000000000000000');
        assertValidBigInt(codec, u64Max, 'ffffffffffffffff');
        assertValidBigInt(codec, BigInt.one, '0100000000000000');
        assertValidBigInt(codec, u64Max - BigInt.one, 'feffffffffffffff');
      });
    });
  });
}
