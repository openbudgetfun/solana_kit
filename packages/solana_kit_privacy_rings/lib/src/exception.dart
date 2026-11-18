/// Failure from the Privacy Rings client.
///
/// [message] never includes an API key or URL userinfo. [code] is a stable
/// machine-readable name such as `empty_deposit_batch`.
class PrivacyRingsException implements Exception {
  /// Creates an exception with a human-readable [message].
  PrivacyRingsException(this.message, {this.code, this.details});

  /// What failed.
  final String message;

  /// Stable identifier for the failure, when one applies.
  final String? code;

  /// Non-secret context. Omitted from [toString] when it could be large.
  final Map<String, Object?>? details;

  @override
  String toString() {
    final suffix = code == null ? '' : ' ($code)';
    return 'PrivacyRingsException$suffix: $message';
  }
}
