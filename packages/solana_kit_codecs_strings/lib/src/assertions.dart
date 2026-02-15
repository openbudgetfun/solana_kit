import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Asserts that a given string contains only characters from the specified
/// [alphabet].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsInvalidStringForBase] if the string contains
/// characters not present in the alphabet.
void assertValidBaseString(
  String alphabet,
  String testValue, [
  String? givenValue,
]) {
  final effectiveValue = givenValue ?? testValue;
  for (var i = 0; i < testValue.length; i++) {
    if (!alphabet.contains(testValue[i])) {
      throw SolanaError(SolanaErrorCode.codecsInvalidStringForBase, {
        'alphabet': alphabet,
        'base': alphabet.length,
        'value': effectiveValue,
      });
    }
  }
}
