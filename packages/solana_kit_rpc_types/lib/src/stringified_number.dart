import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Represents a number which has been encoded as a string for transit over a
/// transport where loss of precision when using the native number type is a
/// concern. The JSON-RPC is such a transport.
extension type const StringifiedNumber(String value) implements String {}

/// Returns `true` if [putativeNumber] can be parsed as a number.
bool isStringifiedNumber(String putativeNumber) {
  return double.tryParse(putativeNumber) != null;
}

/// Asserts that [putativeNumber] can be parsed as a number.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.malformedNumberString] if the string cannot be parsed.
void assertIsStringifiedNumber(String putativeNumber) {
  if (double.tryParse(putativeNumber) == null) {
    throw SolanaError(SolanaErrorCode.malformedNumberString, {
      'value': putativeNumber,
    });
  }
}

/// Combines asserting that a string will parse as a number with coercing
/// it to the [StringifiedNumber] type. It's best used with untrusted input.
StringifiedNumber stringifiedNumber(String putativeNumber) {
  assertIsStringifiedNumber(putativeNumber);
  return StringifiedNumber(putativeNumber);
}
