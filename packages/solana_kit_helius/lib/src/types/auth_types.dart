import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart' show KeyPair;

// ── Signup types (v3.0.0) ──────────────────────────────────────────────────

/// Request for unified signup (v3.0.0). Replaces the legacy agentic signup.
///
/// Either provide [secretKey] for SDK-authenticated signup, or provide
/// [jwt]/[refId]/[walletAddress] for pre-authenticated signup.
class SignupRequest {
  /// Creates a signup request with a secret key (SDK-authenticated).
  const SignupRequest.secretKey({
    required this.secretKey,
    required this.plan,
    this.period = 'monthly',
    this.email,
    this.firstName,
    this.lastName,
    this.couponCode,
    this.paymentHost,
  })  : jwt = null,
        refId = null,
        walletAddress = null;

  /// Creates a signup request from pre-existing authentication.
  const SignupRequest.preauthenticated({
    required this.jwt,
    required this.refId,
    required this.walletAddress,
    required this.plan,
    this.period = 'monthly',
    this.email,
    this.firstName,
    this.lastName,
    this.couponCode,
    this.paymentHost,
  }) : secretKey = null;

  /// Base64-encoded 64-byte Solana CLI-format secret key.
  final String? secretKey;

  /// Pre-existing JWT from wallet signup.
  final String? jwt;

  /// Pre-existing refId from wallet signup.
  final String? refId;

  /// Pre-existing wallet address.
  final String? walletAddress;

  /// Plan to subscribe to: 'agent', 'developer', 'business', or 'professional'.
  final String plan;

  /// Billing period. Ignored for agent plan. Defaults to 'monthly'.
  final String period;

  /// Contact email — required when creating a fresh payment intent.
  final String? email;

  /// First name — required when creating a fresh payment intent.
  final String? firstName;

  /// Last name — required when creating a fresh payment intent.
  final String? lastName;

  /// Optional coupon code.
  final String? couponCode;

  /// Override the payment host URL.
  final String? paymentHost;
}

/// RPC endpoint URLs for a provisioned project.
class SignupEndpoints {
  /// Creates endpoint URLs.
  const SignupEndpoints({required this.mainnet, required this.devnet});

  /// Mainnet RPC endpoint URL.
  final String mainnet;

  /// Devnet RPC endpoint URL.
  final String devnet;
}

/// Discriminated union result from the unified signup (v3.0.0).
sealed class SignupResult {
  const SignupResult._();
}

/// User is already subscribed to the requested plan.
class AlreadySubscribedResult extends SignupResult {
  /// Creates an already-subscribed result.
  const AlreadySubscribedResult({
    required this.jwt,
    required this.refId,
    required this.walletAddress,
    required this.projectId,
    required this.apiKey,
    required this.endpoints,
  }) : super._();

  /// Authentication token.
  final String jwt;

  /// Reference identifier.
  final String refId;

  /// Wallet address.
  final String walletAddress;

  /// Project identifier.
  final String projectId;

  /// API key for the project.
  final String apiKey;

  /// RPC endpoints for the project.
  final SignupEndpoints endpoints;
}

/// User has an existing project on a different plan — upgrade required.
class UpgradeRequiredResult extends SignupResult {
  /// Creates an upgrade-required result.
  const UpgradeRequiredResult({
    required this.jwt,
    required this.refId,
    required this.walletAddress,
    required this.currentPlan,
    required this.requestedPlan,
  }) : super._();

  /// Authentication token.
  final String jwt;

  /// Reference identifier.
  final String refId;

  /// Wallet address.
  final String walletAddress;

  /// Current subscription plan.
  final String currentPlan;

  /// Requested subscription plan.
  final String requestedPlan;
}

/// Payment is required to complete signup.
class PaymentRequiredResult extends SignupResult {
  /// Creates a payment-required result.
  const PaymentRequiredResult({
    required this.jwt,
    required this.refId,
    required this.walletAddress,
    required this.paymentLink,
  }) : super._();

  /// Authentication token.
  final String jwt;

  /// Reference identifier.
  final String refId;

  /// Wallet address.
  final String walletAddress;

  /// Hosted-checkout payment link.
  final PaymentLink paymentLink;
}

// ── PaymentLink type (shared between auth and checkout) ─────────────────────

/// Hosted-checkout link returned to the caller.
///
/// The user clicks [paymentUrl] in a browser, OR an agent sends
/// [amountCents] (× 10_000) USDC raw to [destinationWallet] with
/// [memo] = [paymentIntentId].
class PaymentLink {
  /// Creates a payment link.
  const PaymentLink({
    required this.kind,
    required this.paymentIntentId,
    required this.amountCents,
    required this.destinationWallet,
    required this.memo,
    required this.expiresAt,
    required this.paymentUrl,
    required this.solanaPayUrl,
    required this.planName,
  });

