import 'dart:convert';
import 'dart:typed_data';

/// Compares two byte arrays in constant time to prevent timing attacks.
///
/// Returns `true` if both arrays have the same length and identical contents.
/// The comparison always examines all bytes regardless of where mismatches
/// occur, preventing an attacker from learning partial secret information
/// through timing side-channels.
bool _constantTimeBytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}

/// A string wrapper that redacts its value in [toString] output.
///
/// Use this for sensitive values like API keys, tokens, and passwords
/// that should not appear in logs, error messages, or debug output.
///
/// The original value is accessible via [value] for legitimate use,
/// but [toString] returns a redacted representation.
///
/// Equality comparison uses constant-time comparison to prevent
/// timing side-channel attacks.
///
/// ```dart
/// final key = SensitiveString('sk_live_abc123');
/// print(key); // SensitiveString(****123)
/// print(key.value); // sk_live_abc123
/// ```
class SensitiveString {
  /// Creates a [SensitiveString] wrapping the given [value].
  const SensitiveString(this.value);

  /// The underlying sensitive value.
  final String value;

  /// Returns a redacted representation showing only the last [visibleChars].
  ///
  /// Defaults to showing the last 3 characters.
  String redacted({int visibleChars = 3}) {
    if (value.length <= visibleChars) {
      return '****';
    }
    final suffix = value.substring(value.length - visibleChars);
    return '****$suffix';
  }

  @override
  String toString() => 'SensitiveString(${redacted()})';

  /// Compares two [SensitiveString] values in constant time.
  ///
  /// This prevents timing attacks that could leak information about
  /// how many characters match between two secrets.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensitiveString &&
          _constantTimeBytesEqual(
            utf8.encode(value),
            utf8.encode(other.value),
          );

  @override
  int get hashCode => value.hashCode;
}
