/// A base58-encoded byte string.
extension type const Base58EncodedBytes(String value) implements String {}

/// A base64-encoded byte string.
extension type const Base64EncodedBytes(String value) implements String {}

/// A base64-encoded zstd-compressed byte string.
extension type const Base64EncodedZStdCompressedBytes(String value)
    implements String {}

/// A tuple of base58-encoded data and the encoding label `'base58'`.
typedef Base58EncodedDataResponse = (Base58EncodedBytes data, String encoding);

/// A tuple of base64-encoded data and the encoding label `'base64'`.
typedef Base64EncodedDataResponse = (Base64EncodedBytes data, String encoding);

/// A tuple of base64-encoded zstd-compressed data and the encoding label
/// `'base64+zstd'`.
typedef Base64EncodedZStdCompressedDataResponse = (
  Base64EncodedZStdCompressedBytes data,
  String encoding,
);
