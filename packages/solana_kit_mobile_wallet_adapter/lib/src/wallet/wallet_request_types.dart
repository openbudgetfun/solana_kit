import 'dart:async';

import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

/// An error produced by the wallet when declining or rejecting a request.
///
/// This is distinct from [MwaProtocolError] (in the protocol package), which
/// represents errors received _from_ a wallet. This class represents errors
/// produced _by_ the wallet.
class WalletRequestError implements Exception {
  const WalletRequestError({
    required this.code,
    required this.message,
    this.data,
  });

  /// MWA protocol error code (one of [MwaProtocolErrorCode] constants).
  final int code;

  /// Human-readable error message.
  final String message;

  /// Optional additional error data.
  final Map<String, Object?>? data;

  @override
  String toString() => 'WalletRequestError($code): $message';
}

/// Base class for all wallet-side MWA requests.
///
/// Every request has a unique [requestId] and [sessionId], and must be
/// completed by calling one of the `completeWith*` methods. Failing to
/// complete a request will hang the dApp.
sealed class WalletRequest {
  WalletRequest({
    required this.requestId,
    required this.sessionId,
  });

  /// Unique identifier for this request within the session.
  final String requestId;

  /// Identifier of the MWA session.
  final String sessionId;

  /// Internal completer for resolving the request.
  final Completer<Map<String, Object?>> _completer =
      Completer<Map<String, Object?>>();

  /// Future that resolves when the wallet completes this request.
  Future<Map<String, Object?>> get future => _completer.future;

  /// Cancels the request with an internal error.
  void cancel() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.notSigned,
          message: 'Request cancelled',
        ),
      );
    }
  }

  /// Completes the request with an internal error.
  void completeWithInternalError(Object error) {
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
  }

  /// Completes the request with a successful result.
  void _complete(Map<String, Object?> result) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
  }
}

/// A dApp is requesting authorization.
class AuthorizeDappRequest extends WalletRequest {
  AuthorizeDappRequest({
    required super.requestId,
    required super.sessionId,
    this.identityName,
    this.identityUri,
    this.iconRelativeUri,
    this.chain,
    this.features,
    this.addresses,
    this.signInPayload,
  });

  /// Creates an [AuthorizeDappRequest] from a JSON-RPC params map.
  factory AuthorizeDappRequest.fromParams({
    required String requestId,
    required String sessionId,
    required Map<String, Object?> params,
  }) {
    final identity = params['identity'] as Map<String, Object?>?;
    final signInPayloadJson =
        params['sign_in_payload'] as Map<String, Object?>?;

    return AuthorizeDappRequest(
      requestId: requestId,
      sessionId: sessionId,
      identityName: identity?['name'] as String?,
      identityUri: identity?['uri'] as String?,
      iconRelativeUri: identity?['icon'] as String?,
      chain: params['chain'] as String?,
      features: (params['features'] as List<Object?>?)?.cast<String>(),
      addresses: (params['addresses'] as List<Object?>?)?.cast<String>(),
      signInPayload: signInPayloadJson != null
          ? _signInPayloadFromJson(signInPayloadJson)
          : null,
    );
  }

  /// Human-readable name of the dApp (nullable).
  final String? identityName;

  /// URI of the dApp (nullable).
  final String? identityUri;

  /// Relative URI of the dApp icon (nullable).
  final String? iconRelativeUri;

  /// Chain the dApp wants to interact with (e.g. `solana:mainnet`).
  final String? chain;

  /// Optional features the dApp requests.
  final List<String>? features;

  /// Optional pre-existing addresses to reuse.
  final List<String>? addresses;

  /// Optional Sign In With Solana payload.
  final SignInPayload? signInPayload;

  /// Completes the request by authorizing the dApp.
  void completeWithAuthorize({
    required List<AuthorizedAccount> accounts,
    String? walletUriBase,
    String? authToken,
    SignInResult? signInResult,
  }) {
    _complete({
      'accounts': accounts.map((a) => a.toJson()).toList(),
      if (walletUriBase != null) 'wallet_uri_base': walletUriBase,
      if (authToken != null) 'auth_token': authToken,
      if (signInResult != null) 'sign_in_result': signInResult.toJson(),
    });
  }

  /// Completes the request by declining authorization.
  void completeWithDecline() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.authorizationFailed,
          message: 'Authorization declined',
        ),
      );
    }
  }

  /// Completes the request indicating the chain is not supported.
  void completeWithClusterNotSupported() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.authorizationFailed,
          message: 'Chain not supported',
        ),
      );
    }
  }
}

/// Account authorized by the wallet, returned to the dApp.
class AuthorizedAccount {
  const AuthorizedAccount({
    required this.address,
    this.displayAddress,
    this.displayAddressFormat,
    this.label,
    this.icon,
    this.chains,
    this.features,
  });

  /// Base64-encoded public key of the account.
  final String address;

  /// Human-readable address (e.g. base58 representation).
  final String? displayAddress;

  /// Format of [displayAddress] (e.g. `base58`).
  final String? displayAddressFormat;

  /// Human-readable label for the account.
  final String? label;

