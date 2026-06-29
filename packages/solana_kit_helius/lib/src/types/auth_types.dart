import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart' show KeyPair;

/// Request for agentic signup with a wallet address.
class AgenticSignupRequest {
  /// Creates an agentic signup request.
  const AgenticSignupRequest({required this.walletAddress});

  /// Creates an [AgenticSignupRequest] from a JSON map.
  factory AgenticSignupRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AgenticSignupRequest(
      walletAddress: r.requireString('walletAddress'),
    );
  }

  /// Wallet address signing up for the agentic plan.
  final String walletAddress;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'walletAddress': walletAddress};
}

/// Response from an agentic signup.
class AgenticSignupResponse {
  /// Creates an agentic signup response.
  const AgenticSignupResponse({required this.apiKey, required this.projectId});

  /// Creates an [AgenticSignupResponse] from a JSON map.
  factory AgenticSignupResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AgenticSignupResponse(
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
