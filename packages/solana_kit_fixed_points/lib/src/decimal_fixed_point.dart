/// Whether a fixed-point value may be negative.
enum FixedPointSignedness {
  /// Values must be zero or greater.
  unsigned,

  /// Values may be negative.
  signed,
}

/// Rounding strategy used by fixed-point operations that must coerce an exact
/// mathematical result into a value with fewer bits of precision.
enum FixedPointRoundingMode {
  /// Reject values that cannot be represented exactly.
  strict,

  /// Round toward negative infinity.
  floor,

  /// Round toward positive infinity.
  ceil,

  /// Truncate extra digits toward zero.
  trunc,

  /// Round to the nearest unit, with ties away from zero.
  round,

  /// Truncate extra digits toward zero.
  @Deprecated('Use FixedPointRoundingMode.trunc instead.')
  down,

  /// Round away from zero when any discarded digit is non-zero.
  @Deprecated('Use floor or ceil depending on the sign, or round for nearest.')
  up,

  /// Round to the nearest unit, with ties away from zero.
  @Deprecated('Use FixedPointRoundingMode.round instead.')
  halfUp,
}

/// A decimal fixed-point value.
///
/// The [raw] integer stores the mathematical value scaled by `10 ^ decimals`.
final class DecimalFixedPoint implements Comparable<DecimalFixedPoint> {
  /// Creates a decimal fixed-point value from a raw scaled integer.
  const DecimalFixedPoint({
    required this.raw,
    required this.decimals,
    this.signedness = FixedPointSignedness.unsigned,
    this.totalBits = 64,
  });

  /// Parses [value] as a decimal fixed-point number.
  factory DecimalFixedPoint.parse(
    String value, {
    required int decimals,
    FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
    FixedPointSignedness signedness = FixedPointSignedness.unsigned,
    int totalBits = 64,
  }) {
    _assertValidShape(decimals, totalBits);

    final trimmed = value;
    final negative = trimmed.startsWith('-');
    final unsignedInput = negative ? trimmed.substring(1) : trimmed;
    final parts = unsignedInput.split('.');
    final digits = RegExp(r'^\d+$');
    if (trimmed.isEmpty ||
        (negative && signedness == FixedPointSignedness.unsigned) ||
        parts.length > 2 ||
        !digits.hasMatch(parts[0].isEmpty ? '0' : parts[0]) ||
        (parts.length == 2 &&
            parts[1].isNotEmpty &&
            !digits.hasMatch(parts[1]))) {
      throw FormatException(
        'Expected a ${signedness.name} decimal fixed-point string.',
        value,
      );
    }

    final wholePart = parts[0].isEmpty ? '0' : parts[0];
    var fractionPart = parts.length == 2 ? parts[1] : '';
    var incrementMagnitude = false;
    if (fractionPart.length > decimals) {
      final extra = fractionPart.substring(decimals);
      final hasTruncatedValue = extra.contains(RegExp('[1-9]'));
      incrementMagnitude = switch (rounding) {
        FixedPointRoundingMode.strict => throw FormatException(
          'Decimal fixed-point value cannot be represented without precision loss.',
          value,
        ),
        FixedPointRoundingMode.trunc || FixedPointRoundingMode.down => false,
        FixedPointRoundingMode.floor => negative && hasTruncatedValue,
        FixedPointRoundingMode.ceil => !negative && hasTruncatedValue,
        FixedPointRoundingMode.up => hasTruncatedValue,
        FixedPointRoundingMode.round ||
        FixedPointRoundingMode.halfUp => int.parse(extra[0]) >= 5,
      };
      fractionPart = fractionPart.substring(0, decimals);
    }

    final scale = _pow10(decimals);
    final fractionRaw = decimals == 0
        ? BigInt.zero
        : BigInt.parse(fractionPart.padRight(decimals, '0'));
    var magnitude = BigInt.parse(wholePart) * scale + fractionRaw;
    if (incrementMagnitude) magnitude += BigInt.one;

    final raw = negative ? -magnitude : magnitude;
    _assertRawFits(raw, signedness, totalBits);
    return DecimalFixedPoint(
      raw: raw,
      decimals: decimals,
      signedness: signedness,
      totalBits: totalBits,
    );
  }

  /// The raw integer value scaled by `10 ^ decimals`.
  final BigInt raw;

  /// The number of decimal places represented by [raw].
  final int decimals;

  /// Whether [raw] may be negative.
  final FixedPointSignedness signedness;

  /// The bit width used to validate [raw].
  final int totalBits;

  /// The upstream-compatible kind tag for this value.
  String get kind => 'decimalFixedPoint';

  /// Formats this value as a decimal string.
  String toDecimalString() {
    final sign = raw.isNegative ? '-' : '';
    final magnitude = raw.abs();
    if (decimals == 0) return '$sign$magnitude';

    final scale = _pow10(decimals);
    final whole = magnitude ~/ scale;
    final fraction = (magnitude % scale).toString().padLeft(decimals, '0');
    final trimmedFraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    return trimmedFraction.isEmpty
        ? '$sign$whole'
        : '$sign$whole.$trimmedFraction';
  }

  /// Adds [other], requiring both values to use the same shape.
  DecimalFixedPoint operator +(DecimalFixedPoint other) {
    _assertSameShape(other);
    final next = raw + other.raw;
    _assertRawFits(next, signedness, totalBits);
    return _copyWithRaw(next);
  }

  /// Subtracts [other], requiring both values to use the same shape.
  DecimalFixedPoint operator -(DecimalFixedPoint other) {
    _assertSameShape(other);
    final next = raw - other.raw;
    _assertRawFits(next, signedness, totalBits);
    return _copyWithRaw(next);
  }