  /// Icon URI for the account (e.g. data: URI).
  final String? icon;

  /// Chains this account supports.
  final List<String>? chains;

  /// Features this account supports.
  final List<String>? features;

  /// Converts this account to a JSON-compatible map.
  Map<String, Object?> toJson() => {
        'address': address,
        if (displayAddress != null) 'display_address': displayAddress,
        if (displayAddressFormat != null)
          'display_address_format': displayAddressFormat,
        if (label != null) 'label': label,
        if (icon != null) 'icon': icon,
        if (chains != null) 'chains': chains,
        if (features != null) 'features': features,
      };
}

/// A dApp is requesting reauthorization.
class ReauthorizeDappRequest extends WalletRequest {
  ReauthorizeDappRequest({
    required super.requestId,
    required super.sessionId,
    required this.authorizationScope, this.identityName,
    this.identityUri,
    this.chain,
  });

  /// Human-readable name of the dApp.
  final String? identityName;

  /// URI of the dApp.
  final String? identityUri;

  /// Chain the dApp is interacting with.
  final String? chain;

  /// The authorization scope/token to revalidate.
  final String authorizationScope;

  /// Completes the request by approving reauthorization.
  void completeWithReauthorize({
    required List<AuthorizedAccount> accounts,
    String? authToken,
  }) {
    _complete({
      'accounts': accounts.map((a) => a.toJson()).toList(),
      if (authToken != null) 'auth_token': authToken,
    });
  }

  /// Completes the request by declining reauthorization.
  void completeWithDecline() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.authorizationFailed,
          message: 'Reauthorization declined',
        ),
      );
    }
  }
}

/// A dApp has deauthorized — an event, not a request.
class DeauthorizedEvent extends WalletRequest {
  DeauthorizedEvent({
    required super.requestId,
    required super.sessionId,
    required this.authorizationScope, this.identityName,
    this.identityUri,
    this.chain,
  });

  /// Human-readable name of the dApp.
  final String? identityName;

  /// URI of the dApp.
  final String? identityUri;

  /// Chain the dApp was interacting with.
  final String? chain;

  /// The authorization scope/token that was revoked.
  final String authorizationScope;

  /// Acknowledges the deauthorization event.
  void complete() {
    _complete({});
  }
}

/// A dApp is requesting transaction signing.
class SignTransactionsRequest extends WalletRequest {
  SignTransactionsRequest({
    required super.requestId,
    required super.sessionId,
    required this.payloads,
    this.chain,
    this.authorizationScope,
  });

  /// Creates a [SignTransactionsRequest] from a JSON-RPC params map.
  factory SignTransactionsRequest.fromParams({
    required String requestId,
    required String sessionId,
    required Map<String, Object?> params,
  }) {
    return SignTransactionsRequest(
      requestId: requestId,
      sessionId: sessionId,
      payloads: (params['payloads']! as List<Object?>).cast<String>(),
      chain: params['chain'] as String?,
      authorizationScope: params['auth_token'] as String?,
    );
  }

  /// Base64-encoded transaction payloads to sign.
  final List<String> payloads;

  /// Chain the dApp is interacting with.
  final String? chain;

  /// The dApp's authorization scope.
  final String? authorizationScope;

  /// Completes the request with signed payloads.
  void completeWithSignedPayloads(List<String> signedPayloads) {
    _complete({'signed_payloads': signedPayloads});
  }

  /// Completes the request by declining signing.
  void completeWithDecline() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.notSigned,
          message: 'User declined signing',
        ),
      );
    }
  }

  /// Completes the request indicating some payloads are invalid.
  void completeWithInvalidPayloads(List<bool> valid) {
    if (!_completer.isCompleted) {
      _completer.completeError(
        WalletRequestError(
          code: MwaProtocolErrorCode.invalidPayloads,
          message: 'Invalid payloads',
          data: {'valid': valid},
        ),
      );
    }
  }

  /// Completes the request indicating too many payloads.
  void completeWithTooManyPayloads() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.tooManyPayloads,
          message: 'Too many payloads',
        ),
      );
    }
  }

  /// Completes the request indicating the authorization is not valid.
  void completeWithAuthorizationNotValid() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.authorizationFailed,
          message: 'Authorization not valid',
        ),
      );
    }
  }
}

/// A dApp is requesting message signing.
class SignMessagesRequest extends WalletRequest {
  SignMessagesRequest({
    required super.requestId,
    required super.sessionId,
    required this.payloads,
    required this.addresses,
    this.chain,
    this.authorizationScope,
  });

  /// Creates a [SignMessagesRequest] from a JSON-RPC params map.
  factory SignMessagesRequest.fromParams({
    required String requestId,
    required String sessionId,
    required Map<String, Object?> params,
  }) {
    return SignMessagesRequest(
      requestId: requestId,
      sessionId: sessionId,
      payloads: (params['payloads']! as List<Object?>).cast<String>(),
      addresses: (params['addresses']! as List<Object?>).cast<String>(),
      chain: params['chain'] as String?,
      authorizationScope: params['auth_token'] as String?,
    );
  }

  /// Base64-encoded message payloads to sign.
  final List<String> payloads;

