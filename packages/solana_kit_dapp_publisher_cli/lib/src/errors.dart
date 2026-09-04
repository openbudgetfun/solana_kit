/// Error type for the dApp publisher CLI.
///
/// The CLI surfaces user-facing messages in the same style as the upstream
/// TypeScript publishing CLI so that existing CI pipelines continue to work.
///
/// ```dart
/// try {
///   throw PublisherCliException('`--keypair` is required.');
/// } on PublisherCliException catch (error) {
///   print(error.message);
/// }
/// ```
class PublisherCliException implements Exception {
  /// Creates an exception with the given human-readable [message].
  const PublisherCliException(this.message);

  /// The user-facing message.
  final String message;

  @override
  String toString() => message;
}
