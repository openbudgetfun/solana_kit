import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Converts [value] to an unsigned decimal fixed-point value with the same
/// raw value, total bit width, and decimal scale.
DecimalFixedPoint toUnsignedDecimalFixedPoint(DecimalFixedPoint value) {
  if (value.signedness == FixedPointSignedness.unsigned) return value;
  return rawDecimalFixedPoint(
    FixedPointSignedness.unsigned,
    value.totalBits,
    value.decimals,
  )(value.raw);
}

/// Converts [value] to a signed decimal fixed-point value with the same raw
/// value, total bit width, and decimal scale.
DecimalFixedPoint toSignedDecimalFixedPoint(DecimalFixedPoint value) {
  if (value.signedness == FixedPointSignedness.signed) return value;
  return rawDecimalFixedPoint(
    FixedPointSignedness.signed,
    value.totalBits,
    value.decimals,
  )(value.raw);
}

/// Rescales [value] to [newTotalBits] and [newDecimals].
DecimalFixedPoint rescaleDecimalFixedPoint(
  DecimalFixedPoint value,
  int newTotalBits,
  int newDecimals, [
  FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
]) {
  if (newDecimals < 0) {
    throw RangeError.range(newDecimals, 0, null, 'newDecimals');
  }
  if (value.totalBits == newTotalBits && value.decimals == newDecimals) {
    return value;
  }

  final raw = switch (newDecimals.compareTo(value.decimals)) {
    0 => value.raw,
    1 => value.raw * _pow10(newDecimals - value.decimals),
    _ => _divideWithRounding(
      value.raw,
      _pow10(value.decimals - newDecimals),
      rounding,
    ),
  };

  return rawDecimalFixedPoint(value.signedness, newTotalBits, newDecimals)(raw);
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
      'Decimal fixed-point rescale cannot be represented without precision loss.',
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

BigInt _pow10(int exponent) {
  var result = BigInt.one;
  for (var i = 0; i < exponent; i++) {
    result *= BigInt.from(10);
  }
  return result;
}
