import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('DecimalFixedPoint.parse', () {
    test('parses whole and fractional values', () {
      expect(
        DecimalFixedPoint.parse('12.34', decimals: 2),
        DecimalFixedPoint(raw: BigInt.from(1234), decimals: 2),
      );
      expect(
        DecimalFixedPoint.parse('.5', decimals: 3).toDecimalString(),
        '0.5',
      );
      expect(DecimalFixedPoint.parse('7', decimals: 0).toDecimalString(), '7');
    });

    test('parses signed values when requested', () {
      final value = DecimalFixedPoint.parse(
        '-1.25',
        decimals: 2,
        signedness: FixedPointSignedness.signed,
        totalBits: 8,
      );

      expect(value.raw, BigInt.from(-125));
      expect(value.toDecimalString(), '-1.25');
      expect(value.kind, 'decimalFixedPoint');
      expect(value.signedness, FixedPointSignedness.signed);
      expect(value.totalBits, 8);
    });

    test(
      'rejects malformed, negative unsigned, and over-precise strict values',
      () {
        expect(
          () => DecimalFixedPoint.parse('', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse('-1', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse('1.2.3', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse('a', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse(' 1', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse('+1', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse('1.a', decimals: 2),
          throwsFormatException,
        );
        expect(
          () => DecimalFixedPoint.parse('1.234', decimals: 2),
          throwsFormatException,
        );
      },
    );

    test('rejects invalid scales and bit widths', () {
      expect(
        () => DecimalFixedPoint.parse('1', decimals: -1),
        throwsRangeError,
      );
      expect(
        () => DecimalFixedPoint.parse('1', decimals: 0, totalBits: 0),
        throwsRangeError,
      );
    });

    test('rejects values outside their raw range', () {
      expect(
        () => DecimalFixedPoint.parse('256', decimals: 0, totalBits: 8),
        throwsRangeError,
      );
      expect(
        () => DecimalFixedPoint.parse(
          '-129',
          decimals: 0,
          signedness: FixedPointSignedness.signed,
          totalBits: 8,
        ),
        throwsRangeError,
      );
    });

    test('supports explicit rounding modes', () {
      expect(
        DecimalFixedPoint.parse(
          '1.239',
          decimals: 2,
          rounding: FixedPointRoundingMode.trunc,
        ).toDecimalString(),
        '1.23',
      );
      expect(
        DecimalFixedPoint.parse(
          '1.235',
          decimals: 2,
          rounding: FixedPointRoundingMode.round,
        ).toDecimalString(),
        '1.24',
      );
      expect(
        DecimalFixedPoint.parse(
          '1.234',
          decimals: 2,
          rounding: FixedPointRoundingMode.round,
        ).toDecimalString(),
        '1.23',
      );
      expect(
        DecimalFixedPoint.parse(
          '-1.2301',
          decimals: 2,
          rounding: FixedPointRoundingMode.floor,
          signedness: FixedPointSignedness.signed,
        ).toDecimalString(),
        '-1.24',
      );
      expect(
        DecimalFixedPoint.parse(
          '-1.2301',
          decimals: 2,
          rounding: FixedPointRoundingMode.ceil,
          signedness: FixedPointSignedness.signed,
        ).toDecimalString(),
        '-1.23',
      );
      expect(
        DecimalFixedPoint.parse(
          '1.239',
          decimals: 2,
          rounding: FixedPointRoundingMode.trunc,
        ).toDecimalString(),
        '1.23',
      );
      expect(
        DecimalFixedPoint.parse(
          '1.235',
          decimals: 2,
          rounding: FixedPointRoundingMode.round,
        ).toDecimalString(),
        '1.24',
      );
    });
  });

  test('guards assert and test partial decimal shapes', () {
    final value = decimalFixedPoint(FixedPointSignedness.unsigned, 8, 2)(
      '1.25',
    );
    expect(isDecimalFixedPoint(value), isTrue);
    expect(
      isDecimalFixedPoint(value, FixedPointSignedness.unsigned, 8, 2),
      isTrue,
    );
    expect(isDecimalFixedPoint(value, FixedPointSignedness.signed), isFalse);
    expect(
      isDecimalFixedPoint(value, FixedPointSignedness.unsigned, 16),
      isFalse,
    );
    expect(
      isDecimalFixedPoint(value, FixedPointSignedness.unsigned, 8, 3),
      isFalse,
    );
    expect(isDecimalFixedPoint('1.25'), isFalse);
    expect(
      () => assertIsDecimalFixedPoint(
        DecimalFixedPoint(raw: BigInt.from(300), decimals: 0, totalBits: 8),
      ),
      throwsRangeError,
    );
    expect(
      () => assertIsDecimalFixedPoint(value, FixedPointSignedness.signed),
      throwsArgumentError,
    );
    expect(
      () => assertIsDecimalFixedPoint(value, FixedPointSignedness.unsigned, 16),
      throwsArgumentError,
    );
    expect(
      () =>
          assertIsDecimalFixedPoint(value, FixedPointSignedness.unsigned, 8, 3),
      throwsArgumentError,
    );
    expect(() => assertIsDecimalFixedPoint('1.25'), throwsArgumentError);
  });

  test('toDecimalString trims trailing fractional zeroes', () {
    expect(
      DecimalFixedPoint(
        raw: BigInt.from(123400),
        decimals: 4,
      ).toDecimalString(),
      '12.34',
    );
    expect(
      DecimalFixedPoint(
        raw: BigInt.from(120000),
        decimals: 4,
      ).toDecimalString(),
      '12',
    );
  });

  test('adds, subtracts, compares, and hashes values with matching shapes', () {
    final one = DecimalFixedPoint.parse('1.00', decimals: 2);
    final half = DecimalFixedPoint.parse('0.50', decimals: 2);

    expect((one + half).toDecimalString(), '1.5');
    expect((one - half).toDecimalString(), '0.5');
    expect(one.compareTo(half), isPositive);
    expect(one, DecimalFixedPoint(raw: BigInt.from(100), decimals: 2));
    expect(
      one.hashCode,
      DecimalFixedPoint(raw: BigInt.from(100), decimals: 2).hashCode,
    );
    expect(one.toString(), '1');
  });

  test('supports signed arithmetic and rejects out-of-range results', () {
    final signed = decimalFixedPoint(FixedPointSignedness.signed, 8, 0);
    expect((signed('-1') + signed('2')).raw, BigInt.one);
    expect((signed('-1') - signed('2')).raw, BigInt.from(-3));
    expect(() => signed('127') + signed('1'), throwsRangeError);
  });

  test('rejects arithmetic and comparison with mismatched shapes', () {
    final cents = DecimalFixedPoint.parse('1.00', decimals: 2);
    final millis = DecimalFixedPoint.parse('1.000', decimals: 3);
    final signed = DecimalFixedPoint.parse(
      '1.00',
      decimals: 2,
      signedness: FixedPointSignedness.signed,
    );

    expect(() => cents + millis, throwsArgumentError);
    expect(() => cents - signed, throwsArgumentError);
    expect(() => cents.compareTo(millis), throwsArgumentError);
  });

  test('rejects unsigned subtraction underflow', () {
    final low = DecimalFixedPoint.parse('0.50', decimals: 2);
    final high = DecimalFixedPoint.parse('1.00', decimals: 2);

    expect(() => low - high, throwsRangeError);
  });

  group('fixed-point factories', () {
    test('create values from strings, raw integers, and ratios', () {
      final parseUsdc = decimalFixedPoint(FixedPointSignedness.unsigned, 64, 6);
      final rawUsdc = rawDecimalFixedPoint(
        FixedPointSignedness.unsigned,
        64,
        6,
      );
      final ratio = ratioDecimalFixedPoint(
        FixedPointSignedness.unsigned,
        64,
        4,
      );

      expect(parseUsdc('42.5').raw, BigInt.from(42500000));
      expect(rawUsdc(BigInt.from(42500000)).toDecimalString(), '42.5');
      expect(ratio(BigInt.one, BigInt.from(4)).toDecimalString(), '0.25');
      expect(isDecimalFixedPoint(ratio(BigInt.one, BigInt.from(4))), isTrue);
      expect(isDecimalFixedPoint('0.25'), isFalse);
    });

    test('round ratios and reject invalid ratios', () {
      final ratio = ratioDecimalFixedPoint(FixedPointSignedness.signed, 16, 2);

      expect(
        ratio(BigInt.one, BigInt.from(3), FixedPointRoundingMode.trunc).raw,
        BigInt.from(33),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.floor).raw,
        BigInt.from(-34),
      );
      expect(
        ratio(BigInt.one, BigInt.from(3), FixedPointRoundingMode.ceil).raw,
        BigInt.from(34),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.ceil).raw,
        BigInt.from(-33),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.trunc).raw,
        BigInt.from(-33),
      );
      expect(
        ratio(BigInt.one, BigInt.from(6), FixedPointRoundingMode.round).raw,
        BigInt.from(17),
      );
      expect(
        ratio(BigInt.one, BigInt.from(6), FixedPointRoundingMode.round).raw,
        BigInt.from(17),
      );
      expect(() => ratio(BigInt.one, BigInt.from(3)), throwsFormatException);
      expect(() => ratio(BigInt.one, BigInt.zero), throwsArgumentError);
    });

    test('validate factory shape and raw ranges', () {
      expect(
        () => decimalFixedPoint(FixedPointSignedness.unsigned, 0, 0),
        throwsRangeError,
      );
      expect(
        () => rawDecimalFixedPoint(FixedPointSignedness.unsigned, 8, -1),
        throwsRangeError,
      );
      expect(
        () => rawDecimalFixedPoint(FixedPointSignedness.unsigned, 8, 0)(
          BigInt.from(-1),
        ),
        throwsRangeError,
      );
      expect(
        () => ratioDecimalFixedPoint(FixedPointSignedness.unsigned, 8, 0)(
          BigInt.from(256),
          BigInt.one,
        ),
        throwsRangeError,
      );
    });
  });
}
