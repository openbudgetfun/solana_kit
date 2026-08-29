/// Exceptions thrown by the Solana Kit Pyth package.
library;

/// Base exception for all Pyth-specific failures.
///
/// Thrown when decoding binary Pyth payloads (Wormhole VAAs, accumulator
/// updates, on-chain price accounts) or when the Hermes HTTP API returns an
/// unexpected response.
class PythException implements Exception {
  /// Creates a [PythException] with a human-readable [message].
  const PythException(this.message);

  /// Human-readable description of the failure.
  final String message;

  @override
  String toString() => 'PythException: $message';
}

/// Exception thrown when a Hermes HTTP request ultimately fails.
class PythHttpException extends PythException {
  /// Creates a [PythHttpException] for a failed response.
  const PythHttpException({
    required String message,
    required this.statusCode,
    this.body,
  }) : super(message);

  /// The HTTP status code of the failed response.
  final int statusCode;

  /// The response body returned by the server, when available.
  final String? body;

  @override
  String toString() =>
      'PythHttpException(status: $statusCode): $message'
      '${body == null ? '' : ' — $body'}';
}

/// Exception thrown when binary Pyth data cannot be decoded.
class PythDecodeException extends PythException {
  /// Creates a [PythDecodeException].
  const PythDecodeException(super.message);
}
