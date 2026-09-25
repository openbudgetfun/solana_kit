import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Represents a `BigInt` which has been encoded as a string for transit over a
/// transport that does not support `BigInt` values natively. The JSON-RPC is
/// such a transport.
extension type const StringifiedBigInt(String value) implements String {}

/// Returns `true` if [putativeBigInt] can be parsed as a [BigInt].
bool isStringifiedBigInt(String putativeBigInt) {
  return BigInt.tryParse(putativeBigInt) != null;
}

/// Asserts that [putativeBigInt] can be parsed as a [BigInt].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.malformedBigintString] if the string cannot be parsed.
void assertIsStringifiedBigInt(String putativeBigInt) {
  if (BigInt.tryParse(putativeBigInt) == null) {
    throw SolanaError(SolanaErrorCode.malformedBigintString, {
      'value': putativeBigInt,
    });
  }
}

/// Combines asserting that a string will parse as a `BigInt` with coercing
/// it to the [StringifiedBigInt] type. It's best used with untrusted input.
StringifiedBigInt stringifiedBigInt(String putativeBigInt) {
  assertIsStringifiedBigInt(putativeBigInt);
  return StringifiedBigInt(putativeBigInt);
}
