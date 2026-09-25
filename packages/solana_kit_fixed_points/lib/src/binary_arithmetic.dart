import 'package:solana_kit_fixed_points/src/binary_fixed_point.dart';
import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Adds two binary fixed-point values of the same shape.
BinaryFixedPoint addBinaryFixedPoint(BinaryFixedPoint a, BinaryFixedPoint b) {
  return a + b;
}

/// Subtracts [b] from [a], requiring both values to have the same shape.
BinaryFixedPoint subtractBinaryFixedPoint(
  BinaryFixedPoint a,
  BinaryFixedPoint b,
) {
  return a - b;
}

/// Multiplies [a] by [b] and returns a value with [a]'s shape.
///
/// When [b] is another [BinaryFixedPoint], it must have the same signedness;
/// its fractional bit count is used to rescale the product back to [a]'s
/// fractional bits.
BinaryFixedPoint multiplyBinaryFixedPoint(
  BinaryFixedPoint a,
  Object b, [
  FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
]) {
  final raw = switch (b) {
    final BigInt scalar => a.raw * scalar,
    final BinaryFixedPoint value => _multiplyByFixedPoint(a, value, rounding),
    _ => throw ArgumentError.value(
      b,
      'b',
      'Expected BigInt or BinaryFixedPoint.',
    ),
  };
  return _withBinaryRaw(a, raw);
}

/// Divides [a] by [b] and returns a value with [a]'s shape.
///
/// When [b] is another [BinaryFixedPoint], it must have the same signedness;
/// its fractional bit count is used to rescale the quotient back to [a]'s
/// fractional bits.
BinaryFixedPoint divideBinaryFixedPoint(
  BinaryFixedPoint a,
  Object b, [
  FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
]) {
  final raw = switch (b) {
    final BigInt scalar => _divideChecked(a.raw, scalar, rounding),
    final BinaryFixedPoint value => _divideByFixedPoint(a, value, rounding),
    _ => throw ArgumentError.value(
      b,
      'b',
      'Expected BigInt or BinaryFixedPoint.',
    ),
  };
  return _withBinaryRaw(a, raw);
}

/// Returns the additive inverse of a signed binary fixed-point value.
BinaryFixedPoint negateBinaryFixedPoint(BinaryFixedPoint value) {
  if (value.signedness != FixedPointSignedness.signed) {
    throw ArgumentError.value(
      value.signedness,
      'signedness',
      'Expected a signed value.',
    );
  }
  return _withBinaryRaw(value, -value.raw);
}

/// Returns the absolute value of [value].
BinaryFixedPoint absoluteBinaryFixedPoint(BinaryFixedPoint value) {
  return value.raw.isNegative ? _withBinaryRaw(value, -value.raw) : value;
}

BigInt _multiplyByFixedPoint(
  BinaryFixedPoint a,
  BinaryFixedPoint b,
  FixedPointRoundingMode rounding,
) {
  _assertSameSignedness(a, b, 'multiplyBinaryFixedPoint');
  return _divideChecked(a.raw * b.raw, _pow2(b.fractionalBits), rounding);
}

BigInt _divideByFixedPoint(
  BinaryFixedPoint a,
  BinaryFixedPoint b,
  FixedPointRoundingMode rounding,
) {
  _assertSameSignedness(a, b, 'divideBinaryFixedPoint');
  final scaledNumerator = a.raw * _pow2(b.fractionalBits);
  return _divideChecked(scaledNumerator, b.raw, rounding);
}

void _assertSameSignedness(
  BinaryFixedPoint a,
  BinaryFixedPoint b,
  String operation,
) {
  if (a.signedness != b.signedness) {
    throw ArgumentError(
      '$operation expected operands with the same signedness.',
    );
  }
}

BinaryFixedPoint _withBinaryRaw(BinaryFixedPoint shape, BigInt raw) {
  return rawBinaryFixedPoint(
    shape.signedness,
    shape.totalBits,
    shape.fractionalBits,
  )(raw);
}

BigInt _divideChecked(
  BigInt numerator,
  BigInt denominator,
  FixedPointRoundingMode rounding,
) {
  if (denominator == BigInt.zero) {
    throw ArgumentError.value(
      denominator,
      'denominator',
      'Expected a non-zero denominator.',
    );
  }

  final quotient = numerator ~/ denominator;
  final remainder = numerator.remainder(denominator);
  if (remainder == BigInt.zero) return quotient;

  return switch (rounding) {
    FixedPointRoundingMode.strict => throw const FormatException(
      'Binary fixed-point division cannot be represented without precision loss.',
    ),
    FixedPointRoundingMode.trunc => quotient,
    FixedPointRoundingMode.floor =>
      _roundsTowardPositiveInfinity(numerator, denominator)
          ? quotient
          : quotient - BigInt.one,
    FixedPointRoundingMode.ceil =>
      _roundsTowardPositiveInfinity(numerator, denominator)
          ? quotient + BigInt.one
          : quotient,
    FixedPointRoundingMode.round =>
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

BigInt _pow2(int exponent) => BigInt.one << exponent;
