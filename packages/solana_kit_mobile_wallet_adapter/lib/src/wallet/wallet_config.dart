/// Configuration for a Mobile Wallet Adapter wallet endpoint.
///
/// Specifies the wallet's capabilities and limits for incoming MWA sessions.
class MobileWalletAdapterConfig {
  const MobileWalletAdapterConfig({
    this.maxTransactionsPerSigningRequest = 0,
    this.maxMessagesPerSigningRequest = 0,
    this.supportedTransactionVersions = const ['legacy'],
    this.noConnectionWarningTimeoutMs = 0,
    this.optionalFeatures = const [],
  });

  /// Maximum number of transactions per signing request (0 = unlimited).
  final int maxTransactionsPerSigningRequest;

  /// Maximum number of messages per signing request (0 = unlimited).
  final int maxMessagesPerSigningRequest;

  /// Supported transaction versions (e.g. `['legacy', '0']`).
  final List<String> supportedTransactionVersions;

  /// Timeout in ms before firing a no-connection warning in low-power
  /// mode (0 = disabled).
  final int noConnectionWarningTimeoutMs;

  /// Optional MWA features the wallet supports (e.g.
  /// `solana:signTransactions`, `solana:cloneAuthorization`).
  final List<String> optionalFeatures;

  /// Converts this config to a JSON-compatible map for capabilities response.
  Map<String, Object?> toCapabilitiesJson() => {
        'max_transactions_per_request': maxTransactionsPerSigningRequest,
        'max_messages_per_request': maxMessagesPerSigningRequest,
        'supported_transaction_versions': supportedTransactionVersions,
        'features': optionalFeatures,
      };
}

/// Configuration for the wallet's authorization token issuer.
class AuthIssuerConfig {
  const AuthIssuerConfig({
    required this.name,
    this.maxOutstandingTokensPerIdentity = 50,
    this.authorizationValidityMs = 3600000,
    this.reauthorizationValidityMs = 2592000000,
    this.reauthorizationNopDurationMs = 600000,
  });

  /// Human-readable name of the wallet (shown to dApps).
  final String name;

  /// Maximum outstanding authorization tokens per dApp identity.
  final int maxOutstandingTokensPerIdentity;

  /// Duration in ms an authorization is valid (default: 1 hour).
  final int authorizationValidityMs;

  /// Duration in ms a reauthorization is valid (default: 30 days).
  final int reauthorizationValidityMs;

  /// Duration in ms within which reauthorization is a no-op to avoid
  /// unnecessary reissue (default: 10 minutes).
  final int reauthorizationNopDurationMs;
}
