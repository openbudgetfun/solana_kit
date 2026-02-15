import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Asserts that [value] is between [min] and [max] (inclusive) for a codec
/// named [codecDescription].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsNumberOutOfRange] if the value is out of range.
void assertNumberIsBetweenForCodec(
  String codecDescription,
  num min,
  num max,
  num value,
) {
  if (value < min || value > max) {
    throw SolanaError(SolanaErrorCode.codecsNumberOutOfRange, {
      'codecDescription': codecDescription,
      'min': min,
      'max': max,
      'value': value,
    });
  }
}

/// Asserts that [value] is between [min] and [max] (inclusive) for a codec
/// named [codecDescription], using [BigInt] comparison.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsNumberOutOfRange] if the value is out of range.
void assertBigIntIsBetweenForCodec(
  String codecDescription,
  BigInt min,
  BigInt max,
  BigInt value,
) {
  if (value < min || value > max) {
    throw SolanaError(SolanaErrorCode.codecsNumberOutOfRange, {
      'codecDescription': codecDescription,
      'min': min,
      'max': max,
      'value': value,
    });
  }
}
