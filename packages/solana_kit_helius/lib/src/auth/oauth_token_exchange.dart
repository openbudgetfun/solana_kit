import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Base URL for the Helius developer API.
const heliusDeveloperApiUrl = 'https://dev-api.helius.xyz/v0';

/// Request body for the Helius OAuth token exchange endpoint.
class OAuthTokenExchangeRequest {
  /// Creates an [OAuthTokenExchangeRequest] for the given authorization code.
  const OAuthTokenExchangeRequest({
    required this.code,
    required this.codeVerifier,
    required this.clientId,
    required this.redirectUri,
    this.userAgent,
  });

  /// Authorization code returned by the OAuth provider.
  final String code;

  /// PKCE code verifier used to exchange the authorization code.
  final String codeVerifier;

  /// OAuth client identifier.
  final String clientId;

  /// Redirect URI registered for the OAuth client.
  final String redirectUri;

  /// Optional User-Agent header sent with the token exchange request.
  final String? userAgent;
}

/// Response payload for the Helius OAuth token exchange endpoint.
class OAuthTokenResponse {
  /// Creates an [OAuthTokenResponse] with the issued token and user info.
  const OAuthTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  /// Creates an [OAuthTokenResponse] from a JSON map.
  factory OAuthTokenResponse.fromJson(Map<String, Object?> json) {
    return OAuthTokenResponse(
      accessToken: json['access_token']! as String,
      tokenType: json['token_type']! as String,
      expiresIn: json['expires_in']! as int,
      user: OAuthUser.fromJson(json['user']! as Map<String, Object?>),
    );
  }

  /// Access token issued by the OAuth provider.
  final String accessToken;

  /// Token type (e.g. `Bearer`).
  final String tokenType;

  /// Lifetime of the access token in seconds.
  final int expiresIn;

  /// Authenticated user information.
  final OAuthUser user;
}

/// Authenticated user information returned by the OAuth token exchange.
class OAuthUser {
  /// Creates an [OAuthUser] with the given [id] and [email].
  const OAuthUser({required this.id, required this.email});

  /// Creates an [OAuthUser] from a JSON map.
  factory OAuthUser.fromJson(Map<String, Object?> json) {
    return OAuthUser(
      id: json['id']! as String,
      email: json['email']! as String,
    );
  }

  /// Unique identifier for the user.
  final String id;

  /// Email address for the user.
  final String email;
}

/// Exchanges an OAuth authorization code for an access token.
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
