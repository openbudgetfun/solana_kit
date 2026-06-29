import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// A binary fixed-point value.
///
/// The [raw] integer stores the mathematical value scaled by
/// `2 ^ fractionalBits`.
final class BinaryFixedPoint implements Comparable<BinaryFixedPoint> {
  /// Creates a binary fixed-point value from a raw scaled integer.
  const BinaryFixedPoint({
    required this.raw,
    required this.fractionalBits,
    this.signedness = FixedPointSignedness.unsigned,
    this.totalBits = 64,
  });

  /// Parses [value] as a binary fixed-point number.
  factory BinaryFixedPoint.parse(
    String value, {
    required int fractionalBits,
    FixedPointRoundingMode rounding = FixedPointRoundingMode.strict,
    FixedPointSignedness signedness = FixedPointSignedness.unsigned,
    int totalBits = 64,
  }) {
    _assertValidShape(fractionalBits, totalBits);

    final parsed = _parseDecimalMagnitude(value, signedness);
    final signedMagnitude = parsed.negative
        ? -parsed.magnitude
        : parsed.magnitude;
    final scaled = signedMagnitude * _pow2(fractionalBits);
    final raw = _divideWithRounding(scaled, _pow10(parsed.decimals), rounding);
    _assertRawFits(raw, signedness, totalBits);
    return BinaryFixedPoint(
      raw: raw,
      fractionalBits: fractionalBits,
      signedness: signedness,
      totalBits: totalBits,
    );
  }

  /// The raw integer value scaled by `2 ^ fractionalBits`.
  final BigInt raw;

  /// The number of binary fractional bits represented by [raw].
  final int fractionalBits;

  /// Whether [raw] may be negative.
  final FixedPointSignedness signedness;

  /// The bit width used to validate [raw].
  final int totalBits;

  /// The upstream-compatible kind tag for this value.
  String get kind => 'binaryFixedPoint';

  /// Formats this value as a decimal string when the representation is finite.
  String toDecimalString() {
    final sign = raw.isNegative ? '-' : '';
    final magnitude = raw.abs();
    if (fractionalBits == 0) return '$sign$magnitude';

    final scale = _pow2(fractionalBits);
    final whole = magnitude ~/ scale;
    var remainder = magnitude % scale;
    if (remainder == BigInt.zero) return '$sign$whole';

    final digits = StringBuffer();
    while (remainder != BigInt.zero) {
      remainder *= BigInt.from(10);
      digits.write(remainder ~/ scale);
      remainder %= scale;
    }
    return '$sign$whole.$digits';
  }

  /// Adds [other], requiring both values to use the same shape.
  BinaryFixedPoint operator +(BinaryFixedPoint other) {
    _assertSameShape(other);
    final next = raw + other.raw;
    _assertRawFits(next, signedness, totalBits);
    return _copyWithRaw(next);
  }

  /// Subtracts [other], requiring both values to use the same shape.
  BinaryFixedPoint operator -(BinaryFixedPoint other) {
    _assertSameShape(other);
    final next = raw - other.raw;
    _assertRawFits(next, signedness, totalBits);
    return _copyWithRaw(next);
  }

  @override
  int compareTo(BinaryFixedPoint other) {
    _assertSameShape(other);
    return raw.compareTo(other.raw);
  }

  @override
  bool operator ==(Object other) {
    return other is BinaryFixedPoint &&
        raw == other.raw &&
        fractionalBits == other.fractionalBits &&
        signedness == other.signedness &&
        totalBits == other.totalBits;
  }

  @override
  int get hashCode => Object.hash(raw, fractionalBits, signedness, totalBits);

  @override
  String toString() => toDecimalString();

  BinaryFixedPoint _copyWithRaw(BigInt next) {
    return BinaryFixedPoint(
      raw: next,
      fractionalBits: fractionalBits,
      signedness: signedness,
      totalBits: totalBits,
    );
  }

  void _assertSameShape(BinaryFixedPoint other) {
    if (fractionalBits != other.fractionalBits ||
        signedness != other.signedness ||
        totalBits != other.totalBits) {
      throw ArgumentError(
        'Expected another binary fixed-point value with the same shape.',
      );
    }
  }
}

