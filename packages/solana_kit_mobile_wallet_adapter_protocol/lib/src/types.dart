import 'dart:typed_data';

/// MWA protocol version.
enum ProtocolVersion {
  /// Version 1 of the MWA protocol (chain-based, with features).
  v1,

  /// Legacy MWA protocol (cluster-based, with boolean capability flags).
  legacy,
}

/// Properties of an MWA session, negotiated during the handshake.
class SessionProperties {
  const SessionProperties({required this.protocolVersion});

  /// The protocol version negotiated for this session.
  final ProtocolVersion protocolVersion;
}

/// Application identity information sent to the wallet during authorization.
class AppIdentity {
  const AppIdentity({this.uri, this.icon, this.name});

  /// The application's URI.
  final Uri? uri;

  /// A relative path to the application's icon from [uri].
  final String? icon;

  /// The application's display name.
  final String? name;

  Map<String, Object?> toJson() => {
    if (uri != null) 'uri': uri.toString(),
    if (icon != null) 'icon': icon,
    if (name != null) 'name': name,
  };
}

/// A wallet account returned during authorization.
class MwaAccount {
  const MwaAccount({
    required this.address,
    this.displayAddress,
    this.label,
    this.icon,
    this.chains,
    this.features,
  });

  factory MwaAccount.fromJson(Map<String, Object?> json) {
    return MwaAccount(
      address: json['address']! as String,
      displayAddress: json['display_address'] as String?,
      label: json['label'] as String?,
      icon: json['icon'] as String?,
      chains: (json['chains'] as List<Object?>?)?.cast<String>(),
      features: (json['features'] as List<Object?>?)?.cast<String>(),
    );
  }

  /// The account's address, base64-encoded.
  final String address;

  /// Human-readable display address (e.g. base58 for Solana).
  final String? displayAddress;

  /// An optional display label for the account.
  final String? label;

  /// An optional icon URI for the account.
  final String? icon;

  /// Chain identifiers this account supports (e.g. `solana:mainnet`).
  final List<String>? chains;

  /// Feature identifiers this account supports.
  final List<String>? features;

  Map<String, Object?> toJson() => {
    'address': address,
    if (displayAddress != null) 'display_address': displayAddress,
    if (label != null) 'label': label,
    if (icon != null) 'icon': icon,
    if (chains != null) 'chains': chains,
    if (features != null) 'features': features,
  };
}

/// Result of a Sign In With Solana (SIWS) operation.
class SignInResult {
  const SignInResult({
    required this.address,
    required this.signedMessage,
    required this.signature,
    this.signatureType,
  });

  factory SignInResult.fromJson(Map<String, Object?> json) {
    return SignInResult(
      address: json['address']! as String,
      signedMessage: json['signed_message']! as String,
      signature: json['signature']! as String,
      signatureType: json['signature_type'] as String?,
    );
  }

  /// The signer's base64-encoded address.
  final String address;

  /// The signed SIWS message bytes, base64-encoded.
  final String signedMessage;

  /// The signature bytes, base64-encoded.
  final String signature;

  /// The signature type (e.g. `ed25519`).
  final String? signatureType;

  Map<String, Object?> toJson() => {
    'address': address,
    'signed_message': signedMessage,
    'signature': signature,
    if (signatureType != null) 'signature_type': signatureType,
  };
}

/// The full authorization result returned by the wallet.
class AuthorizationResult {
  const AuthorizationResult({
    required this.accounts,
    required this.authToken,
    this.walletUriBase,
    this.signInResult,
  });

  factory AuthorizationResult.fromJson(Map<String, Object?> json) {
    return AuthorizationResult(
      accounts: (json['accounts']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(MwaAccount.fromJson)
          .toList(),
      authToken: json['auth_token']! as String,
      walletUriBase: json['wallet_uri_base'] as String?,
      signInResult: json['sign_in_result'] != null
          ? SignInResult.fromJson(
              json['sign_in_result']! as Map<String, Object?>,
            )
          : null,
    );
  }

  /// The authorized accounts.
  final List<MwaAccount> accounts;

  /// An opaque authorization token for reauthorization.
  final String authToken;

  /// The wallet's base URI for subsequent connections.
  final String? walletUriBase;

  /// The result of a SIWS operation, if requested.
  final SignInResult? signInResult;
}

/// Payload for a Sign In With Solana request.
class SignInPayload {
  const SignInPayload({
    this.domain,
    this.address,
    this.statement,
    this.uri,
    this.version,
    this.chainId,
    this.nonce,
    this.issuedAt,
    this.expirationTime,
    this.notBefore,
    this.requestId,
    this.resources,
  });

  /// The domain requesting the sign-in.
  final String? domain;

  /// The account address to sign in with.
  final String? address;

  /// A human-readable statement for the user.
  final String? statement;

  /// The URI of the requesting party.
  final String? uri;

