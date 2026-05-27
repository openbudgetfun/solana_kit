import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';
import 'package:test/test.dart';

void main() {
  group('getRawRange', () {
    test('returns unsigned two-complement range', () {
      final range = getRawRange(FixedPointSignedness.unsigned, 8);

      expect(range.min, BigInt.zero);
      expect(range.max, BigInt.from(255));
    });

    test('returns signed two-complement range', () {
      final range = getRawRange(FixedPointSignedness.signed, 8);

      expect(range.min, BigInt.from(-128));
      expect(range.max, BigInt.from(127));
    });

    test('rejects non-positive bit widths', () {
      expect(
        () => getRawRange(FixedPointSignedness.unsigned, 0),
        throwsRangeError,
      );
    });
  });
}
