import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc/src/rpc_request_coalescer.dart';
import 'package:solana_kit_rpc/src/rpc_request_deduplication.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

/// Creates a default [RpcTransport] for Solana RPC requests.
///
/// The default behaviours include:
/// - An automatically-set `solana-client` request header, containing the
///   version of the Dart SDK (cannot be overridden by user-supplied headers).
/// - Logic that coalesces multiple calls in the same microtask, for the same
///   methods with the same arguments, into a single network request.
///
/// Optionally pass an [http.Client] via [client] to control the HTTP client
/// used for requests (useful for testing).
RpcTransport createDefaultRpcTransport({
  required String url,
  Map<String, String>? headers,
  http.Client? client,
}) {
  final normalizedHeaders = headers != null ? _normalizeHeaders(headers) : null;
  final mergedHeaders = <String, String>{
    if (normalizedHeaders != null) ...normalizedHeaders,
    // Applied last so it cannot be overridden.
    'solana-client': 'dart/0.0.1',
  };

  final baseTransport = createHttpTransportForSolanaRpc(
    url: url,
    headers: mergedHeaders,
    client: client,
  );

  return getRpcTransportWithRequestCoalescing(
    baseTransport,
    getSolanaRpcPayloadDeduplicationKey,
  );
}

Map<String, String> _normalizeHeaders(Map<String, String> headers) {
  return {
    for (final entry in headers.entries) entry.key.toLowerCase(): entry.value,
  };
}
