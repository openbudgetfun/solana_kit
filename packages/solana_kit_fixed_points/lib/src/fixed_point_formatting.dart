import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Options for fixed-point string formatting helpers.
final class FixedPointToStringOptions {
  /// Creates fixed-point string formatting options.
  const FixedPointToStringOptions({
    this.decimals,
    this.padTrailingZeros = false,
    this.rounding = FixedPointRoundingMode.strict,
  });

  /// Target number of decimal fractional digits.
  final int? decimals;

  /// Whether to retain trailing zeroes up to the active decimal scale.
  final bool padTrailingZeros;

  /// Rounding mode used when [decimals] lowers the native decimal scale.
  final FixedPointRoundingMode rounding;
}

/// Applies the configured target decimal count to a base-10 scaled integer.
({int decimals, BigInt raw}) applyDecimalsOption(
  BigInt raw,
  int currentDecimals, [
  FixedPointToStringOptions options = const FixedPointToStringOptions(),
]) {
  final targetDecimals = options.decimals;
  if (targetDecimals == null || targetDecimals == currentDecimals) {
    return (decimals: currentDecimals, raw: raw);
  }
  if (targetDecimals < 0) {
    throw RangeError.range(targetDecimals, 0, null, 'decimals');
  }
  if (targetDecimals > currentDecimals) {
    return (
      decimals: targetDecimals,
      raw: raw * _pow10(targetDecimals - currentDecimals),
    );
  }

  return (
    decimals: targetDecimals,
    raw: _divideWithRounding(
      raw,
      _pow10(currentDecimals - targetDecimals),
      options.rounding,
    ),
  );
}

/// Formats a base-10 scaled integer as a decimal string.
String formatScaledBigInt(
  BigInt raw,
  int decimals, {
  bool padTrailingZeros = false,
}) {
  if (decimals < 0) {
    throw RangeError.range(decimals, 0, null, 'decimals');
  }
  if (decimals == 0) return raw.toString();

  final isNegative = raw.isNegative;
  final absDigits = raw.abs().toString();
  final padded = absDigits.padLeft(decimals + 1, '0');
  final integerPart = padded.substring(0, padded.length - decimals);
  var fractionalPart = padded.substring(padded.length - decimals);
  if (!padTrailingZeros) {
    fractionalPart = fractionalPart.replaceFirst(RegExp(r'0+$'), '');
  }

  final sign = isNegative ? '-' : '';
  if (fractionalPart.isEmpty) return '$sign$integerPart';
  return '$sign$integerPart.$fractionalPart';
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
      'Fixed-point value cannot be represented without precision loss.',
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
