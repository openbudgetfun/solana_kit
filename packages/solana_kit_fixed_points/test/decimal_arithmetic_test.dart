import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  final usd = decimalFixedPoint(FixedPointSignedness.unsigned, 16, 2);
  final signedUsd = decimalFixedPoint(FixedPointSignedness.signed, 16, 2);
  final rate = decimalFixedPoint(FixedPointSignedness.unsigned, 16, 4);

  test('adds and subtracts decimal fixed-point values', () {
    expect(
      addDecimalFixedPoint(usd('1.50'), usd('2.25')).toDecimalString(),
      '3.75',
    );
    expect(
      subtractDecimalFixedPoint(usd('2.25'), usd('1.50')).toDecimalString(),
      '0.75',
    );
    expect(
      () => subtractDecimalFixedPoint(usd('1'), usd('2')),
      throwsRangeError,
    );
  });

  test('multiplies by scalars and fixed-point values', () {
    expect(
      multiplyDecimalFixedPoint(usd('1.50'), BigInt.from(3)).toDecimalString(),
      '4.5',
    );
    expect(
      multiplyDecimalFixedPoint(usd('100'), rate('0.0025')).toDecimalString(),
      '0.25',
    );
    expect(
      multiplyDecimalFixedPoint(
        usd('1.00'),
        rate('0.3333'),
        FixedPointRoundingMode.round,
      ).toDecimalString(),
      '0.33',
    );
  });

  test('divides by scalars and fixed-point values', () {
    expect(
      divideDecimalFixedPoint(usd('10.50'), BigInt.from(3)).toDecimalString(),
      '3.5',
    );
    expect(
      divideDecimalFixedPoint(usd('10'), rate('0.05')).toDecimalString(),
      '200',
    );
    expect(
      divideDecimalFixedPoint(
        signedUsd('-1.00'),
        BigInt.from(3),
        FixedPointRoundingMode.floor,
      ).toDecimalString(),
      '-0.34',
    );
    expect(
      divideDecimalFixedPoint(
        signedUsd('-1.00'),
        BigInt.from(3),
        FixedPointRoundingMode.ceil,
      ).toDecimalString(),
      '-0.33',
    );
    expect(
      divideDecimalFixedPoint(
        signedUsd('-1.00'),
        BigInt.from(3),
        FixedPointRoundingMode.trunc,
      ).toDecimalString(),
      '-0.33',
    );
    expect(
      divideDecimalFixedPoint(
        signedUsd('-1.00'),
        BigInt.from(3),
        FixedPointRoundingMode.up,
      ).toDecimalString(),
      '-0.34',
    );
    expect(
      divideDecimalFixedPoint(
        usd('1.00'),
        BigInt.from(3),
        FixedPointRoundingMode.floor,
      ).toDecimalString(),
      '0.33',
    );
    expect(
      divideDecimalFixedPoint(
        usd('1.00'),
        BigInt.from(3),
        FixedPointRoundingMode.ceil,
      ).toDecimalString(),
      '0.34',
    );
    expect(
      divideDecimalFixedPoint(
        usd('1.00'),
        BigInt.from(4),
        FixedPointRoundingMode.round,
      ).toDecimalString(),
      '0.25',
    );
    expect(
      divideDecimalFixedPoint(
        usd('1.00'),
        BigInt.from(6),
        FixedPointRoundingMode.round,
      ).toDecimalString(),
      '0.17',
    );
  });

  test('supports negation and absolute value', () {
    expect(
      negateDecimalFixedPoint(signedUsd('1.25')).toDecimalString(),
      '-1.25',
    );
    expect(
      absoluteDecimalFixedPoint(signedUsd('-1.25')).toDecimalString(),
      '1.25',
    );
    final positive = usd('1.25');
    expect(identical(absoluteDecimalFixedPoint(positive), positive), isTrue);
  });

  test('rejects invalid arithmetic operands and overflows', () {
    expect(
      () => multiplyDecimalFixedPoint(usd('1'), 'bad'),
      throwsArgumentError,
    );
    expect(() => divideDecimalFixedPoint(usd('1'), 'bad'), throwsArgumentError);
    expect(
      () => divideDecimalFixedPoint(usd('1'), BigInt.zero),
      throwsArgumentError,
    );
    expect(
      () => divideDecimalFixedPoint(usd('1'), usd('0')),
      throwsArgumentError,
    );
    expect(() => negateDecimalFixedPoint(usd('1')), throwsArgumentError);
    expect(
      () => multiplyDecimalFixedPoint(usd('1'), signedUsd('1')),
      throwsArgumentError,
    );
    expect(
      () => divideDecimalFixedPoint(usd('1'), signedUsd('1')),
      throwsArgumentError,
    );
    expect(
      () => addDecimalFixedPoint(usd('655.35'), usd('0.01')),
      throwsRangeError,
    );
    expect(
      () => multiplyDecimalFixedPoint(usd('1'), rate('0.3333')),
      throwsFormatException,
    );
    expect(
      () => divideDecimalFixedPoint(usd('1'), BigInt.from(3)),
      throwsFormatException,
    );
  });
}