  /// Creates a [PaymentLink] from a JSON map.
  factory PaymentLink.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return PaymentLink(
      kind: r.requireString('kind'),
      paymentIntentId: r.requireString('paymentIntentId'),
      amountCents: r.requireInt('amountCents'),
      destinationWallet: r.requireString('destinationWallet'),
      memo: r.requireString('memo'),
      expiresAt: r.requireString('expiresAt'),
      paymentUrl: r.requireString('paymentUrl'),
      solanaPayUrl: r.requireString('solanaPayUrl'),
      planName: r.requireString('planName'),
    );
  }

  /// Always 'payment_required'.
  final String kind;

  /// Payment intent identifier (also used as memo).
  final String paymentIntentId;

  /// Amount in cents.
  final int amountCents;

  /// Merchant USDC wallet address.
  final String destinationWallet;

  /// Memo for the payment (always equals [paymentIntentId]).
  final String memo;

  /// Expiry timestamp.
  final String expiresAt;

  /// Public payment URL (e.g. `https://dashboard.helius.dev/pay/<id>`).
  final String paymentUrl;

  /// Raw `solana:` URI for wallet apps.
  final String solanaPayUrl;

  /// Display name resolved from plan/period.
  final String planName;

  /// Serializes this payment link to a JSON map.
  Map<String, Object?> toJson() => {
        'kind': kind,
        'paymentIntentId': paymentIntentId,
        'amountCents': amountCents,
        'destinationWallet': destinationWallet,
        'memo': memo,
        'expiresAt': expiresAt,
        'paymentUrl': paymentUrl,
        'solanaPayUrl': solanaPayUrl,
        'planName': planName,
      };
}

// ── Legacy wallet signup types ──────────────────────────────────────────────

/// Request for wallet signup with signature verification.
class WalletSignupRequest {
  /// Creates a wallet signup request.
  const WalletSignupRequest({
    required this.walletAddress,
    required this.signature,
    required this.message,
  });

  /// Creates a [WalletSignupRequest] from a JSON map.
  factory WalletSignupRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WalletSignupRequest(
      walletAddress: r.requireString('walletAddress'),
      signature: r.requireString('signature'),
      message: r.requireString('message'),
    );
  }

  /// Wallet address signing up.
  final String walletAddress;

  /// Signature of [message] by [walletAddress].
  final String signature;

  /// Message that was signed.
  final String message;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
        'walletAddress': walletAddress,
        'signature': signature,
        'message': message,
      };
}

/// Response from a wallet signup.
class WalletSignupResponse {
  /// Creates a wallet signup response.
  const WalletSignupResponse({required this.apiKey, required this.projectId});

  /// Creates a [WalletSignupResponse] from a JSON map.
  factory WalletSignupResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WalletSignupResponse(
      apiKey: r.requireString('apiKey'),
      projectId: r.requireString('projectId'),
    );
  }

  /// API key issued for the new project.
  final String apiKey;

  /// Identifier of the created project.
  final String projectId;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {'apiKey': apiKey, 'projectId': projectId};
}

// ── Project and API key types ───────────────────────────────────────────────

/// Request to create a new project.
class CreateProjectRequest {
  /// Creates a create-project request.
  const CreateProjectRequest({required this.name});

  /// Creates a [CreateProjectRequest] from a JSON map.
  factory CreateProjectRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateProjectRequest(name: r.requireString('name'));
  }

  /// Name of the project to create.
  final String name;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'name': name};
}

/// A Helius project.
class HeliusProject {
  /// Creates a Helius project.
  const HeliusProject({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.createdAt,
  });

  /// Creates a [HeliusProject] from a JSON map.
  factory HeliusProject.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return HeliusProject(
      id: r.requireString('id'),
      name: r.requireString('name'),
      apiKey: r.requireString('apiKey'),
      createdAt: r.requireInt('createdAt'),
    );
  }

  /// Unique identifier of the project.
  final String id;

  /// Display name of the project.
  final String name;

  /// API key associated with the project.
  final String apiKey;

  /// Creation timestamp of the project.
  final int createdAt;

  /// Serializes this project to a JSON map.
  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'apiKey': apiKey,
        'createdAt': createdAt,
      };
}

/// Request to create a new API key.
class CreateApiKeyRequest {
  /// Creates a create-API-key request.
  const CreateApiKeyRequest({required this.projectId, required this.name});

  /// Creates a [CreateApiKeyRequest] from a JSON map.
  factory CreateApiKeyRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateApiKeyRequest(
      projectId: r.requireString('projectId'),
      name: r.requireString('name'),
    );
  }

  /// Identifier of the project that owns the API key.
  final String projectId;

  /// Display name of the API key.
  final String name;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'projectId': projectId, 'name': name};
}

