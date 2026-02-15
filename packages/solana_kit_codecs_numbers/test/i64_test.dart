import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('i64', () {
    const be = NumberCodecConfig(endian: Endian.big);
    final i64Min = -BigInt.parse('9223372036854775808');
    final i64Max = BigInt.parse('9223372036854775807');

    group('encoder', () {
      test('has the correct fixed size', () {
        final encoder = getI64Encoder();
        expect(encoder.fixedSize, equals(8));
        expect(isFixedSize(encoder), isTrue);
      });

      test('encodes little-endian values correctly', () {
        final encoder = getI64Encoder();
        assertValidEncodeBigInt(encoder, BigInt.zero, '0000000000000000');
        assertValidEncodeBigInt(encoder, BigInt.one, '0100000000000000');
        assertValidEncodeBigInt(encoder, BigInt.from(42), '2a00000000000000');
        assertValidEncodeBigInt(encoder, -BigInt.one, 'ffffffffffffffff');
        assertValidEncodeBigInt(encoder, -BigInt.from(42), 'd6ffffffffffffff');
        assertValidEncodeBigInt(encoder, i64Min, '0000000000000080');
        assertValidEncodeBigInt(encoder, i64Max, 'ffffffffffffff7f');
      });

      test('encodes big-endian values correctly', () {
        final encoder = getI64Encoder(be);
        assertValidEncodeBigInt(encoder, BigInt.zero, '0000000000000000');
        assertValidEncodeBigInt(encoder, BigInt.one, '0000000000000001');
        assertValidEncodeBigInt(encoder, BigInt.from(42), '000000000000002a');
        assertValidEncodeBigInt(encoder, -BigInt.one, 'ffffffffffffffff');
        assertValidEncodeBigInt(encoder, -BigInt.from(42), 'ffffffffffffffd6');
        assertValidEncodeBigInt(encoder, i64Min, '8000000000000000');
        assertValidEncodeBigInt(encoder, i64Max, '7fffffffffffffff');
      });

      test('throws on out-of-range values', () {
        final encoder = getI64Encoder();
        assertRangeErrorBigInt(encoder, i64Min - BigInt.one);
        assertRangeErrorBigInt(encoder, i64Max + BigInt.one);
      });
    });

    group('decoder', () {
      test('has the correct fixed size', () {
        final decoder = getI64Decoder();
        expect(decoder.fixedSize, equals(8));
        expect(isFixedSize(decoder), isTrue);
      });

      test('decodes little-endian values correctly', () {
        final decoder = getI64Decoder();
        expect(decoder.decode(b('0000000000000000')), equals(BigInt.zero));
        expect(decoder.decode(b('0100000000000000')), equals(BigInt.one));
        expect(decoder.decode(b('2a00000000000000')), equals(BigInt.from(42)));
        expect(decoder.decode(b('ffffffffffffffff')), equals(-BigInt.one));
        expect(decoder.decode(b('d6ffffffffffffff')), equals(-BigInt.from(42)));
        expect(decoder.decode(b('0000000000000080')), equals(i64Min));
        expect(decoder.decode(b('ffffffffffffff7f')), equals(i64Max));
      });

      test('decodes big-endian values correctly', () {
        final decoder = getI64Decoder(be);
        expect(decoder.decode(b('0000000000000000')), equals(BigInt.zero));
        expect(decoder.decode(b('0000000000000001')), equals(BigInt.one));
        expect(decoder.decode(b('000000000000002a')), equals(BigInt.from(42)));
        expect(decoder.decode(b('ffffffffffffffff')), equals(-BigInt.one));
        expect(decoder.decode(b('ffffffffffffffd6')), equals(-BigInt.from(42)));
        expect(decoder.decode(b('8000000000000000')), equals(i64Min));
        expect(decoder.decode(b('7fffffffffffffff')), equals(i64Max));
      });

      test('decodes with offset', () {
        final decoder = getI64Decoder();
        final (value, offset) = decoder.read(b('ffffffd6ffffffffffffff'), 3);
        expect(value, equals(-BigInt.from(42)));
        expect(offset, equals(11));
      });
    });

    group('codec', () {
      test('has the correct fixed size', () {
        final codec = getI64Codec();
        expect(codec.fixedSize, equals(8));
        expect(isFixedSize(codec), isTrue);
      });

      test('roundtrips little-endian values correctly', () {
        final codec = getI64Codec();
        assertValidBigInt(codec, BigInt.zero, '0000000000000000');
        assertValidBigInt(codec, BigInt.one, '0100000000000000');
        assertValidBigInt(codec, BigInt.from(42), '2a00000000000000');
        assertValidBigInt(codec, -BigInt.one, 'ffffffffffffffff');
        assertValidBigInt(codec, -BigInt.from(42), 'd6ffffffffffffff');
      });

      test('roundtrips big-endian values correctly', () {
        final codec = getI64Codec(be);
        assertValidBigInt(codec, BigInt.zero, '0000000000000000');
        assertValidBigInt(codec, BigInt.one, '0000000000000001');
        assertValidBigInt(codec, BigInt.from(42), '000000000000002a');
        assertValidBigInt(codec, -BigInt.one, 'ffffffffffffffff');
        assertValidBigInt(codec, -BigInt.from(42), 'ffffffffffffffd6');
      });

      test('roundtrips boundary values', () {
        final codec = getI64Codec();
        assertValidBigInt(codec, i64Min, '0000000000000080');
        assertValidBigInt(codec, i64Max, 'ffffffffffffff7f');
        assertValidBigInt(codec, i64Min + BigInt.one, '0100000000000080');
        assertValidBigInt(codec, i64Max - BigInt.one, 'feffffffffffff7f');
      });
    });
  });
}
