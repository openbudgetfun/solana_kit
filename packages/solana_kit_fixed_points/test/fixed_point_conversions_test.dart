import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('decimal conversions', () {
    final unsigned = decimalFixedPoint(FixedPointSignedness.unsigned, 8, 2);
    final signed = decimalFixedPoint(FixedPointSignedness.signed, 8, 2);

    test('convert signedness while preserving shape and raw value', () {
      final unsignedValue = unsigned('1.00');
      expect(
        identical(toUnsignedDecimalFixedPoint(unsignedValue), unsignedValue),
        isTrue,
      );
      final signedValue = signed('1.00');
      final convertedUnsigned = toUnsignedDecimalFixedPoint(signedValue);
      expect(convertedUnsigned.signedness, FixedPointSignedness.unsigned);
      expect(convertedUnsigned.raw, signedValue.raw);

      expect(
        identical(toSignedDecimalFixedPoint(signedValue), signedValue),
        isTrue,
      );
      final convertedSigned = toSignedDecimalFixedPoint(unsignedValue);
      expect(convertedSigned.signedness, FixedPointSignedness.signed);
      expect(convertedSigned.raw, unsignedValue.raw);
    });

    test('reject out-of-range signedness conversions', () {
      expect(
        () => toUnsignedDecimalFixedPoint(signed('-1.00')),
        throwsRangeError,
      );
      expect(
        () => toSignedDecimalFixedPoint(
          rawDecimalFixedPoint(FixedPointSignedness.unsigned, 8, 0)(
            BigInt.from(200),
          ),
        ),
        throwsRangeError,
      );
    });

    test('rescale decimal precision and width', () {
      final value = decimalFixedPoint(FixedPointSignedness.unsigned, 32, 4)(
        '1.2345',
      );
      expect(identical(rescaleDecimalFixedPoint(value, 32, 4), value), isTrue);
      expect(
        rescaleDecimalFixedPoint(value, 32, 6).toDecimalString(),
        '1.2345',
      );
      expect(
        rescaleDecimalFixedPoint(
          value,
          32,
          2,
          FixedPointRoundingMode.floor,
        ).toDecimalString(),
        '1.23',
      );
      expect(
        rescaleDecimalFixedPoint(
          decimalFixedPoint(FixedPointSignedness.signed, 32, 4)('-1.2345'),
          32,
          2,
          FixedPointRoundingMode.floor,
        ).toDecimalString(),
        '-1.24',
      );
      expect(
        rescaleDecimalFixedPoint(
          decimalFixedPoint(FixedPointSignedness.signed, 32, 4)('-1.2345'),
          32,
          2,
          FixedPointRoundingMode.ceil,
        ).toDecimalString(),
        '-1.23',
      );
      expect(
        rescaleDecimalFixedPoint(
          value,
          32,
          2,
          FixedPointRoundingMode.ceil,
        ).toDecimalString(),
        '1.24',
      );
      expect(
        rescaleDecimalFixedPoint(
          value,
          32,
          2,
          FixedPointRoundingMode.round,
        ).toDecimalString(),
        '1.23',
      );
      expect(
        rescaleDecimalFixedPoint(
          decimalFixedPoint(FixedPointSignedness.signed, 32, 4)('-1.2350'),
          32,
          2,
          FixedPointRoundingMode.round,
        ).toDecimalString(),
        '-1.24',
      );
    });

    test('reject invalid decimal rescale results', () {
      final value = decimalFixedPoint(FixedPointSignedness.unsigned, 32, 4)(
        '1.2345',
      );
      expect(
        () => rescaleDecimalFixedPoint(value, 32, 2),
        throwsFormatException,
      );
      expect(() => rescaleDecimalFixedPoint(value, 8, 4), throwsRangeError);
      expect(() => rescaleDecimalFixedPoint(value, 32, -1), throwsRangeError);
    });
  });

  group('binary conversions', () {
    final unsigned = binaryFixedPoint(FixedPointSignedness.unsigned, 8, 2);
    final signed = binaryFixedPoint(FixedPointSignedness.signed, 8, 2);

    test('convert signedness while preserving shape and raw value', () {
      final unsignedValue = unsigned('1.00');
      expect(
        identical(toUnsignedBinaryFixedPoint(unsignedValue), unsignedValue),
        isTrue,
      );
      final signedValue = signed('1.00');
      final convertedUnsigned = toUnsignedBinaryFixedPoint(signedValue);
      expect(convertedUnsigned.signedness, FixedPointSignedness.unsigned);
      expect(convertedUnsigned.raw, signedValue.raw);

      expect(
        identical(toSignedBinaryFixedPoint(signedValue), signedValue),
        isTrue,
      );
      final convertedSigned = toSignedBinaryFixedPoint(unsignedValue);
      expect(convertedSigned.signedness, FixedPointSignedness.signed);
      expect(convertedSigned.raw, unsignedValue.raw);
    });

    test('reject out-of-range signedness conversions', () {
      expect(
        () => toUnsignedBinaryFixedPoint(signed('-1.00')),
        throwsRangeError,
      );
      expect(
        () => toSignedBinaryFixedPoint(
          rawBinaryFixedPoint(FixedPointSignedness.unsigned, 8, 0)(
            BigInt.from(200),
          ),
        ),
        throwsRangeError,
      );
    });

    test('rescale binary precision and width', () {
      final value = binaryFixedPoint(FixedPointSignedness.unsigned, 32, 4)(
        '1.3125',
      );
      expect(identical(rescaleBinaryFixedPoint(value, 32, 4), value), isTrue);
      expect(rescaleBinaryFixedPoint(value, 32, 6).toDecimalString(), '1.3125');
      expect(
        rescaleBinaryFixedPoint(
          value,
          32,
          2,
          FixedPointRoundingMode.floor,
        ).toDecimalString(),
        '1.25',
      );
      expect(
        rescaleBinaryFixedPoint(
          binaryFixedPoint(FixedPointSignedness.signed, 32, 4)('-1.3125'),
          32,
          2,
          FixedPointRoundingMode.floor,
        ).toDecimalString(),
        '-1.5',
      );
      expect(
        rescaleBinaryFixedPoint(
          binaryFixedPoint(FixedPointSignedness.signed, 32, 4)('-1.3125'),
          32,
          2,
          FixedPointRoundingMode.ceil,
        ).toDecimalString(),
        '-1.25',
      );
      expect(
        rescaleBinaryFixedPoint(
          value,
          32,
          2,
          FixedPointRoundingMode.ceil,
        ).toDecimalString(),
        '1.5',
      );
      expect(
        rescaleBinaryFixedPoint(
          value,
          32,
          2,
          FixedPointRoundingMode.round,
        ).toDecimalString(),
        '1.25',
      );
      expect(
        rescaleBinaryFixedPoint(
          binaryFixedPoint(FixedPointSignedness.signed, 32, 4)('-1.375'),
          32,
          2,
          FixedPointRoundingMode.round,
        ).toDecimalString(),
        '-1.5',
      );
    });

    test('reject invalid binary rescale results', () {
      final value = binaryFixedPoint(FixedPointSignedness.unsigned, 32, 4)(
        '1.3125',
      );
      expect(
        () => rescaleBinaryFixedPoint(value, 32, 2),
        throwsFormatException,
      );
      expect(() => rescaleBinaryFixedPoint(value, 4, 4), throwsRangeError);
      expect(() => rescaleBinaryFixedPoint(value, 32, -1), throwsRangeError);
    });
  });
}