/// A Helius API key.
class HeliusApiKey {
  /// Creates a Helius API key.
  const HeliusApiKey({
    required this.id,
    required this.key,
    required this.name,
    required this.createdAt,
  });

  /// Creates a [HeliusApiKey] from a JSON map.
  factory HeliusApiKey.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return HeliusApiKey(
      id: r.requireString('id'),
      key: r.requireString('key'),
      name: r.requireString('name'),
      createdAt: r.requireInt('createdAt'),
    );
  }

  /// Unique identifier of the API key.
  final String id;

  /// The API key value.
  final String key;

  /// Display name of the API key.
  final String name;

  /// Creation timestamp of the API key.
  final int createdAt;

  /// Serializes this API key to a JSON map.
  Map<String, Object?> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'createdAt': createdAt,
      };
}

/// Response containing credit balance information.
class CheckBalancesResponse {
  /// Creates a check-balances response.
  const CheckBalancesResponse({
    required this.credits,
    required this.creditsUsed,
  });

  /// Creates a [CheckBalancesResponse] from a JSON map.
  factory CheckBalancesResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CheckBalancesResponse(
      credits: r.requireInt('credits'),
      creditsUsed: r.requireInt('creditsUsed'),
    );
  }

  /// Credits remaining for the project.
  final int credits;

  /// Credits used by the project.
  final int creditsUsed;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
        'credits': credits,
        'creditsUsed': creditsUsed,
      };
}

/// A keypair result containing public and secret keys.
class KeypairResult {
  /// Creates a keypair result.
  const KeypairResult({required this.publicKey, required this.secretKey});

  /// Creates a [KeypairResult] from a JSON map.
  factory KeypairResult.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return KeypairResult(
      publicKey: r.requireString('publicKey'),
      secretKey: r.requireString('secretKey'),
    );
  }

  /// Base58-encoded public key.
  final String publicKey;

  /// Base58-encoded secret key.
  final String secretKey;

  /// Serializes this keypair result to a JSON map.
  Map<String, Object?> toJson() => {
        'publicKey': publicKey,
        'secretKey': secretKey,
      };
}

/// Request to sign an auth message.
class SignAuthMessageRequest {
  /// Creates a sign-auth-message request.
  const SignAuthMessageRequest({
    required this.secretKey,
    this.message,
    this.timestamp,
  });

  /// Creates a [SignAuthMessageRequest] from a JSON map.
  factory SignAuthMessageRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SignAuthMessageRequest(
      message: r.optString('message'),
      secretKey: r.requireString('secretKey'),
      timestamp: r.optInt('timestamp'),
    );
  }

  /// Creates a request from Solana CLI-format secret key bytes.
  ///
  /// The bytes are base64-encoded into [secretKey], preserving the current JSON
  /// shape while avoiding base64 work at call sites.
  factory SignAuthMessageRequest.fromSecretKeyBytes(
    List<int> secretKeyBytes, {
    String? message,
    int? timestamp,
  }) {
    return SignAuthMessageRequest(
      message: message,
      secretKey: base64Encode(secretKeyBytes),
      timestamp: timestamp,
    );
  }

  /// Creates a request from a [KeyPair].
  ///
  /// The key pair is converted to Solana CLI-format secret key bytes by
  /// concatenating the 32-byte private key and 32-byte public key.
  factory SignAuthMessageRequest.fromKeyPair(
    KeyPair keyPair, {
    String? message,
    int? timestamp,
  }) {
    final secretKeyBytes = Uint8List(64)
      ..setRange(0, 32, keyPair.privateKey)
      ..setRange(32, 64, keyPair.publicKey);

    return SignAuthMessageRequest.fromSecretKeyBytes(
      secretKeyBytes,
      message: message,
      timestamp: timestamp,
    );
  }

  /// Message to sign.
  ///
  /// If omitted, the signer creates the upstream Helius auth message JSON with
  /// the configured or current timestamp.
  final String? message;

  /// Base64-encoded 64-byte Solana CLI-format secret key.
  final String secretKey;

  /// Millisecond timestamp used when generating the upstream Helius auth
  /// message. If omitted, the current time is used.
  final int? timestamp;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
        if (message != null) 'message': message,
        'secretKey': secretKey,
        if (timestamp != null) 'timestamp': timestamp,
      };
}

/// Response containing a signed auth message.
class SignAuthMessageResponse {
  /// Creates a sign-auth-message response.
  const SignAuthMessageResponse({required this.signature, this.message});

  /// Creates a [SignAuthMessageResponse] from a JSON map.
  factory SignAuthMessageResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SignAuthMessageResponse(
      signature: r.requireString('signature'),
      message: r.optString('message'),
    );
  }

  /// The message that was signed, when locally available.
  final String? message;

  /// Base58-encoded Ed25519 signature bytes.
  final String signature;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
        if (message != null) 'message': message,
        'signature': signature,
      };
}
