import 'package:solana_kit_addresses/src/address.dart';

/// Returns a [Comparator] that sorts [Address] values using base58 collation
/// rules.
///
/// The comparator sorts addresses using a case-sensitive variant-aware string
/// comparison where lowercase letters sort before uppercase. This matches the
/// base58 alphabet ordering used by Solana.
///
/// This is suitable for sorting addresses in the same order as the Solana
/// runtime.
Comparator<Address> getAddressComparator() {
  return (Address x, Address y) {
    return _compareBase58(x.value, y.value);
  };
}

/// Compares two base58-encoded strings using character-by-character comparison
/// according to the base58 alphabet ordering.
///
/// The base58 alphabet is:
/// `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`
///
/// In this ordering, digits come first, then uppercase letters (skipping I
/// and O), then lowercase letters (skipping l). This comparator implements a
/// locale-independent sort that matches the TS `Intl.Collator` with
/// `caseFirst: 'lower'` and `sensitivity: 'variant'` for base58 strings.
int _compareBase58(String a, String b) {
  final minLen = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < minLen; i++) {
    final charA = a.codeUnitAt(i);
    final charB = b.codeUnitAt(i);
    if (charA != charB) {
      final orderA = _charOrder(charA);
      final orderB = _charOrder(charB);
      return orderA.compareTo(orderB);
    }
  }
  return a.length.compareTo(b.length);
}

/// Returns a sort-order value for a character code.
///
/// The ordering follows the ICU collation rules used by the TS
/// `Intl.Collator` with `caseFirst: 'lower'` and `sensitivity: 'variant'`:
/// - Digits 0-9 sort first
/// - Then letters, where for each letter position lowercase sorts before
///   uppercase (e.g., a < A < b < B)
int _charOrder(int codeUnit) {
  // Digits 0-9 (codeUnits 48-57) sort first
  if (codeUnit >= 48 && codeUnit <= 57) {
    return codeUnit - 48; // 0-9
  }
  // Letters: lowercase before uppercase for same letter
  // a-z: 97-122, A-Z: 65-90
  if (codeUnit >= 97 && codeUnit <= 122) {
    // lowercase letter: maps to (letter_index * 2 + 10)
    return (codeUnit - 97) * 2 + 10;
  }
  if (codeUnit >= 65 && codeUnit <= 90) {
    // uppercase letter: maps to (letter_index * 2 + 11)
    return (codeUnit - 65) * 2 + 11;
  }
  // Fallback for non-alphanumeric characters
  return codeUnit + 100;
}
