import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

import 'package:solana_kit_rpc_transport_http/src/http_transport_config.dart';
import 'package:solana_kit_rpc_transport_http/src/http_transport_headers.dart';

/// Creates a function you can use to make `POST` requests with headers suitable
/// for sending JSON data to a server.
///
/// The returned [RpcTransport] sends the payload as a JSON-encoded body and
/// expects a JSON response.
///
/// ```dart
/// final transport = createHttpTransport(
///   HttpTransportConfig(url: 'https://api.mainnet-beta.solana.com'),
/// );
/// final response = await transport(
///   RpcTransportConfig(
///     payload: {'id': 1, 'jsonrpc': '2.0', 'method': 'getSlot'},
///   ),
/// );
/// ```
///
/// Optionally pass an [http.Client] via [client] to control the HTTP client
/// used for requests (useful for testing with a mock client).
RpcTransport createHttpTransport(
  HttpTransportConfig config, {
  http.Client? client,
}) {
  final HttpTransportConfig(:fromJson, :headers, :toJson, :url) = config;

  // Validate headers in debug mode only.
  assert(() {
    if (headers != null) {
      assertIsAllowedHttpRequestHeaders(headers);
    }
    return true;
  }(), 'Header validation failed');

  final customHeaders = headers != null ? normalizeHeaders(headers) : null;
  final effectiveClient = client ?? http.Client();

  return (RpcTransportConfig transportConfig) async {
    final payload = transportConfig.payload;
    final body = toJson != null ? toJson(payload) : jsonEncode(payload);
    final bodyBytes = utf8.encode(body);

    final mergedHeaders = <String, String>{
      if (customHeaders != null) ...customHeaders,
      // Protocol headers are applied last so they cannot be overridden.
      'accept': 'application/json',
      'content-length': bodyBytes.length.toString(),
      'content-type': 'application/json; charset=utf-8',
    };

    final response = await effectiveClient.post(
      Uri.parse(url),
      headers: mergedHeaders,
      body: body,
    );

    if (response.statusCode != 200) {
      throw SolanaError(SolanaErrorCode.rpcTransportHttpError, {
        'statusCode': response.statusCode,
        'message': response.reasonPhrase ?? 'Unknown error',
      });
    }

    if (fromJson != null) {
      return fromJson(response.body, payload);
    }

    return jsonDecode(response.body);
  };
}
