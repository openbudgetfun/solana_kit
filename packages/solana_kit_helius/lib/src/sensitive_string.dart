/// A string wrapper that redacts its value in [toString] output.
///
/// Use this for sensitive values like API keys, tokens, and passwords
/// that should not appear in logs, error messages, or debug output.
///
/// The original value is accessible via [value] for legitimate use,
/// but [toString] returns a redacted representation.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensitiveString && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
