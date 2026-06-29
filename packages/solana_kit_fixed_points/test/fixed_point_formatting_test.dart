import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('decimal formatting', () {
    final usdc = decimalFixedPoint(FixedPointSignedness.unsigned, 64, 6);
    final signed = decimalFixedPoint(FixedPointSignedness.signed, 64, 6);

    test('formats canonical strings and padded strings', () {
      expect(decimalFixedPointToString(usdc('42.5')), '42.5');
      expect(
        decimalFixedPointToString(
          usdc('42.5'),
          const FixedPointToStringOptions(padTrailingZeros: true),
        ),
        '42.500000',
      );
      expect(decimalFixedPointToString(signed('-0.5')), '-0.5');
      expect(
        decimalFixedPointToString(
          usdc('42'),
          const FixedPointToStringOptions(decimals: 0),
        ),
        '42',
      );
    });

    test('respects decimal precision options', () {
      expect(
        decimalFixedPointToString(
          usdc('42.678'),
          const FixedPointToStringOptions(
            decimals: 2,
            rounding: FixedPointRoundingMode.floor,
          ),
        ),
        '42.67',
      );
      expect(
        decimalFixedPointToString(
          usdc('42.6'),
          const FixedPointToStringOptions(decimals: 8, padTrailingZeros: true),
        ),
        '42.60000000',
      );
      expect(
        decimalFixedPointToString(
          signed('-1.234'),
          const FixedPointToStringOptions(
            decimals: 2,
            rounding: FixedPointRoundingMode.floor,
          ),
        ),
        '-1.24',
      );
      expect(
        decimalFixedPointToString(
          signed('1.234'),
          const FixedPointToStringOptions(
            decimals: 2,
            rounding: FixedPointRoundingMode.ceil,
          ),
        ),
        '1.24',
      );
      expect(
        decimalFixedPointToString(
          signed('-1.234'),
          const FixedPointToStringOptions(
            decimals: 2,
            rounding: FixedPointRoundingMode.ceil,
          ),
        ),
        '-1.23',
      );
      expect(
        decimalFixedPointToString(
          signed('1.235'),
          const FixedPointToStringOptions(
            decimals: 2,
            rounding: FixedPointRoundingMode.round,
          ),
        ),
        '1.24',
      );
      expect(
        () => decimalFixedPointToString(
          usdc('42.678'),
          const FixedPointToStringOptions(decimals: 2),
        ),
        throwsFormatException,
      );
      expect(
        () => decimalFixedPointToString(
          usdc('42.678'),
          const FixedPointToStringOptions(decimals: -1),
        ),
        throwsRangeError,
      );
    });

    test('supports formatter and double conversion helpers', () {
      expect(
        formatDecimalFixedPoint((value) => 'formatted:$value', usdc('1234.5')),
        'formatted:1234500000E-6',
      );
      expect(decimalFixedPointToNumber(usdc('42.5')), 42.5);
    });
  });

  group('binary formatting', () {
    final q4 = binaryFixedPoint(FixedPointSignedness.unsigned, 16, 4);
    final signedQ4 = binaryFixedPoint(FixedPointSignedness.signed, 16, 4);
    final whole = binaryFixedPoint(FixedPointSignedness.unsigned, 16, 0);

    test('converts to base-10 scaled integers', () {
      final base10 = binaryFixedPointToBase10(q4('0.5'));
      expect(base10.raw, BigInt.from(5000));
      expect(base10.decimals, 4);
      expect(
        base10,
        BinaryFixedPointBase10(raw: BigInt.from(5000), decimals: 4),
      );
      expect(base10.hashCode, isA<int>());
      final wholeBase10 = binaryFixedPointToBase10(whole('7'));
      expect(wholeBase10.raw, BigInt.from(7));
      expect(wholeBase10.decimals, 0);
      expect(base10 == wholeBase10, isFalse);
    });

    test('formats canonical strings and padded strings', () {
      expect(binaryFixedPointToString(q4('0.5')), '0.5');
      expect(
        binaryFixedPointToString(
          q4('0.5'),
          const FixedPointToStringOptions(padTrailingZeros: true),
        ),
        '0.5000',
      );
      expect(binaryFixedPointToString(signedQ4('-0.5')), '-0.5');
      expect(binaryFixedPointToString(whole('7')), '7');
    });

    test('respects decimal precision options', () {
      expect(
        binaryFixedPointToString(
          q4('0.3125'),
          const FixedPointToStringOptions(
            decimals: 2,
            rounding: FixedPointRoundingMode.round,
          ),
        ),
        '0.31',
      );
      expect(
        binaryFixedPointToString(
          q4('0.5'),
          const FixedPointToStringOptions(decimals: 6, padTrailingZeros: true),
        ),
        '0.500000',
      );
      expect(
        () => binaryFixedPointToString(
          q4('0.3125'),
          const FixedPointToStringOptions(decimals: 2),
        ),
        throwsFormatException,
      );
    });

    test('supports formatter and double conversion helpers', () {
      expect(
        formatBinaryFixedPoint((value) => 'formatted:$value', q4('0.5')),
        'formatted:5000E-4',
      );
      expect(binaryFixedPointToNumber(q4('0.5')), 0.5);
      expect(binaryFixedPointToNumber(whole('7')), 7);
    });
  });

  test('formats scaled integers directly', () {
    expect(formatScaledBigInt(BigInt.from(123400), 4), '12.34');
    expect(formatScaledBigInt(BigInt.from(-1200), 2), '-12');
    expect(formatScaledBigInt(BigInt.from(12), 0), '12');
    expect(() => formatScaledBigInt(BigInt.one, -1), throwsRangeError);
  });
}
