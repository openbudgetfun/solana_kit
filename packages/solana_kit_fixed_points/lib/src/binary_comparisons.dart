import 'package:solana_kit_fixed_points/src/binary_fixed_point.dart';

/// Compares two binary fixed-point values with the same fractional bit count.
///
/// Returns `-1`, `0`, or `1` depending on whether [a] is less than, equal to,
/// or greater than [b]. Signedness and total bit width are storage concerns and
/// are allowed to differ.
int cmpBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  _assertComparable(a, b);
  return a.raw.compareTo(b.raw).sign;
}

/// Returns whether [a] and [b] represent the same binary fixed-point value.
bool eqBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  return cmpBinaryFixedPoint(a, b) == 0;
}

/// Returns whether [a] is strictly less than [b].
bool ltBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  return cmpBinaryFixedPoint(a, b) < 0;
}

/// Returns whether [a] is less than or equal to [b].
bool lteBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  return cmpBinaryFixedPoint(a, b) <= 0;
}

/// Returns whether [a] is strictly greater than [b].
bool gtBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  return cmpBinaryFixedPoint(a, b) > 0;
}

/// Returns whether [a] is greater than or equal to [b].
bool gteBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  return cmpBinaryFixedPoint(a, b) >= 0;
}

void _assertComparable(BinaryFixedPoint a, BinaryFixedPoint b) {
  if (a.fractionalBits != b.fractionalBits) {
    throw ArgumentError(
      'Expected binary fixed-point values with the same fractional bits.',
    );
  }
}
