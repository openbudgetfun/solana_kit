import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';
import 'package:solana_kit_fixed_points/src/fixed_point_formatting.dart';

/// Formats a decimal fixed-point value as a canonical decimal string.
String decimalFixedPointToString(
  DecimalFixedPoint value, [
  FixedPointToStringOptions options = const FixedPointToStringOptions(),
]) {
  final scaled = applyDecimalsOption(value.raw, value.decimals, options);
  return formatScaledBigInt(
    scaled.raw,
    scaled.decimals,
    padTrailingZeros: options.padTrailingZeros,
  );
}

/// Formats a decimal fixed-point value using a caller-provided formatter.
///
/// The formatter receives ES2023-style scientific notation (`<raw>E-<decimals>`),
/// matching upstream's precision-preserving `Intl.NumberFormat` path.
String formatDecimalFixedPoint(
  String Function(String scientificNotation) formatter,
  DecimalFixedPoint value,
) {
  return formatter('${value.raw}E-${value.decimals}');
}

/// Converts a decimal fixed-point value to a Dart [double].
double decimalFixedPointToNumber(DecimalFixedPoint value) {
  return value.raw.toDouble() / _pow10Double(value.decimals);
}

double _pow10Double(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
