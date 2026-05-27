import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('BinaryFixedPoint.parse', () {
    test('parses whole and finite fractional values', () {
      expect(
        BinaryFixedPoint.parse('12.5', fractionalBits: 4).raw,
        BigInt.from(200),
      );
      expect(
        BinaryFixedPoint.parse('.5', fractionalBits: 3).toDecimalString(),
        '0.5',
      );
      expect(
        BinaryFixedPoint.parse('7', fractionalBits: 0).toDecimalString(),
        '7',
      );
    });

    test('parses signed values when requested', () {
      final value = BinaryFixedPoint.parse(
        '-1.25',
        fractionalBits: 2,
        signedness: FixedPointSignedness.signed,
        totalBits: 8,
      );

      expect(value.raw, BigInt.from(-5));
      expect(value.toDecimalString(), '-1.25');
      expect(value.kind, 'binaryFixedPoint');
      expect(value.signedness, FixedPointSignedness.signed);
      expect(value.totalBits, 8);
    });

    test(
      'rejects malformed, negative unsigned, and over-precise strict values',
      () {
        expect(
          () => BinaryFixedPoint.parse('', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse('-1', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse('1.2.3', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse('a', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse(' 1', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse('+1', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse('1.a', fractionalBits: 2),
          throwsFormatException,
        );
        expect(
          () => BinaryFixedPoint.parse('0.1', fractionalBits: 4),
          throwsFormatException,
        );
      },
    );

    test('rejects invalid shapes and out-of-range values', () {
      expect(
        () => BinaryFixedPoint.parse('1', fractionalBits: -1),
        throwsRangeError,
      );
      expect(
        () => BinaryFixedPoint.parse('1', fractionalBits: 1, totalBits: 0),
        throwsRangeError,
      );
      expect(
        () => BinaryFixedPoint.parse('1', fractionalBits: 2, totalBits: 1),
        throwsRangeError,
      );
      expect(
        () => BinaryFixedPoint.parse('256', fractionalBits: 0, totalBits: 8),
        throwsRangeError,
      );
    });

    test('supports explicit rounding modes', () {
      expect(
        BinaryFixedPoint.parse(
          '0.1',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.down,
        ).raw,
        BigInt.one,
      );
      expect(
        BinaryFixedPoint.parse(
          '0.1',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.up,
        ).raw,
        BigInt.two,
      );
      expect(
        BinaryFixedPoint.parse(
          '0.09375',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.halfUp,
        ).raw,
        BigInt.two,
      );
      expect(
        BinaryFixedPoint.parse(
          '-0.1',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.up,
          signedness: FixedPointSignedness.signed,
        ).raw,
        BigInt.from(-2),
      );
      expect(
        BinaryFixedPoint.parse(
          '-0.1',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.floor,
          signedness: FixedPointSignedness.signed,
        ).raw,
        BigInt.from(-2),
      );
      expect(
        BinaryFixedPoint.parse(
          '-0.1',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.ceil,
          signedness: FixedPointSignedness.signed,
        ).raw,
        BigInt.from(-1),
      );
      expect(
        BinaryFixedPoint.parse(
          '0.1',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.trunc,
        ).raw,
        BigInt.one,
      );
      expect(
        BinaryFixedPoint.parse(
          '0.09375',
          fractionalBits: 4,
          rounding: FixedPointRoundingMode.round,
        ).raw,
        BigInt.two,
      );
    });
  });

  test('guards assert and test partial binary shapes', () {
    final value = binaryFixedPoint(FixedPointSignedness.unsigned, 8, 2)('1.25');
    expect(isBinaryFixedPoint(value), isTrue);
    expect(
      isBinaryFixedPoint(value, FixedPointSignedness.unsigned, 8, 2),
      isTrue,
    );
    expect(isBinaryFixedPoint(value, FixedPointSignedness.signed), isFalse);
    expect(
      isBinaryFixedPoint(value, FixedPointSignedness.unsigned, 16),
      isFalse,
    );
    expect(
      isBinaryFixedPoint(value, FixedPointSignedness.unsigned, 8, 3),
      isFalse,
    );
    expect(isBinaryFixedPoint('1.25'), isFalse);
    expect(
      () => assertIsBinaryFixedPoint(
        BinaryFixedPoint(
          raw: BigInt.from(300),
          fractionalBits: 0,
          totalBits: 8,
        ),
      ),
      throwsRangeError,
    );
    expect(
      () => assertIsBinaryFixedPoint(value, FixedPointSignedness.signed),
      throwsArgumentError,
    );
    expect(
      () => assertIsBinaryFixedPoint(value, FixedPointSignedness.unsigned, 16),
      throwsArgumentError,
    );
    expect(
      () =>
          assertIsBinaryFixedPoint(value, FixedPointSignedness.unsigned, 8, 3),
      throwsArgumentError,
    );
    expect(() => assertIsBinaryFixedPoint('1.25'), throwsArgumentError);
  });

  test('toDecimalString formats finite binary fractions', () {
    expect(
      BinaryFixedPoint(
        raw: BigInt.from(20),
        fractionalBits: 4,
      ).toDecimalString(),
      '1.25',
    );
    expect(
      BinaryFixedPoint(
        raw: BigInt.from(16),
        fractionalBits: 4,
      ).toDecimalString(),
      '1',
    );
  });

  test('adds, subtracts, compares, and hashes values with matching shapes', () {
    final one = BinaryFixedPoint.parse('1.00', fractionalBits: 4);
    final half = BinaryFixedPoint.parse('0.50', fractionalBits: 4);

    expect((one + half).toDecimalString(), '1.5');
    expect((one - half).toDecimalString(), '0.5');
    expect(one.compareTo(half), isPositive);
    expect(one, BinaryFixedPoint(raw: BigInt.from(16), fractionalBits: 4));
    expect(
      one.hashCode,
      BinaryFixedPoint(raw: BigInt.from(16), fractionalBits: 4).hashCode,
    );
    expect(one.toString(), '1');
  });

  test('supports signed arithmetic and rejects out-of-range results', () {
    final signed = binaryFixedPoint(FixedPointSignedness.signed, 8, 0);
    expect((signed('-1') + signed('2')).raw, BigInt.one);
    expect((signed('-1') - signed('2')).raw, BigInt.from(-3));
    expect(() => signed('127') + signed('1'), throwsRangeError);
  });

  test('rejects arithmetic and comparison with mismatched shapes', () {
    final q4 = BinaryFixedPoint.parse('1.00', fractionalBits: 4);
    final q5 = BinaryFixedPoint.parse('1.00', fractionalBits: 5);
    final signed = BinaryFixedPoint.parse(
      '1.00',
      fractionalBits: 4,
      signedness: FixedPointSignedness.signed,
    );

    expect(() => q4 + q5, throwsArgumentError);
    expect(() => q4 - signed, throwsArgumentError);
    expect(() => q4.compareTo(q5), throwsArgumentError);
  });

  test('rejects unsigned subtraction underflow', () {
    final low = BinaryFixedPoint.parse('0.50', fractionalBits: 4);
    final high = BinaryFixedPoint.parse('1.00', fractionalBits: 4);

    expect(() => low - high, throwsRangeError);
  });

  group('fixed-point factories', () {
    test('create values from strings, raw integers, and ratios', () {
      final parseSample = binaryFixedPoint(FixedPointSignedness.signed, 16, 15);
      final rawSample = rawBinaryFixedPoint(
        FixedPointSignedness.signed,
        16,
        15,
      );
      final ratio = ratioBinaryFixedPoint(FixedPointSignedness.unsigned, 64, 4);

      expect(parseSample('0.5').raw, BigInt.from(16384));
      expect(rawSample(BigInt.from(16384)).toDecimalString(), '0.5');
      expect(ratio(BigInt.one, BigInt.from(4)).toDecimalString(), '0.25');
      expect(isBinaryFixedPoint(ratio(BigInt.one, BigInt.from(4))), isTrue);
      expect(isBinaryFixedPoint('0.25'), isFalse);
    });

    test('round ratios and reject invalid ratios', () {
      final ratio = ratioBinaryFixedPoint(FixedPointSignedness.signed, 16, 4);

      expect(
        ratio(BigInt.one, BigInt.from(3), FixedPointRoundingMode.down).raw,
        BigInt.from(5),
      );
      expect(
        ratio(BigInt.one, BigInt.from(3), FixedPointRoundingMode.up).raw,
        BigInt.from(6),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.up).raw,
        BigInt.from(-6),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.floor).raw,
        BigInt.from(-6),
      );
      expect(
        ratio(BigInt.one, BigInt.from(3), FixedPointRoundingMode.ceil).raw,
        BigInt.from(6),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.ceil).raw,
        BigInt.from(-5),
      );
      expect(
        ratio(-BigInt.one, BigInt.from(3), FixedPointRoundingMode.trunc).raw,
        BigInt.from(-5),
      );
      expect(
        ratio(BigInt.one, BigInt.from(6), FixedPointRoundingMode.round).raw,
        BigInt.from(3),
      );
      expect(
        ratio(BigInt.one, BigInt.from(6), FixedPointRoundingMode.halfUp).raw,
        BigInt.from(3),
      );
      expect(() => ratio(BigInt.one, BigInt.from(3)), throwsFormatException);
      expect(() => ratio(BigInt.one, BigInt.zero), throwsArgumentError);
    });

    test('validate factory shape and raw ranges', () {
      expect(
        () => binaryFixedPoint(FixedPointSignedness.unsigned, 0, 0),
        throwsRangeError,
      );
      expect(
        () => rawBinaryFixedPoint(FixedPointSignedness.unsigned, 8, -1),
        throwsRangeError,
      );
      expect(
        () => rawBinaryFixedPoint(FixedPointSignedness.unsigned, 8, 9),
        throwsRangeError,
      );
      expect(
        () => rawBinaryFixedPoint(FixedPointSignedness.unsigned, 8, 0)(
          BigInt.from(-1),
        ),
        throwsRangeError,
      );
      expect(
        () => ratioBinaryFixedPoint(FixedPointSignedness.unsigned, 8, 0)(
          BigInt.from(256),
          BigInt.one,
        ),
        throwsRangeError,
      );
    });
  });
}
