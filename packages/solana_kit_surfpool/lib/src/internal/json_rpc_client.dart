import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_surfpool/src/errors.dart';

/// Internal JSON-RPC 2.0 client for Surfpool endpoints.
class SurfpoolJsonRpcClient {
  /// Creates a JSON-RPC client for [url].
  SurfpoolJsonRpcClient({required this.url, required this.client});

  /// HTTP JSON-RPC endpoint URL.
  final Uri url;

  /// HTTP client used for JSON-RPC requests.
  final http.Client client;

  int _nextId = 1;

  /// Calls a JSON-RPC [method] with optional [params].
  Future<Object?> call(String method, [Object? params]) async {
    final id = _nextId++;
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': ?params,
    });

    final response = await client.post(
      url,
      headers: const {
        'accept': 'application/json',
        'content-type': 'application/json; charset=utf-8',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw SurfpoolRpcException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}',
        method: method,
        statusCode: response.statusCode,
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      throw SurfpoolRpcException(
        'Invalid JSON-RPC response',
        method: method,
        cause: error,
      );
    }

    if (decoded is! Map<String, Object?>) {
      throw SurfpoolRpcException(
        'JSON-RPC response must be an object',
        method: method,
        cause: decoded,
      );
    }

    final error = decoded['error'];
    if (error != null) {
      final (message, code) = switch (error) {
        {'message': final Object? message, 'code': final int code} => (
          message?.toString() ?? 'Unknown RPC error',
          code,
        ),
        {'message': final Object? message} => (
          message?.toString() ?? 'Unknown RPC error',
          null,
        ),
        _ => ('Unknown RPC error', null),
      };
      throw SurfpoolRpcException(
        message,
        method: method,
        rpcCode: code,
        cause: error,
      );
    }

    return decoded['result'];
  }
}
