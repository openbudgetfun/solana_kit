import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Returns the inclusive raw integer range for a fixed-point value.
///
/// Signed ranges use two's-complement semantics. For example, an 8-bit signed
/// value spans `[-128, 127]`, while an 8-bit unsigned value spans `[0, 255]`.
({BigInt min, BigInt max}) getRawRange(
  FixedPointSignedness signedness,
  int totalBits,
) {
  if (totalBits <= 0) throw RangeError.range(totalBits, 1, null, 'totalBits');

  if (signedness == FixedPointSignedness.signed) {
    final half = BigInt.one << (totalBits - 1);
    return (min: -half, max: half - BigInt.one);
  }

  return (min: BigInt.zero, max: (BigInt.one << totalBits) - BigInt.one);
}
