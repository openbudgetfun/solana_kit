/// Request for agentic signup with a wallet address.
class AgenticSignupRequest {
  const AgenticSignupRequest({required this.walletAddress});

  factory AgenticSignupRequest.fromJson(Map<String, Object?> json) {
    return AgenticSignupRequest(
      walletAddress: json['walletAddress']! as String,
    );
  }

  final String walletAddress;

  Map<String, Object?> toJson() => {'walletAddress': walletAddress};
}

/// Response from an agentic signup.
class AgenticSignupResponse {
  const AgenticSignupResponse({required this.apiKey, required this.projectId});

  factory AgenticSignupResponse.fromJson(Map<String, Object?> json) {
    return AgenticSignupResponse(
      apiKey: json['apiKey']! as String,
      projectId: json['projectId']! as String,
    );
  }

  final String apiKey;
  final String projectId;

  Map<String, Object?> toJson() => {'apiKey': apiKey, 'projectId': projectId};
}

/// Request for wallet signup with signature verification.
class WalletSignupRequest {
  const WalletSignupRequest({
    required this.walletAddress,
    required this.signature,
    required this.message,
  });

  factory WalletSignupRequest.fromJson(Map<String, Object?> json) {
    return WalletSignupRequest(
      walletAddress: json['walletAddress']! as String,
      signature: json['signature']! as String,
      message: json['message']! as String,
    );
  }

  final String walletAddress;
  final String signature;
  final String message;

  Map<String, Object?> toJson() => {
    'walletAddress': walletAddress,
    'signature': signature,
    'message': message,
  };
}

/// Response from a wallet signup.
class WalletSignupResponse {
  const WalletSignupResponse({required this.apiKey, required this.projectId});

  factory WalletSignupResponse.fromJson(Map<String, Object?> json) {
    return WalletSignupResponse(
      apiKey: json['apiKey']! as String,
      projectId: json['projectId']! as String,
    );
  }

  final String apiKey;
  final String projectId;

  Map<String, Object?> toJson() => {'apiKey': apiKey, 'projectId': projectId};
}

/// Request to create a new project.
class CreateProjectRequest {
  const CreateProjectRequest({required this.name});

  factory CreateProjectRequest.fromJson(Map<String, Object?> json) {
    return CreateProjectRequest(name: json['name']! as String);
  }

  final String name;

  Map<String, Object?> toJson() => {'name': name};
}

/// A Helius project.
class HeliusProject {
  const HeliusProject({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.createdAt,
  });

  factory HeliusProject.fromJson(Map<String, Object?> json) {
    return HeliusProject(
      id: json['id']! as String,
      name: json['name']! as String,
      apiKey: json['apiKey']! as String,
      createdAt: json['createdAt']! as int,
    );
  }

  final String id;
  final String name;
  final String apiKey;
  final int createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'apiKey': apiKey,
    'createdAt': createdAt,
  };
}

/// Request to create a new API key.
class CreateApiKeyRequest {
  const CreateApiKeyRequest({required this.projectId, required this.name});

  factory CreateApiKeyRequest.fromJson(Map<String, Object?> json) {
    return CreateApiKeyRequest(
      projectId: json['projectId']! as String,
      name: json['name']! as String,
    );
  }

  final String projectId;
  final String name;

  Map<String, Object?> toJson() => {'projectId': projectId, 'name': name};
}

/// A Helius API key.
class HeliusApiKey {
  const HeliusApiKey({
    required this.id,
    required this.key,
    required this.name,
    required this.createdAt,
  });

  factory HeliusApiKey.fromJson(Map<String, Object?> json) {
    return HeliusApiKey(
      id: json['id']! as String,
      key: json['key']! as String,
      name: json['name']! as String,
      createdAt: json['createdAt']! as int,
    );
  }

  final String id;
  final String key;
  final String name;
  final int createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'key': key,
    'name': name,
    'createdAt': createdAt,
  };
}

/// Response containing credit balance information.
class CheckBalancesResponse {
  const CheckBalancesResponse({
    required this.credits,
    required this.creditsUsed,
  });

  factory CheckBalancesResponse.fromJson(Map<String, Object?> json) {
    return CheckBalancesResponse(
      credits: json['credits']! as int,
      creditsUsed: json['creditsUsed']! as int,
    );
  }

  final int credits;
  final int creditsUsed;

  Map<String, Object?> toJson() => {
    'credits': credits,
    'creditsUsed': creditsUsed,
  };
}

/// A keypair result containing public and secret keys.
class KeypairResult {
  const KeypairResult({required this.publicKey, required this.secretKey});

  factory KeypairResult.fromJson(Map<String, Object?> json) {
    return KeypairResult(
      publicKey: json['publicKey']! as String,
      secretKey: json['secretKey']! as String,
    );
  }

  final String publicKey;
  final String secretKey;

  Map<String, Object?> toJson() => {
    'publicKey': publicKey,
    'secretKey': secretKey,
  };
}

/// Request to sign an auth message.
class SignAuthMessageRequest {
  const SignAuthMessageRequest({
    required this.message,
    required this.secretKey,
  });

  factory SignAuthMessageRequest.fromJson(Map<String, Object?> json) {
    return SignAuthMessageRequest(
      message: json['message']! as String,
      secretKey: json['secretKey']! as String,
    );
  }

  final String message;
  final String secretKey;

  Map<String, Object?> toJson() => {'message': message, 'secretKey': secretKey};
}

/// Response containing a signed auth message.
class SignAuthMessageResponse {
  const SignAuthMessageResponse({required this.signature});

  factory SignAuthMessageResponse.fromJson(Map<String, Object?> json) {
    return SignAuthMessageResponse(signature: json['signature']! as String);
  }

  final String signature;

  Map<String, Object?> toJson() => {'signature': signature};
}
