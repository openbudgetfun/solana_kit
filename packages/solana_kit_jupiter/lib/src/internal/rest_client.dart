import 'dart:convert';

import 'package:http/http.dart';

/// Error thrown when a Jupiter API call fails.
///
/// Carries the HTTP status code and the best-effort error message extracted
/// from the response body so callers can surface actionable failures.
class JupiterException implements Exception {
  /// Creates a Jupiter API exception.
  JupiterException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  /// The failing HTTP status code.
  final int statusCode;

  /// The best-effort error message from the response body or status line.
  final String message;

  /// The raw decoded JSON body of the failed response, if it was JSON.
  final Object? body;

  @override
  String toString() =>
      'JupiterException(statusCode: $statusCode, message: $message)';
}

/// Internal REST caller for Jupiter Exchange API endpoints.
///
/// Sends JSON requests with the configured `x-api-key` header and returns
/// the decoded JSON body on success. Non-2xx responses throw a
/// [JupiterException].
class JupiterRestClient {
  /// Creates a REST caller backed by the given [_client] configuration.
  JupiterRestClient({
    required String baseUrl,
    required this._client,
    this._apiKey,
  }) : _baseUri = Uri.parse(baseUrl);

  final Uri _baseUri;
  final String? _apiKey;
  final Client _client;

  /// Sends a GET request to [path] with optional [queryParameters].
  Future<Object?> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    var uri = _baseUri.resolve(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    final request = Request('GET', uri)
      ..headers.addAll(_headers())
      ..followRedirects = false;
    final response = await Response.fromStream(await _client.send(request));
    return _handleResponse(response);
  }

  /// Sends a POST request to [path] with a JSON [body].
  Future<Object?> post(String path, {Object? body}) async {
    final uri = _baseUri.resolve(path);
    final request = Request('POST', uri)
      ..headers.addAll(_headers())
      ..headers['content-type'] = 'application/json; charset=utf-8'
      ..followRedirects = false;
    if (body != null) request.body = jsonEncode(body);
    final response = await Response.fromStream(await _client.send(request));
    return _handleResponse(response);
  }

  Map<String, String> _headers() {
    final headers = <String, String>{'accept': 'application/json'};
    final apiKey = _apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['x-api-key'] = apiKey;
    }
    return headers;
  }

  Object? _handleResponse(Response response) {
    final status = response.statusCode;
    final body = decodeJsonObject(response.body);
    if (status < 200 || status >= 300) {
      throw JupiterException(
        statusCode: status,
        message: _errorMessage(status, response.body),
        body: body,
      );
    }
    return body;
  }
}

/// Decodes a JSON response body when it is an object or array; returns the
/// raw string otherwise.
Object? decodeJsonObject(String body) {
  if (body.isEmpty) return null;
  try {
    return jsonDecode(body);
  } on FormatException {
    return body;
  }
}

String _errorMessage(int status, String body) {
  if (body.isEmpty) return 'HTTP $status';
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final error = decoded['error'] ?? decoded['detail'] ?? decoded['message'];
      if (error != null) return '$status: $error';
    }
  } on FormatException {
    // fall through to the status-only message
  }
  return 'HTTP $status';
}
