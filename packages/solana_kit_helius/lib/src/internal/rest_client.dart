import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Internal REST caller for Helius REST API endpoints.
///
/// Supports GET, POST, PUT, and DELETE methods. Returns decoded JSON on
/// success, or throws a [SolanaError] with [SolanaErrorCode.heliusRestError]
/// on failure.
class RestClient {
  RestClient({required this.baseUrl, required http.Client client})
    : _client = client;

  final String baseUrl;
  final http.Client _client;

  static const _jsonHeaders = {
    'accept': 'application/json',
    'content-type': 'application/json; charset=utf-8',
  };

  /// Sends a GET request to [path] with optional [queryParameters].
  Future<Object?> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _client.get(
      uri,
      headers: {'accept': 'application/json'},
    );
    return _handleResponse(response);
  }

  /// Sends a POST request to [path] with an optional JSON [body].
  Future<Object?> post(String path, {Object? body}) async {
    final uri = _buildUri(path);
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Sends a PUT request to [path] with an optional JSON [body].
  Future<Object?> put(String path, {Object? body}) async {
    final uri = _buildUri(path);
    final response = await _client.put(
      uri,
      headers: _jsonHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Sends a DELETE request to [path].
  Future<Object?> delete(String path) async {
    final uri = _buildUri(path);
    final response = await _client.delete(
      uri,
      headers: {'accept': 'application/json'},
    );
    return _handleResponse(response);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: {...uri.queryParameters, ...queryParameters},
      );
    }
    return uri;
  }

  Object? _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SolanaError(SolanaErrorCode.heliusRestError, {
        'statusCode': response.statusCode,
        'message': response.body.isNotEmpty
            ? response.body
            : (response.reasonPhrase ?? 'Unknown error'),
      });
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}
