import 'dart:typed_data';

import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('fixed-point input validation', () {
    for (final input in ['.', '-', '-.']) {
      test('decimal parser rejects digit-free input $input', () {
        expect(
          () => DecimalFixedPoint.parse(
            input,
            decimals: 2,
            signedness: FixedPointSignedness.signed,
          ),
          throwsFormatException,
        );
      });
      test('binary parser rejects digit-free input $input', () {
        expect(
          () => BinaryFixedPoint.parse(
            input,
            fractionalBits: 2,
            signedness: FixedPointSignedness.signed,
          ),
          throwsFormatException,
        );
      });
    }

    test('rejects malformed decimal shapes in validation helpers', () {
      for (final value in [
        DecimalFixedPoint(raw: BigInt.zero, decimals: -1),
        DecimalFixedPoint(raw: BigInt.zero, decimals: 0, totalBits: 0),
      ]) {
        expect(isDecimalFixedPoint(value), isFalse);
        expect(() => assertIsDecimalFixedPoint(value), throwsRangeError);
      }
    });

    test('rejects malformed binary shapes in validation helpers', () {
      for (final value in [
        BinaryFixedPoint(raw: BigInt.zero, fractionalBits: -1),
        BinaryFixedPoint(raw: BigInt.zero, fractionalBits: 0, totalBits: 0),
        BinaryFixedPoint(raw: BigInt.zero, fractionalBits: 9, totalBits: 8),
      ]) {
        expect(isBinaryFixedPoint(value), isFalse);
        expect(() => assertIsBinaryFixedPoint(value), throwsRangeError);
      }
    });
  });

  group('signed fixed-point encoding rejects value-changing overflow', () {
    for (final bits in [8, 16, 64, 128]) {
      for (final endian in FixedPointEndian.values) {
        final half = BigInt.one << (bits - 1);
        final invalid = [-half - BigInt.one, half];

        for (final raw in invalid) {
          test('decimal $bits-bit ${endian.name} rejects $raw atomically', () {
            final codec = getDecimalFixedPointCodec(
              FixedPointSignedness.signed,
              bits,
              0,
              endian: endian,
            );
            final value = DecimalFixedPoint(
              raw: raw,
              decimals: 0,
              signedness: FixedPointSignedness.signed,
              totalBits: bits,
            );
            final buffer = Uint8List(bits ~/ 8 + 2)
              ..fillRange(0, bits ~/ 8 + 2, 42);
            final before = Uint8List.fromList(buffer);

            expect(
              () => codec.encoder.write(value, buffer, 1),
              throwsRangeError,
            );
            expect(buffer, before);
          });

          test('binary $bits-bit ${endian.name} rejects $raw atomically', () {
            final codec = getBinaryFixedPointCodec(
              FixedPointSignedness.signed,
              bits,
              0,
              endian: endian,
            );
            final value = BinaryFixedPoint(
              raw: raw,
              fractionalBits: 0,
              signedness: FixedPointSignedness.signed,
              totalBits: bits,
            );
            final buffer = Uint8List(bits ~/ 8 + 2)
              ..fillRange(0, bits ~/ 8 + 2, 42);
            final before = Uint8List.fromList(buffer);

            expect(
              () => codec.encoder.write(value, buffer, 1),
              throwsRangeError,
            );
            expect(buffer, before);
          });
        }

        test(
          '$bits-bit ${endian.name} preserves all signed boundary values',
          () {
            final decimalCodec = getDecimalFixedPointCodec(
              FixedPointSignedness.signed,
              bits,
              0,
              endian: endian,
            );
            final binaryCodec = getBinaryFixedPointCodec(
              FixedPointSignedness.signed,
              bits,
              0,
              endian: endian,
            );

            for (final raw in [
              -half,
              -BigInt.one,
              BigInt.zero,
              half - BigInt.one,
            ]) {
              final decimalValue = rawDecimalFixedPoint(
                FixedPointSignedness.signed,
                bits,
                0,
              )(raw);
              final binaryValue = rawBinaryFixedPoint(
                FixedPointSignedness.signed,
                bits,
                0,
              )(raw);

              expect(
                decimalCodec.decode(decimalCodec.encode(decimalValue)),
                decimalValue,
              );
              expect(
                binaryCodec.decode(binaryCodec.encode(binaryValue)),
                binaryValue,
              );
            }
          },
        );
      }
    }
  });
}
