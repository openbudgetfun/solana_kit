import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

/// A matcher that verifies a value is a valid Solana [Address].
///
/// ```dart
/// expect(address, isValidSolanaAddress);
/// ```
const Matcher isValidSolanaAddress = _IsValidAddressMatcher();

class _IsValidAddressMatcher extends Matcher {
  const _IsValidAddressMatcher();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Address) return false;
    try {
      assertIsAddress(item.toString());
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Description describe(Description description) =>
      description.add('is a valid Solana address');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Address) {
      return mismatchDescription.add('is not an Address');
    }
    return mismatchDescription.add('is not a valid base58-encoded address');
  }
}

/// Returns a matcher that verifies two [Address] values are equal.
///
/// ```dart
/// expect(actualAddress, equalsAddress(expectedAddress));
/// ```
Matcher equalsAddress(Address expected) =>
    isA<Address>().having((a) => a.toString(), 'address', expected.toString());