/// Asserts that [value] is a [BinaryFixedPoint] matching the optional shape.
void assertIsBinaryFixedPoint(
  Object? value, [
  FixedPointSignedness? signedness,
  int? totalBits,
  int? fractionalBits,
]) {
  if (value is! BinaryFixedPoint) {
    throw ArgumentError.value(value, 'value', 'Expected a BinaryFixedPoint.');
  }
  if (signedness != null && value.signedness != signedness) {
    throw ArgumentError.value(
      value,
      'value',
      'Binary fixed-point signedness mismatch.',
    );
  }
  if (totalBits != null && value.totalBits != totalBits) {
    throw ArgumentError.value(
      value,
      'value',
      'Binary fixed-point total bit width mismatch.',
    );
  }
  if (fractionalBits != null && value.fractionalBits != fractionalBits) {
    throw ArgumentError.value(
      value,
      'value',
      'Binary fixed-point fractional bit scale mismatch.',
    );
  }
  _assertRawFits(value.raw, value.signedness, value.totalBits);
}

/// Returns whether [value] is a [BinaryFixedPoint] matching the optional shape.
bool isBinaryFixedPoint(
  Object? value, [
  FixedPointSignedness? signedness,
  int? totalBits,
  int? fractionalBits,
]) {
  try {
    assertIsBinaryFixedPoint(value, signedness, totalBits, fractionalBits);
    return true;
  } on Object {
    return false;
  }
}

/// Returns a factory that parses decimal strings into [BinaryFixedPoint] values.
BinaryFixedPoint Function(String value, [FixedPointRoundingMode rounding])
binaryFixedPoint(
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits,
) {
  _assertValidShape(fractionalBits, totalBits);
  return (value, [rounding = FixedPointRoundingMode.strict]) =>
      BinaryFixedPoint.parse(
        value,
        fractionalBits: fractionalBits,
        rounding: rounding,
        signedness: signedness,
        totalBits: totalBits,
      );
}

/// Returns a factory that wraps raw scaled integers as [BinaryFixedPoint] values.
BinaryFixedPoint Function(BigInt raw) rawBinaryFixedPoint(
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits,
) {
  _assertValidShape(fractionalBits, totalBits);
  return (raw) {
    _assertRawFits(raw, signedness, totalBits);
    return BinaryFixedPoint(
      raw: raw,
      fractionalBits: fractionalBits,
      signedness: signedness,
      totalBits: totalBits,
    );
  };
}

/// Returns a factory that converts ratios into [BinaryFixedPoint] values.
BinaryFixedPoint Function(
  BigInt numerator,
  BigInt denominator, [
  FixedPointRoundingMode rounding,
])
ratioBinaryFixedPoint(
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits,
) {
  _assertValidShape(fractionalBits, totalBits);
  return (numerator, denominator, [rounding = FixedPointRoundingMode.strict]) {
    if (denominator == BigInt.zero) {
      throw ArgumentError.value(
        denominator,
        'denominator',
        'Expected a non-zero denominator.',
      );
    }

    final raw = _divideWithRounding(
      numerator * _pow2(fractionalBits),
      denominator,
      rounding,
    );
    _assertRawFits(raw, signedness, totalBits);
    return BinaryFixedPoint(
      raw: raw,
      fractionalBits: fractionalBits,
      signedness: signedness,
      totalBits: totalBits,
    );
  };
}

_ParsedDecimal _parseDecimalMagnitude(
  String value,
  FixedPointSignedness signedness,
) {
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
  final fractionPart = parts.length == 2 ? parts[1] : '';
  final magnitude =
      BigInt.parse(wholePart) * _pow10(fractionPart.length) +
      (fractionPart.isEmpty ? BigInt.zero : BigInt.parse(fractionPart));
  return _ParsedDecimal(
    negative: negative,
    magnitude: magnitude,
    decimals: fractionPart.length,
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
      'Binary fixed-point value cannot be represented without precision loss.',
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

void _assertValidShape(int fractionalBits, int totalBits) {
  if (fractionalBits < 0) {
    throw RangeError.range(fractionalBits, 0, null, 'fractionalBits');
  }
  if (totalBits <= 0) throw RangeError.range(totalBits, 1, null, 'totalBits');
  if (fractionalBits > totalBits) {
    throw RangeError.range(fractionalBits, 0, totalBits, 'fractionalBits');
  }
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

final class _ParsedDecimal {
  const _ParsedDecimal({
    required this.negative,
    required this.magnitude,
    required this.decimals,
  });

  final bool negative;
  final BigInt magnitude;
  final int decimals;
}
