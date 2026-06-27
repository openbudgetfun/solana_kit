import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';

const heliusDeveloperApiUrl = 'https://dev-api.helius.xyz/v0';

class OAuthTokenExchangeRequest {
  const OAuthTokenExchangeRequest({
    required this.code,
    required this.codeVerifier,
    required this.clientId,
    required this.redirectUri,
    this.userAgent,
  });

  final String code;
  final String codeVerifier;
  final String clientId;
  final String redirectUri;
  final String? userAgent;
}

class OAuthTokenResponse {
  const OAuthTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory OAuthTokenResponse.fromJson(Map<String, Object?> json) {
    return OAuthTokenResponse(
      accessToken: json['access_token']! as String,
      tokenType: json['token_type']! as String,
      expiresIn: json['expires_in']! as int,
      user: OAuthUser.fromJson(json['user']! as Map<String, Object?>),
    );
  }

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final OAuthUser user;
}

class OAuthUser {
  const OAuthUser({required this.id, required this.email});

  factory OAuthUser.fromJson(Map<String, Object?> json) {
    return OAuthUser(
      id: json['id']! as String,
      email: json['email']! as String,
    );
  }

  final String id;
  final String email;
}

Future<OAuthTokenResponse> oauthTokenExchange(
  OAuthTokenExchangeRequest request, {
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final httpClient = client ?? http.Client(); // coverage:ignore-line
  final closeClient = client == null; // coverage:ignore-line

  try {
    final body = Uri(
      queryParameters: <String, String>{
        'grant_type': 'authorization_code',
        'code': request.code,
        'code_verifier': request.codeVerifier,
        'client_id': request.clientId,
        'redirect_uri': request.redirectUri,
      },
    ).query;
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      if (request.userAgent != null) 'User-Agent': request.userAgent!,
    };
    final response = await httpClient.post(
      Uri.parse('$baseUrl/oauth/token'),
      headers: headers,
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {
          SolanaErrorContextKeys.operation: 'heliusOAuthTokenExchange',
          SolanaErrorContextKeys.statusCode: response.statusCode,
          'message': response.body,
        },
      );
    }

    return OAuthTokenResponse.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
  } finally {
    if (closeClient) httpClient.close(); // coverage:ignore-line
  }
}
