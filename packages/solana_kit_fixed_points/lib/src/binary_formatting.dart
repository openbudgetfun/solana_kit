import 'package:solana_kit_fixed_points/src/binary_conversions.dart';
import 'package:solana_kit_fixed_points/src/binary_fixed_point.dart';
import 'package:solana_kit_fixed_points/src/fixed_point_formatting.dart';

/// Formats a binary fixed-point value as a canonical decimal string.
String binaryFixedPointToString(
  BinaryFixedPoint value, [
  FixedPointToStringOptions options = const FixedPointToStringOptions(),
]) {
  final base10 = binaryFixedPointToBase10(value);
  final scaled = applyDecimalsOption(base10.raw, base10.decimals, options);
  return formatScaledBigInt(
    scaled.raw,
    scaled.decimals,
    padTrailingZeros: options.padTrailingZeros,
  );
}

/// Formats a binary fixed-point value using a caller-provided formatter.
///
/// The formatter receives ES2023-style scientific notation (`<raw>E-<decimals>`),
/// matching upstream's precision-preserving `Intl.NumberFormat` path.
String formatBinaryFixedPoint(
  String Function(String scientificNotation) formatter,
  BinaryFixedPoint value,
) {
  final base10 = binaryFixedPointToBase10(value);
  return formatter('${base10.raw}E-${base10.decimals}');
}

/// Converts a binary fixed-point value to a Dart [double].
double binaryFixedPointToNumber(BinaryFixedPoint value) {
  if (value.fractionalBits == 0) return value.raw.toDouble();

  final scale = BigInt.one << value.fractionalBits;
  final integerPart = value.raw ~/ scale;
  final fractionalPart =
      (value.raw - integerPart * scale).toDouble() /
      _pow2Double(value.fractionalBits);
  return integerPart.toDouble() + fractionalPart;
}

double _pow2Double(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 2;
  }
  return result;
}