  @override
  int compareTo(DecimalFixedPoint other) {
    _assertSameShape(other);
    return raw.compareTo(other.raw);
  }

  @override
  bool operator ==(Object other) {
    return other is DecimalFixedPoint &&
        raw == other.raw &&
        decimals == other.decimals &&
        signedness == other.signedness &&
        totalBits == other.totalBits;
  }

  @override
  int get hashCode => Object.hash(raw, decimals, signedness, totalBits);

  @override
  String toString() => toDecimalString();

  DecimalFixedPoint _copyWithRaw(BigInt next) {
    return DecimalFixedPoint(
      raw: next,
      decimals: decimals,
      signedness: signedness,
      totalBits: totalBits,
    );
  }

  void _assertSameShape(DecimalFixedPoint other) {
    if (decimals != other.decimals ||
        signedness != other.signedness ||
        totalBits != other.totalBits) {
      throw ArgumentError(
        'Expected another decimal fixed-point value with the same shape.',
      );
    }
  }
}

/// Asserts that [value] is a [DecimalFixedPoint] matching the optional shape.
void assertIsDecimalFixedPoint(
  Object? value, [
  FixedPointSignedness? signedness,
  int? totalBits,
  int? decimals,
]) {
  if (value is! DecimalFixedPoint) {
    throw ArgumentError.value(value, 'value', 'Expected a DecimalFixedPoint.');
  }
  if (signedness != null && value.signedness != signedness) {
    throw ArgumentError.value(
      value,
      'value',
      'Decimal fixed-point signedness mismatch.',
    );
  }
  if (totalBits != null && value.totalBits != totalBits) {
    throw ArgumentError.value(
      value,
      'value',
      'Decimal fixed-point total bit width mismatch.',
    );
  }
  if (decimals != null && value.decimals != decimals) {
    throw ArgumentError.value(
      value,
      'value',
      'Decimal fixed-point decimal scale mismatch.',
    );
  }
  _assertRawFits(value.raw, value.signedness, value.totalBits);
}

/// Returns whether [value] is a [DecimalFixedPoint] matching the optional shape.
bool isDecimalFixedPoint(
  Object? value, [
  FixedPointSignedness? signedness,
  int? totalBits,
  int? decimals,
]) {
  try {
    assertIsDecimalFixedPoint(value, signedness, totalBits, decimals);
    return true;
  } on Object {
    return false;
  }
}

/// Returns a factory that parses decimal strings into [DecimalFixedPoint] values.
DecimalFixedPoint Function(String value, [FixedPointRoundingMode rounding])
decimalFixedPoint(
  FixedPointSignedness signedness,
  int totalBits,
  int decimals,
) {
  _assertValidShape(decimals, totalBits);
  return (value, [rounding = FixedPointRoundingMode.strict]) =>
      DecimalFixedPoint.parse(
        value,
        decimals: decimals,
        rounding: rounding,
        signedness: signedness,
        totalBits: totalBits,
      );
}

/// Returns a factory that wraps raw scaled integers as [DecimalFixedPoint] values.
DecimalFixedPoint Function(BigInt raw) rawDecimalFixedPoint(
  FixedPointSignedness signedness,
  int totalBits,
  int decimals,
) {
  _assertValidShape(decimals, totalBits);
  return (raw) {
    _assertRawFits(raw, signedness, totalBits);
    return DecimalFixedPoint(
      raw: raw,
      decimals: decimals,
      signedness: signedness,
      totalBits: totalBits,
    );
  };
}

/// Returns a factory that converts ratios into [DecimalFixedPoint] values.
DecimalFixedPoint Function(
  BigInt numerator,
  BigInt denominator, [
  FixedPointRoundingMode rounding,
])
ratioDecimalFixedPoint(
  FixedPointSignedness signedness,
  int totalBits,
  int decimals,
) {
  _assertValidShape(decimals, totalBits);
  return (numerator, denominator, [rounding = FixedPointRoundingMode.strict]) {
    if (denominator == BigInt.zero) {
      throw ArgumentError.value(
        denominator,
        'denominator',
        'Expected a non-zero denominator.',
      );
    }

    final scaledNumerator = numerator * _pow10(decimals);
    final raw = _divideWithRounding(scaledNumerator, denominator, rounding);
    _assertRawFits(raw, signedness, totalBits);
    return DecimalFixedPoint(
      raw: raw,
      decimals: decimals,
      signedness: signedness,
      totalBits: totalBits,
    );
  };
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
      'Ratio cannot be represented without precision loss.',
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

void _assertValidShape(int decimals, int totalBits) {
  if (decimals < 0) throw RangeError.range(decimals, 0, null, 'decimals');
  if (totalBits <= 0) throw RangeError.range(totalBits, 1, null, 'totalBits');
}

void _assertRawFits(
  BigInt raw,
  FixedPointSignedness signedness,
  int totalBits,
) {
  final min = switch (signedness) {
    FixedPointSignedness.unsigned => BigInt.zero,
    FixedPointSignedness.signed => -_pow2(totalBits - 1),
  };
  final max = switch (signedness) {
    FixedPointSignedness.unsigned => _pow2(totalBits) - BigInt.one,
    FixedPointSignedness.signed => _pow2(totalBits - 1) - BigInt.one,
  };
  if (raw < min || raw > max) {
    throw RangeError(
      'Raw fixed-point value $raw is outside the $min..$max range.',
    );
  }
}

BigInt _pow10(int exponent) {
  var result = BigInt.one;
  for (var i = 0; i < exponent; i++) {
    result *= BigInt.from(10);
  }
  return result;
}

BigInt _pow2(int exponent) {
  var result = BigInt.one;
  for (var i = 0; i < exponent; i++) {
    result *= BigInt.two;
  }
  return result;
}
