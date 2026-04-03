/// Encoding format for account data returned by Solana RPC methods.
enum AccountEncoding {
  /// Base58 encoding.
  base58,

  /// Base64 encoding.
  base64,

  /// Base64 encoding with Zstandard compression.
  base64Zstd,

  /// Parsed JSON encoding for supported program accounts.
  jsonParsed;

  /// Serializes this value to the Solana JSON-RPC wire format.
  String toJson() => switch (this) {
    AccountEncoding.base64Zstd => 'base64+zstd',
    _ => name,
  };
}

/// Encoding format for transaction data returned by Solana RPC methods.
enum TransactionEncoding {
  /// Base58 encoding.
  base58,

  /// Base64 encoding.
  base64,

  /// JSON encoding.
  json,

  /// Parsed JSON encoding.
  jsonParsed;

  /// Serializes this value to the Solana JSON-RPC wire format.
  String toJson() => name;
}

/// Encoding format for serialized wire transactions sent to Solana RPC methods.
enum WireTransactionEncoding {
  /// Base58 encoding.
  base58,

  /// Base64 encoding.
  base64;

  /// Serializes this value to the Solana JSON-RPC wire format.
  String toJson() => name;
}
