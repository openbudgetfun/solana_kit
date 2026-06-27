/// Well-known MWA protocol error codes returned by wallets in JSON-RPC error
/// responses.
///
/// These codes are kept in sync with the Android `ProtocolContract` Java
/// class and the MWA specification.
abstract final class MwaProtocolErrorCode {
  /// Authorization was not granted for the requested account/scope.
  static const int authorizationFailed = -1;

  /// One or more payloads provided to the wallet were invalid.
  static const int invalidPayloads = -2;

  /// The wallet declined to sign the payloads.
  static const int notSigned = -3;

  /// The wallet failed to submit the signed transactions.
  static const int notSubmitted = -4;

  /// Too many payloads were included in the request.
  static const int tooManyPayloads = -5;

  /// Android origin attestation is required by the wallet.
  static const int attestOriginAndroid = -100;
}

/// A JSON-RPC error returned by the wallet during an MWA session.
class MwaProtocolError implements Exception {
  const MwaProtocolError({
    required this.jsonRpcMessageId,
    required this.code,
    required this.message,
    this.data,
  });

  /// The JSON-RPC message ID that produced this error.
  final int jsonRpcMessageId;

  /// The wallet error code (one of [MwaProtocolErrorCode] constants).
  final int code;

  /// A human-readable error message from the wallet.
  final String message;

  /// Optional additional error data from the wallet.
  final Object? data;

  @override
  String toString() =>
      'MwaProtocolError(id: $jsonRpcMessageId, code: $code, message: $message)';
}
