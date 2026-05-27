import 'package:solana_kit_fixed_points/src/binary_fixed_point.dart';
import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Exact base-10 representation of a binary fixed-point value.
final class BinaryFixedPointBase10 {
  /// Creates a base-10 scaled integer representation.
  const BinaryFixedPointBase10({required this.raw, required this.decimals});

  /// The base-10 scaled raw integer.
  final BigInt raw;

  /// The number of decimal fractional digits represented by [raw].
  final int decimals;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryFixedPointBase10 &&
          runtimeType == other.runtimeType &&
          raw == other.raw &&
          decimals == other.decimals;

  @override
  int get hashCode => Object.hash(runtimeType, raw, decimals);
}

/// Converts [value] to an exact base-10 `(raw, decimals)` representation.
BinaryFixedPointBase10 binaryFixedPointToBase10(BinaryFixedPoint value) {
  final decimals = value.fractionalBits;
  return BinaryFixedPointBase10(
    raw: decimals == 0 ? value.raw : value.raw * _pow5(decimals),
    decimals: decimals,
  );
}

/// Converts [value] to an unsigned binary fixed-point value with the same raw
/// value, total bit width, and fractional bit count.
BinaryFixedPoint toUnsignedBinaryFixedPoint(BinaryFixedPoint value) {
  if (value.signedness == FixedPointSignedness.unsigned) return value;
  return rawBinaryFixedPoint(
    FixedPointSignedness.unsigned,
    value.totalBits,
    value.fractionalBits,
  )(value.raw);
}

/// Converts [value] to a signed binary fixed-point value with the same raw
/// value, total bit width, and fractional bit count.
BinaryFixedPoint toSignedBinaryFixedPoint(BinaryFixedPoint value) {
  if (value.signedness == FixedPointSignedness.signed) return value;
  return rawBinaryFixedPoint(
    FixedPointSignedness.signed,
    value.totalBits,
    value.fractionalBits,
  )(value.raw);
}

/// Rescales [value] to [newTotalBits] and [newFractionalBits].
BinaryFixedPoint rescaleBinaryFixedPoint(
  BinaryFixedPoint value,
  int newTotalBits,
  int newFractionalBits, [
  FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
]) {
  if (newFractionalBits < 0) {
    throw RangeError.range(newFractionalBits, 0, null, 'newFractionalBits');
  }
  if (value.totalBits == newTotalBits &&
      value.fractionalBits == newFractionalBits) {
    return value;
  }

  final raw = switch (newFractionalBits.compareTo(value.fractionalBits)) {
    0 => value.raw,
    1 => value.raw << (newFractionalBits - value.fractionalBits),
    _ => _divideWithRounding(
      value.raw,
      BigInt.one << (value.fractionalBits - newFractionalBits),
      rounding,
    ),
  };

  return rawBinaryFixedPoint(value.signedness, newTotalBits, newFractionalBits)(
    raw,
  );
}

BigInt _divideWithRounding(
  BigInt numerator,
  BigInt denominator,
  FixedPointRoundingMode rounding,
) {
  final quotient = numerator ~/ denominator;
  final remainder = numerator.remainder(denominator);
  if (remainder == BigInt.zero) return quotient;

  return switch (rounding) {
    FixedPointRoundingMode.strict => throw const FormatException(
      'Binary fixed-point rescale cannot be represented without precision loss.',
    ),
    FixedPointRoundingMode.trunc || FixedPointRoundingMode.down => quotient,
    FixedPointRoundingMode.floor =>
      _roundsTowardPositiveInfinity(numerator, denominator)
          ? quotient
          : quotient - BigInt.one,
    FixedPointRoundingMode.ceil =>
      _roundsTowardPositiveInfinity(numerator, denominator)
          ? quotient + BigInt.one
          : quotient,
    FixedPointRoundingMode.up =>
      quotient + _roundingDirection(numerator, denominator),
    FixedPointRoundingMode.round || FixedPointRoundingMode.halfUp =>
      (remainder.abs() * BigInt.two >= denominator.abs())
          ? quotient + _roundingDirection(numerator, denominator)
          : quotient,
  };
}

BigInt _roundingDirection(BigInt numerator, BigInt denominator) {
  return _roundsTowardPositiveInfinity(numerator, denominator)
      ? BigInt.one
      : -BigInt.one;
}

bool _roundsTowardPositiveInfinity(BigInt numerator, BigInt denominator) {
  return numerator.isNegative == denominator.isNegative;
}

BigInt _pow5(int exponent) {
  var result = BigInt.one;
  for (var i = 0; i < exponent; i++) {
    result *= BigInt.from(5);
  }
  return result;
}
