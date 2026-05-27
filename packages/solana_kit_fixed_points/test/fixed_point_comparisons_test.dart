import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('decimal comparisons', () {
    final usd = decimalFixedPoint(FixedPointSignedness.unsigned, 16, 2);
    final wideUsd = decimalFixedPoint(FixedPointSignedness.signed, 32, 2);
    final millis = decimalFixedPoint(FixedPointSignedness.unsigned, 16, 3);

    test('compare by raw value while allowing storage shape differences', () {
      expect(cmpDecimalFixedPoint(usd('1.25'), wideUsd('2.50')), -1);
      expect(cmpDecimalFixedPoint(usd('2.50'), wideUsd('2.50')), 0);
      expect(cmpDecimalFixedPoint(usd('3.75'), wideUsd('2.50')), 1);
    });

    test('provide boolean comparison helpers', () {
      final low = usd('1.25');
      final equal = wideUsd('1.25');
      final high = wideUsd('2.50');

      expect(eqDecimalFixedPoint(low, equal), isTrue);
      expect(eqDecimalFixedPoint(low, high), isFalse);
      expect(ltDecimalFixedPoint(low, high), isTrue);
      expect(ltDecimalFixedPoint(high, low), isFalse);
      expect(lteDecimalFixedPoint(low, equal), isTrue);
      expect(lteDecimalFixedPoint(high, low), isFalse);
      expect(gtDecimalFixedPoint(high, low), isTrue);
      expect(gtDecimalFixedPoint(low, high), isFalse);
      expect(gteDecimalFixedPoint(equal, low), isTrue);
      expect(gteDecimalFixedPoint(low, high), isFalse);
    });

    test('reject mismatched decimal scales', () {
      expect(
        () => cmpDecimalFixedPoint(usd('1'), millis('1')),
        throwsArgumentError,
      );
    });
  });

  group('binary comparisons', () {
    final q4 = binaryFixedPoint(FixedPointSignedness.unsigned, 16, 4);
    final wideQ4 = binaryFixedPoint(FixedPointSignedness.signed, 32, 4);
    final q8 = binaryFixedPoint(FixedPointSignedness.unsigned, 16, 8);

    test('compare by raw value while allowing storage shape differences', () {
      expect(cmpBinaryFixedPoint(q4('1.25'), wideQ4('2.5')), -1);
      expect(cmpBinaryFixedPoint(q4('2.5'), wideQ4('2.5')), 0);
      expect(cmpBinaryFixedPoint(q4('3.75'), wideQ4('2.5')), 1);
    });

    test('provide boolean comparison helpers', () {
      final low = q4('1.25');
      final equal = wideQ4('1.25');
      final high = wideQ4('2.5');

      expect(eqBinaryFixedPoint(low, equal), isTrue);
      expect(eqBinaryFixedPoint(low, high), isFalse);
      expect(ltBinaryFixedPoint(low, high), isTrue);
      expect(ltBinaryFixedPoint(high, low), isFalse);
      expect(lteBinaryFixedPoint(low, equal), isTrue);
      expect(lteBinaryFixedPoint(high, low), isFalse);
      expect(gtBinaryFixedPoint(high, low), isTrue);
      expect(gtBinaryFixedPoint(low, high), isFalse);
      expect(gteBinaryFixedPoint(equal, low), isTrue);
      expect(gteBinaryFixedPoint(low, high), isFalse);
    });

    test('reject mismatched fractional bits', () {
      expect(() => cmpBinaryFixedPoint(q4('1'), q8('1')), throwsArgumentError);
    });
  });
}