  /// The SIWS message version.
  final String? version;

  /// The chain ID (e.g. `mainnet`).
  final String? chainId;

  /// A random nonce to prevent replay attacks.
  final String? nonce;

  /// The time the message was issued (ISO 8601).
  final String? issuedAt;

  /// The expiration time of the message (ISO 8601).
  final String? expirationTime;

  /// The earliest time the message is valid (ISO 8601).
  final String? notBefore;

  /// An application-specific request identifier.
  final String? requestId;

  /// A list of URIs the user is authorizing access to.
  final List<String>? resources;

  Map<String, Object?> toJson() => {
    if (domain != null) 'domain': domain,
    if (address != null) 'address': address,
    if (statement != null) 'statement': statement,
    if (uri != null) 'uri': uri,
    if (version != null) 'version': version,
    if (chainId != null) 'chain_id': chainId,
    if (nonce != null) 'nonce': nonce,
    if (issuedAt != null) 'issued_at': issuedAt,
    if (expirationTime != null) 'expiration_time': expirationTime,
    if (notBefore != null) 'not_before': notBefore,
    if (requestId != null) 'request_id': requestId,
    if (resources != null) 'resources': resources,
  };
}

/// Wallet capabilities returned by `getCapabilities`.
class WalletCapabilities {
  const WalletCapabilities({
    this.maxTransactionsPerRequest,
    this.maxMessagesPerRequest,
    this.supportedTransactionVersions,
    this.features,
  });

  factory WalletCapabilities.fromJson(Map<String, Object?> json) {
    return WalletCapabilities(
      maxTransactionsPerRequest:
          json['max_transactions_per_request'] as int?,
      maxMessagesPerRequest: json['max_messages_per_request'] as int?,
      supportedTransactionVersions:
          json['supported_transaction_versions'] as List<Object?>?,
      features: (json['features'] as List<Object?>?)?.cast<String>(),
    );
  }

  /// Maximum number of transactions per signing request.
  final int? maxTransactionsPerRequest;

  /// Maximum number of messages per signing request.
  final int? maxMessagesPerRequest;

  /// Transaction versions supported by the wallet.
  final List<Object?>? supportedTransactionVersions;

  /// Feature identifiers supported by the wallet.
  final List<String>? features;
}

/// Options for the `signAndSendTransactions` method.
class SignAndSendOptions {
  const SignAndSendOptions({
    this.minContextSlot,
    this.commitment,
    this.skipPreflight,
    this.maxRetries,
    this.waitForCommitmentToSendNextTransaction,
  });

  /// Minimum slot that the request can be evaluated at.
  final int? minContextSlot;

  /// The commitment level for confirmation.
  final String? commitment;

  /// Whether to skip preflight transaction checks.
  final bool? skipPreflight;

  /// Maximum number of times for the RPC node to retry sending.
  final int? maxRetries;

  /// Whether to wait for commitment before sending the next transaction.
  final bool? waitForCommitmentToSendNextTransaction;

  Map<String, Object?> toJson() => {
    if (minContextSlot != null) 'min_context_slot': minContextSlot,
    if (commitment != null) 'commitment': commitment,
    if (skipPreflight != null) 'skip_preflight': skipPreflight,
    if (maxRetries != null) 'max_retries': maxRetries,
    if (waitForCommitmentToSendNextTransaction != null)
      'wait_for_commitment_to_send_next_transaction':
          waitForCommitmentToSendNextTransaction,
  };
}

/// Configuration for a local wallet association session.
class WalletAssociationConfig {
  const WalletAssociationConfig({this.baseUri});

  /// An optional base URI for the wallet Intent.
  final String? baseUri;
}

/// Configuration for a remote wallet association session.
class RemoteWalletAssociationConfig {
  const RemoteWalletAssociationConfig({
    required this.reflectorHost,
    this.baseUri,
  });

  /// The reflector server host authority.
  final String reflectorHost;

  /// An optional base URI for the wallet Intent.
  final String? baseUri;
}

/// Parsed association URI parameters.
sealed class AssociationParams {
  const AssociationParams({
    required this.associationPublicKey,
    required this.protocol,
  });

  /// The association public key bytes.
  final Uint8List associationPublicKey;

  /// The protocol version requested.
  final String protocol;
}

/// Parameters for a local association.
class LocalAssociationParams extends AssociationParams {
  const LocalAssociationParams({
    required super.associationPublicKey,
    required super.protocol,
    required this.port,
  });

  /// The port to connect to on localhost.
  final int port;
}

/// Parameters for a remote association via reflector.
class RemoteAssociationParams extends AssociationParams {
  const RemoteAssociationParams({
    required super.associationPublicKey,
    required super.protocol,
    required this.reflectorHost,
    required this.reflectorId,
  });

  /// The reflector server host.
  final String reflectorHost;

  /// The reflector connection ID.
  final int reflectorId;
}
