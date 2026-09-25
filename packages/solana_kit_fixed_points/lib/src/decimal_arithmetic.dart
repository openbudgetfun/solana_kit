import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Adds two decimal fixed-point values of the same shape.
DecimalFixedPoint addDecimalFixedPoint(
  DecimalFixedPoint a,
  DecimalFixedPoint b,
) {
  return a + b;
}

/// Subtracts [b] from [a], requiring both values to have the same shape.
DecimalFixedPoint subtractDecimalFixedPoint(
  DecimalFixedPoint a,
  DecimalFixedPoint b,
) {
  return a - b;
}

/// Multiplies [a] by [b] and returns a value with [a]'s shape.
///
/// When [b] is another [DecimalFixedPoint], it must have the same signedness;
/// its scale is used to rescale the product back to [a]'s decimals.
DecimalFixedPoint multiplyDecimalFixedPoint(
  DecimalFixedPoint a,
  Object b, [
  FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
]) {
  final raw = switch (b) {
    final BigInt scalar => a.raw * scalar,
    final DecimalFixedPoint value => _multiplyByFixedPoint(a, value, rounding),
    _ => throw ArgumentError.value(
      b,
      'b',
      'Expected BigInt or DecimalFixedPoint.',
    ),
  };
  return _withDecimalRaw(a, raw);
}

/// Divides [a] by [b] and returns a value with [a]'s shape.
///
/// When [b] is another [DecimalFixedPoint], it must have the same signedness;
/// its scale is used to rescale the quotient back to [a]'s decimals.
DecimalFixedPoint divideDecimalFixedPoint(
  DecimalFixedPoint a,
  Object b, [
  FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
]) {
  final raw = switch (b) {
    final BigInt scalar => _divideChecked(a.raw, scalar, rounding),
    final DecimalFixedPoint value => _divideByFixedPoint(a, value, rounding),
    _ => throw ArgumentError.value(
      b,
      'b',
      'Expected BigInt or DecimalFixedPoint.',
    ),
  };
  return _withDecimalRaw(a, raw);
}

/// Returns the additive inverse of a signed decimal fixed-point value.
DecimalFixedPoint negateDecimalFixedPoint(DecimalFixedPoint value) {
  if (value.signedness != FixedPointSignedness.signed) {
    throw ArgumentError.value(
      value.signedness,
      'signedness',
      'Expected a signed value.',
    );
  }
  return _withDecimalRaw(value, -value.raw);
}

/// Returns the absolute value of [value].
DecimalFixedPoint absoluteDecimalFixedPoint(DecimalFixedPoint value) {
  return value.raw.isNegative ? _withDecimalRaw(value, -value.raw) : value;
}

BigInt _multiplyByFixedPoint(
  DecimalFixedPoint a,
  DecimalFixedPoint b,
  FixedPointRoundingMode rounding,
) {
  _assertSameSignedness(a, b, 'multiplyDecimalFixedPoint');
  return _divideChecked(a.raw * b.raw, _pow10(b.decimals), rounding);
}

BigInt _divideByFixedPoint(
  DecimalFixedPoint a,
  DecimalFixedPoint b,
  FixedPointRoundingMode rounding,
) {
  _assertSameSignedness(a, b, 'divideDecimalFixedPoint');
  final scaledNumerator = a.raw * _pow10(b.decimals);
  return _divideChecked(scaledNumerator, b.raw, rounding);
}

void _assertSameSignedness(
  DecimalFixedPoint a,
  DecimalFixedPoint b,
  String operation,
) {
  if (a.signedness != b.signedness) {
    throw ArgumentError(
      '$operation expected operands with the same signedness.',
    );
  }
}

DecimalFixedPoint _withDecimalRaw(DecimalFixedPoint shape, BigInt raw) {
  return rawDecimalFixedPoint(
    shape.signedness,
    shape.totalBits,
    shape.decimals,
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
      'Decimal fixed-point division cannot be represented without precision loss.',
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

BigInt _pow10(int exponent) {
  var result = BigInt.one;
  for (var i = 0; i < exponent; i++) {
    result *= BigInt.from(10);
  }
  return result;
}
