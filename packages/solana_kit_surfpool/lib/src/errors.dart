/// Base exception thrown by the Surfpool SDK package.
class SurfpoolException implements Exception {
  /// Creates a Surfpool exception with a human-readable [message].
  const SurfpoolException(this.message, {this.cause});

  /// Human-readable description of the failure.
  final String message;

  /// Optional underlying error or payload that caused the failure.
  final Object? cause;

  @override
  String toString() {
    final cause = this.cause;
    if (cause == null) return 'SurfpoolException: $message';
    return 'SurfpoolException: $message ($cause)';
  }
}

/// Exception thrown for JSON-RPC transport or response failures.
class SurfpoolRpcException extends SurfpoolException {
  /// Creates a JSON-RPC exception.
  const SurfpoolRpcException(
    super.message, {
    required this.method,
    this.statusCode,
    this.rpcCode,
    super.cause,
  });

  /// JSON-RPC method that was being called.
  final String method;

  /// HTTP status code when the failure happened at the HTTP layer.
  final int? statusCode;

  /// JSON-RPC error code when the Surfpool endpoint returned one.
  final int? rpcCode;

  @override
  String toString() {
    final parts = [
      'SurfpoolRpcException: $message',
      'method: $method',
      if (statusCode != null) 'statusCode: $statusCode',
      if (rpcCode != null) 'rpcCode: $rpcCode',
      if (cause != null) 'cause: $cause',
    ];
    return parts.join(', ');
  }
}

/// Exception thrown when the `surfpool` CLI cannot be started or managed.
class SurfnetProcessException extends SurfpoolException {
  /// Creates a Surfnet process exception.
  const SurfnetProcessException(super.message, {super.cause});
}
