import 'dart:typed_data';

import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('decimal fixed-point codecs', () {
    test('encode and decode unsigned little-endian values', () {
      final codec = getDecimalFixedPointCodec(
        FixedPointSignedness.unsigned,
        16,
        2,
      );
      final value = rawDecimalFixedPoint(FixedPointSignedness.unsigned, 16, 2)(
        BigInt.from(0x1234),
      );

      final bytes = codec.encode(value);
      expect(bytes, Uint8List.fromList([0x34, 0x12]));
      expect(codec.decode(bytes), value);
      expect(codec.fixedSize, 2);
    });

    test('encode and decode signed big-endian values', () {
      final codec = getDecimalFixedPointCodec(
        FixedPointSignedness.signed,
        16,
        2,
        endian: FixedPointEndian.big,
      );
      final value = rawDecimalFixedPoint(FixedPointSignedness.signed, 16, 2)(
        BigInt.from(-2),
      );

      final bytes = codec.encode(value);
      expect(bytes, Uint8List.fromList([0xff, 0xfe]));
      expect(codec.decode(bytes), value);
    });

    test('write and read support offsets', () {
      final encoder = getDecimalFixedPointEncoder(
        FixedPointSignedness.unsigned,
        16,
        0,
      );
      final decoder = getDecimalFixedPointDecoder(
        FixedPointSignedness.unsigned,
        16,
        0,
      );
      final value = rawDecimalFixedPoint(FixedPointSignedness.unsigned, 16, 0)(
        BigInt.from(7),
      );
      final buffer = Uint8List(4);

      expect(encoder.write(value, buffer, 1), 3);
      expect(buffer, Uint8List.fromList([0, 7, 0, 0]));
      final (decoded, nextOffset) = decoder.read(buffer, 1);
      expect(decoded, value);
      expect(nextOffset, 3);
    });

    test('validate decimal codec shapes and readable ranges', () {
      final encoder = getDecimalFixedPointEncoder(
        FixedPointSignedness.unsigned,
        16,
        2,
      );
      final value = rawDecimalFixedPoint(FixedPointSignedness.unsigned, 16, 3)(
        BigInt.one,
      );

      expect(() => encoder.encode(value), throwsArgumentError);
      expect(
        () => getDecimalFixedPointEncoder(FixedPointSignedness.unsigned, 7, 0),
        throwsArgumentError,
      );
      expect(
        () => getDecimalFixedPointDecoder(FixedPointSignedness.unsigned, 0, 0),
        throwsRangeError,
      );
      expect(
        () => getDecimalFixedPointDecoder(FixedPointSignedness.unsigned, 8, -1),
        throwsRangeError,
      );
      expect(
        () => getDecimalFixedPointDecoder(
          FixedPointSignedness.unsigned,
          16,
          0,
        ).decode(Uint8List.fromList([1])),
        throwsRangeError,
      );
      expect(
        () => getDecimalFixedPointDecoder(
          FixedPointSignedness.unsigned,
          16,
          0,
        ).read(Uint8List(2), -1),
        throwsRangeError,
      );
    });
  });

  group('binary fixed-point codecs', () {
    test('encode and decode unsigned little-endian values', () {
      final codec = getBinaryFixedPointCodec(
        FixedPointSignedness.unsigned,
        16,
        4,
      );
      final value = rawBinaryFixedPoint(FixedPointSignedness.unsigned, 16, 4)(
        BigInt.from(0x1234),
      );

      final bytes = codec.encode(value);
      expect(bytes, Uint8List.fromList([0x34, 0x12]));
      expect(codec.decode(bytes), value);
    });

    test('encode and decode signed big-endian values', () {
      final codec = getBinaryFixedPointCodec(
        FixedPointSignedness.signed,
        16,
        4,
        endian: FixedPointEndian.big,
      );
      final value = rawBinaryFixedPoint(FixedPointSignedness.signed, 16, 4)(
        BigInt.from(-2),
      );

      final bytes = codec.encode(value);
      expect(bytes, Uint8List.fromList([0xff, 0xfe]));
      expect(codec.decode(bytes), value);
    });

    test('validate binary codec shapes and raw write ranges', () {
      final encoder = getBinaryFixedPointEncoder(
        FixedPointSignedness.unsigned,
        16,
        4,
      );
      final wrongScale = rawBinaryFixedPoint(
        FixedPointSignedness.unsigned,
        16,
        5,
      )(BigInt.one);
      final negative = rawBinaryFixedPoint(FixedPointSignedness.signed, 16, 4)(
        -BigInt.one,
      );

      expect(() => encoder.encode(wrongScale), throwsArgumentError);
      expect(() => encoder.encode(negative), throwsArgumentError);
      expect(
        () => getBinaryFixedPointEncoder(FixedPointSignedness.unsigned, 8, -1),
        throwsRangeError,
      );
      expect(
        () => getBinaryFixedPointDecoder(FixedPointSignedness.unsigned, 8, 9),
        throwsRangeError,
      );
      expect(
        () => getBinaryFixedPointEncoder(FixedPointSignedness.unsigned, 7, 0),
        throwsArgumentError,
      );
    });

    test('rejects writes that do not fit in the destination buffer', () {
      final encoder = getBinaryFixedPointEncoder(
        FixedPointSignedness.unsigned,
        16,
        0,
      );
      final value = rawBinaryFixedPoint(FixedPointSignedness.unsigned, 16, 0)(
        BigInt.one,
      );

      expect(() => encoder.write(value, Uint8List(1), 0), throwsRangeError);
      expect(() => encoder.write(value, Uint8List(2), -1), throwsRangeError);
    });

    test('rejects malformed raw values during writes', () {
      final encoder = getBinaryFixedPointEncoder(
        FixedPointSignedness.unsigned,
        8,
        0,
      );

      expect(
        () => encoder.encode(
          BinaryFixedPoint(raw: -BigInt.one, fractionalBits: 0, totalBits: 8),
        ),
        throwsRangeError,
      );
      expect(
        () => encoder.encode(
          BinaryFixedPoint(
            raw: BigInt.from(256),
            fractionalBits: 0,
            totalBits: 8,
          ),
        ),
        throwsRangeError,
      );
    });
  });
}
