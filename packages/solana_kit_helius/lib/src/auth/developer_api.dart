// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/auth/oauth_token_exchange.dart';

final class DeveloperSignupResponse {
  const DeveloperSignupResponse({
    required this.token,
    required this.refId,
    required this.newUser,
  });

  factory DeveloperSignupResponse.fromJson(Map<String, Object?> json) {
    return DeveloperSignupResponse(
      token: _requireString(json, 'token'),
      refId: _requireString(json, 'refId'),
      newUser: _requireBool(json, 'newUser'),
    );
  }

  final String token;
  final String refId;
  final bool newUser;
}

final class DeveloperSubscription {
  const DeveloperSubscription({
    required this.plan,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
  });

  factory DeveloperSubscription.fromJson(Map<String, Object?> json) {
    return DeveloperSubscription(
      plan: _requireString(json, 'plan'),
      billingPeriodStart: _requireString(json, 'billingPeriodStart'),
      billingPeriodEnd: _requireString(json, 'billingPeriodEnd'),
    );
  }

  final String plan;
  final String billingPeriodStart;
  final String billingPeriodEnd;
}

final class DeveloperProjectSummary {
  const DeveloperProjectSummary({required this.id, required this.subscription});

  factory DeveloperProjectSummary.fromJson(Map<String, Object?> json) {
    return DeveloperProjectSummary(
      id: _requireString(json, 'id'),
      subscription: DeveloperSubscription.fromJson(
        _requireMap(json, 'subscription'),
      ),
    );
  }

  final String id;
  final DeveloperSubscription subscription;
}

final class DeveloperApiKey {
  const DeveloperApiKey({required this.keyId});

  factory DeveloperApiKey.fromJson(Map<String, Object?> json) {
    return DeveloperApiKey(keyId: _requireString(json, 'keyId'));
  }

  final String keyId;
}

final class DeveloperProjectDetails {
  const DeveloperProjectDetails({required this.apiKeys});

  factory DeveloperProjectDetails.fromJson(Map<String, Object?> json) {
    final rawApiKeys = json['apiKeys'];
    if (rawApiKeys is! List) {
      throw const FormatException('Expected apiKeys to be an array');
    }
    return DeveloperProjectDetails(
      apiKeys: rawApiKeys
          .map((value) => DeveloperApiKey.fromJson(_asMap(value)))
          .toList(growable: false),
    );
  }

  final List<DeveloperApiKey> apiKeys;
}

Future<DeveloperSignupResponse> developerWalletSignup({
  required String message,
  required String signature,
  required String walletAddress,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final result = await _developerApiRequest(
    const ['wallet-signup'],
    method: 'POST',
    body: <String, Object?>{
      'message': message,
      'signature': signature,
      'userID': walletAddress,
    },
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return DeveloperSignupResponse.fromJson(_asMap(result));
}

Future<List<DeveloperProjectSummary>> developerListProjects(
  String jwt, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final result = await _developerApiRequest(
    const ['projects'],
    jwt: jwt,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  if (result is! List) {
    throw const FormatException('Expected projects to be an array');
  }
  return result
      .map((value) => DeveloperProjectSummary.fromJson(_asMap(value)))
      .toList(growable: false);
}

Future<DeveloperProjectDetails> developerGetProject(
  String jwt,
  String projectId, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final result = await _developerApiRequest(
    ['projects', projectId],
    jwt: jwt,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return DeveloperProjectDetails.fromJson(_asMap(result));
}

Future<DeveloperApiKey> developerCreateApiKey(
  String jwt,
  String projectId,
  String walletAddress, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final result = await _developerApiRequest(
    ['projects', projectId, 'add-key'],
    jwt: jwt,
    method: 'POST',
    body: <String, Object?>{'userId': walletAddress},
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return DeveloperApiKey.fromJson(_asMap(result));
}

Future<Object?> _developerApiRequest(
  List<String> pathSegments, {
  String? jwt,
  String method = 'GET',
  Object? body,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final baseUri = Uri.parse(baseUrl);
  if (!baseUri.isAbsolute || baseUri.host.isEmpty) {
    throw ArgumentError.value(baseUrl, 'baseUrl', 'must be an absolute URL');
  }
  if (baseUri.scheme != 'https' && baseUri.scheme != 'http') {
    throw ArgumentError.value(
      baseUrl,
      'baseUrl',
      'must use the https or http scheme',
    );
  }
  final uri = baseUri.replace(
    pathSegments: [
      ...baseUri.pathSegments.where((segment) => segment.isNotEmpty),
      ...pathSegments,
    ],
  );
  final httpClient = client ?? http.Client();
  final closeClient = client == null;
  try {
    final userAgentHeader = userAgent == null
        ? null
        : <String, String>{'User-Agent': userAgent};
    final headers = <String, String>{
      'accept': 'application/json',
      if (body != null) 'content-type': 'application/json',
      if (jwt != null) 'Authorization': 'Bearer $jwt',
      ...?userAgentHeader,
    };
    final response = method == 'POST'
        ? await httpClient.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
        : await httpClient.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseMessage = response.body.length <= 4096
          ? response.body
          : '${response.body.substring(0, 4096)}…';
      throw createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {
          SolanaErrorContextKeys.operation: 'heliusDeveloperAuth',
          SolanaErrorContextKeys.statusCode: response.statusCode,
          'message': responseMessage,
        },
      );
    }
    return jsonDecode(response.body);
  } finally {
    if (closeClient) httpClient.close();
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is! Map) throw const FormatException('Expected a JSON object');
  return Map<String, Object?>.from(value);
}

Map<String, Object?> _requireMap(Map<String, Object?> json, String key) {
  return _asMap(json[key]);
}

String _requireString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Expected $key to be a non-empty string');
  }
  return value;
}

bool _requireBool(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! bool) throw FormatException('Expected $key to be a boolean');
  return value;
}
