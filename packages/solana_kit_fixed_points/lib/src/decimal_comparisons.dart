import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Compares two decimal fixed-point values with the same decimal scale.
///
/// Returns `-1`, `0`, or `1` depending on whether [a] is less than, equal to,
/// or greater than [b]. Signedness and total bit width are storage concerns and
/// are allowed to differ.
int cmpDecimalFixedPoint(DecimalFixedPoint a, DecimalFixedPoint b) {
  _assertComparable(a, b);
  return a.raw.compareTo(b.raw).sign;
}

/// Returns whether [a] and [b] represent the same decimal fixed-point value.
bool eqDecimalFixedPoint(DecimalFixedPoint a, DecimalFixedPoint b) {
  return cmpDecimalFixedPoint(a, b) == 0;
}

/// Returns whether [a] is strictly less than [b].
bool ltDecimalFixedPoint(DecimalFixedPoint a, DecimalFixedPoint b) {
  return cmpDecimalFixedPoint(a, b) < 0;
}

/// Returns whether [a] is less than or equal to [b].
bool lteDecimalFixedPoint(DecimalFixedPoint a, DecimalFixedPoint b) {
  return cmpDecimalFixedPoint(a, b) <= 0;
}

/// Returns whether [a] is strictly greater than [b].
bool gtDecimalFixedPoint(DecimalFixedPoint a, DecimalFixedPoint b) {
  return cmpDecimalFixedPoint(a, b) > 0;
}

/// Returns whether [a] is greater than or equal to [b].
bool gteDecimalFixedPoint(DecimalFixedPoint a, DecimalFixedPoint b) {
  return cmpDecimalFixedPoint(a, b) >= 0;
}

void _assertComparable(DecimalFixedPoint a, DecimalFixedPoint b) {
  if (a.decimals != b.decimals) {
    throw ArgumentError(
      'Expected decimal fixed-point values with the same decimals.',
    );
  }
}
