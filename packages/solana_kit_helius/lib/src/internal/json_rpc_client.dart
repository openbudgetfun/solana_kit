import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Internal JSON-RPC 2.0 caller for Helius RPC endpoints.
///
/// Sends `POST` requests with a JSON-RPC 2.0 envelope and returns the
/// `result` field on success, or throws a [SolanaError] on failure.
class JsonRpcClient {
  JsonRpcClient({required this.url, required http.Client client})
    : _client = client;

  final String url;
  final http.Client _client;
  int _nextId = 1;

  /// Calls a JSON-RPC method with the given [params].
  ///
  /// Returns the `result` field of the response, or throws a [SolanaError]
  /// with [SolanaErrorCode.heliusRpcError] if the response contains an error.
  Future<Object?> call(String method, [Object? params]) async {
    final id = _nextId++;
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      if (params != null) 'params': params,
    });

    final response = await _client.post(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json; charset=utf-8',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw SolanaError(SolanaErrorCode.heliusRpcError, {
        'message':
            'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}',
      });
    }

    final json = jsonDecode(response.body) as Map<String, Object?>;

    if (json.containsKey('error')) {
      final error = json['error']! as Map<String, Object?>;
      throw SolanaError(SolanaErrorCode.heliusRpcError, {
        'message': error['message'] ?? 'Unknown RPC error',
      });
    }

    return json['result'];
  }
}
