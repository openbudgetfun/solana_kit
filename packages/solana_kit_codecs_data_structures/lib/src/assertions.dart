import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Checks the number of items in an array-like structure is expected.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsInvalidNumberOfItems] if [expected] != [actual].
void assertValidNumberOfItemsForCodec(
  String codecDescription,
  int expected,
  int actual,
) {
  if (expected != actual) {
    throw SolanaError(SolanaErrorCode.codecsInvalidNumberOfItems, {
      'actual': actual,
      'codecDescription': codecDescription,
      'expected': expected,
    });
  }
}
