/// Stable categories for wallet failures.
enum WalletStandardErrorCode {
  /// The wallet or account is no longer available.
  unavailable,

  /// The requested feature is not supported.
  unsupportedFeature,

  /// The wallet rejected the request.
  userRejected,

  /// The request is invalid for the active wallet or account.
  invalidRequest,

  /// A wallet returned malformed or inconsistent data.
  invalidResponse,

  /// The wallet disconnected during an operation.
  disconnected,

  /// A platform transport failed.
  transport,

  /// An operation exceeded its deadline.
  timeout,
}

/// A typed error produced by Wallet Standard operations.
class WalletStandardException implements Exception {
  /// Creates a wallet exception.
  const WalletStandardException(this.code, this.message, {this.cause});

  /// The stable failure category.
  final WalletStandardErrorCode code;

  /// A developer-readable explanation.
  final String message;

  /// The original platform or wallet failure, when available.
  final Object? cause;

  @override
  String toString() => 'WalletStandardException($code, $message)';
}