  /// Addresses that should sign each message.
  final List<String> addresses;

  /// Chain the dApp is interacting with.
  final String? chain;

  /// The dApp's authorization scope.
  final String? authorizationScope;

  /// Completes the request with signed payloads.
  void completeWithSignedPayloads(List<String> signedPayloads) {
    _complete({'signed_payloads': signedPayloads});
  }

  /// Completes the request by declining signing.
  void completeWithDecline() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.notSigned,
          message: 'User declined signing',
        ),
      );
    }
  }

  /// Completes the request indicating some payloads are invalid.
  void completeWithInvalidPayloads(List<bool> valid) {
    if (!_completer.isCompleted) {
      _completer.completeError(
        WalletRequestError(
          code: MwaProtocolErrorCode.invalidPayloads,
          message: 'Invalid payloads',
          data: {'valid': valid},
        ),
      );
    }
  }

  /// Completes the request indicating too many payloads.
  void completeWithTooManyPayloads() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.tooManyPayloads,
          message: 'Too many payloads',
        ),
      );
    }
  }
}

/// A dApp is requesting transaction signing and sending.
class SignAndSendTransactionsRequest extends WalletRequest {
  SignAndSendTransactionsRequest({
    required super.requestId,
    required super.sessionId,
    required this.payloads,
    this.chain,
    this.authorizationScope,
    this.minContextSlot,
    this.commitment,
    this.skipPreflight,
    this.maxRetries,
    this.waitForCommitmentToSendNextTransaction,
  });

  /// Creates a [SignAndSendTransactionsRequest] from a JSON-RPC params map.
  factory SignAndSendTransactionsRequest.fromParams({
    required String requestId,
    required String sessionId,
    required Map<String, Object?> params,
  }) {
    final options = params['options'] as Map<String, Object?>?;
    return SignAndSendTransactionsRequest(
      requestId: requestId,
      sessionId: sessionId,
      payloads: (params['payloads']! as List<Object?>).cast<String>(),
      chain: params['chain'] as String?,
      authorizationScope: params['auth_token'] as String?,
      minContextSlot: options?['min_context_slot'] as int?,
      commitment: options?['commitment'] as String?,
      skipPreflight: options?['skip_preflight'] as bool?,
      maxRetries: options?['max_retries'] as int?,
      waitForCommitmentToSendNextTransaction:
          options?['wait_for_commitment_to_send_next_transaction'] as bool?,
    );
  }

  /// Base64-encoded transaction payloads to sign and send.
  final List<String> payloads;

  /// Chain the dApp is interacting with.
  final String? chain;

  /// The dApp's authorization scope.
  final String? authorizationScope;

  /// Minimum context slot for the RPC node.
  final int? minContextSlot;

  /// Commitment level for transaction confirmation.
  final String? commitment;

  /// Whether to skip preflight checks.
  final bool? skipPreflight;

  /// Maximum number of retries for the RPC node.
  final int? maxRetries;

  /// Whether to wait for commitment before sending the next transaction.
  final bool? waitForCommitmentToSendNextTransaction;

  /// Completes the request with transaction signatures.
  void completeWithSignatures(List<String> signatures) {
    _complete({'signatures': signatures});
  }

  /// Completes the request by declining.
  void completeWithDecline() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.notSubmitted,
          message: 'User declined signing',
        ),
      );
    }
  }

  /// Completes the request indicating some signatures are invalid.
  void completeWithInvalidSignatures(List<bool> valid) {
    if (!_completer.isCompleted) {
      _completer.completeError(
        WalletRequestError(
          code: MwaProtocolErrorCode.invalidPayloads,
          message: 'Invalid signatures',
          data: {'valid': valid},
        ),
      );
    }
  }

  /// Completes the request indicating not all transactions were submitted.
  void completeWithNotSubmitted(List<String?> signatures) {
    if (!_completer.isCompleted) {
      _completer.completeError(
        WalletRequestError(
          code: MwaProtocolErrorCode.notSubmitted,
          message: 'Not all transactions submitted',
          data: {'signatures': signatures},
        ),
      );
    }
  }

  /// Completes the request indicating too many payloads.
  void completeWithTooManyPayloads() {
    if (!_completer.isCompleted) {
      _completer.completeError(
        const WalletRequestError(
          code: MwaProtocolErrorCode.tooManyPayloads,
          message: 'Too many payloads',
        ),
      );
    }
  }
}

/// Constructs a [SignInPayload] from a JSON map.
SignInPayload _signInPayloadFromJson(Map<String, Object?> json) {
  return SignInPayload(
    domain: json['domain'] as String?,
    address: json['address'] as String?,
    statement: json['statement'] as String?,
    uri: json['uri'] as String?,
    version: json['version'] as String?,
    chainId: json['chain_id'] as String?,
    nonce: json['nonce'] as String?,
    issuedAt: json['issued_at'] as String?,
    expirationTime: json['expiration_time'] as String?,
    notBefore: json['not_before'] as String?,
    requestId: json['request_id'] as String?,
    resources: (json['resources'] as List<Object?>?)?.cast<String>(),
  );
}
