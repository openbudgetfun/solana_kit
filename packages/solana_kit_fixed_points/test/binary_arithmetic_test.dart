import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  final q4 = binaryFixedPoint(FixedPointSignedness.unsigned, 16, 4);
  final signedQ4 = binaryFixedPoint(FixedPointSignedness.signed, 16, 4);
  final q8 = binaryFixedPoint(FixedPointSignedness.unsigned, 16, 8);

  test('adds and subtracts binary fixed-point values', () {
    expect(
      addBinaryFixedPoint(q4('1.5'), q4('2.25')).toDecimalString(),
      '3.75',
    );
    expect(
      subtractBinaryFixedPoint(q4('2.25'), q4('1.5')).toDecimalString(),
      '0.75',
    );
    expect(() => subtractBinaryFixedPoint(q4('1'), q4('2')), throwsRangeError);
  });

  test('multiplies by scalars and fixed-point values', () {
    expect(
      multiplyBinaryFixedPoint(q4('1.5'), BigInt.from(3)).toDecimalString(),
      '4.5',
    );
    expect(
      multiplyBinaryFixedPoint(q4('2'), q8('0.25')).toDecimalString(),
      '0.5',
    );
    expect(
      multiplyBinaryFixedPoint(
        q4('1'),
        q8('0.10', FixedPointRoundingMode.round),
        FixedPointRoundingMode.round,
      ).toDecimalString(),
      '0.125',
    );
  });

  test('divides by scalars and fixed-point values', () {
    expect(
      divideBinaryFixedPoint(q4('10'), BigInt.from(2)).toDecimalString(),
      '5',
    );
    expect(divideBinaryFixedPoint(q4('1'), q8('0.25')).toDecimalString(), '4');
    expect(
      divideBinaryFixedPoint(
        signedQ4('-1'),
        BigInt.from(3),
        FixedPointRoundingMode.floor,
      ).toDecimalString(),
      '-0.375',
    );
    expect(
      divideBinaryFixedPoint(
        signedQ4('-1'),
        BigInt.from(3),
        FixedPointRoundingMode.ceil,
      ).toDecimalString(),
      '-0.3125',
    );
    expect(
      divideBinaryFixedPoint(
        signedQ4('-1'),
        BigInt.from(3),
        FixedPointRoundingMode.trunc,
      ).toDecimalString(),
      '-0.3125',
    );
    expect(
      divideBinaryFixedPoint(
        q4('1'),
        BigInt.from(3),
        FixedPointRoundingMode.floor,
      ).toDecimalString(),
      '0.3125',
    );
    expect(
      divideBinaryFixedPoint(
        q4('1'),
        BigInt.from(3),
        FixedPointRoundingMode.ceil,
      ).toDecimalString(),
      '0.375',
    );
    expect(
      divideBinaryFixedPoint(
        q4('1'),
        BigInt.from(4),
        FixedPointRoundingMode.round,
      ).toDecimalString(),
      '0.25',
    );
    expect(
      divideBinaryFixedPoint(
        q4('1'),
        BigInt.from(6),
        FixedPointRoundingMode.round,
      ).toDecimalString(),
      '0.1875',
    );
  });

  test('supports negation and absolute value', () {
    expect(negateBinaryFixedPoint(signedQ4('1.25')).toDecimalString(), '-1.25');
    expect(
      absoluteBinaryFixedPoint(signedQ4('-1.25')).toDecimalString(),
      '1.25',
    );
    final positive = q4('1.25');
    expect(identical(absoluteBinaryFixedPoint(positive), positive), isTrue);
  });

  test('rejects invalid arithmetic operands and overflows', () {
    expect(() => multiplyBinaryFixedPoint(q4('1'), 'bad'), throwsArgumentError);
    expect(() => divideBinaryFixedPoint(q4('1'), 'bad'), throwsArgumentError);
    expect(
      () => divideBinaryFixedPoint(q4('1'), BigInt.zero),
      throwsArgumentError,
    );
    expect(() => divideBinaryFixedPoint(q4('1'), q4('0')), throwsArgumentError);
    expect(() => negateBinaryFixedPoint(q4('1')), throwsArgumentError);
    expect(
      () => multiplyBinaryFixedPoint(q4('1'), signedQ4('1')),
      throwsArgumentError,
    );
    expect(
      () => divideBinaryFixedPoint(q4('1'), signedQ4('1')),
      throwsArgumentError,
    );
    expect(
      () => addBinaryFixedPoint(q4('4095.9375'), q4('0.0625')),
      throwsRangeError,
    );
    expect(
      () => multiplyBinaryFixedPoint(
        q4('1'),
        q8('0.10', FixedPointRoundingMode.round),
      ),
      throwsFormatException,
    );
    expect(
      () => divideBinaryFixedPoint(q4('1'), BigInt.from(3)),
      throwsFormatException,
    );
  });
}
