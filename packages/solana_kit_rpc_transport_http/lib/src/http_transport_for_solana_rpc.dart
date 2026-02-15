import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transport_http/src/http_transport.dart';
import 'package:solana_kit_rpc_transport_http/src/http_transport_config.dart';
import 'package:solana_kit_rpc_transport_http/src/is_solana_request.dart';

/// Creates an [RpcTransport] that uses JSON HTTP requests with BigInt-aware
/// JSON handling for Solana RPC requests.
///
/// Much like [createHttpTransport], this function creates a transport that
/// sends JSON-RPC requests over HTTP. However, it also uses custom `toJson`
/// and `fromJson` functions that allow `BigInt` values to be serialized and
/// deserialized correctly over the wire.
///
/// Since this is specific to the Solana RPC API, the custom JSON functions are
/// only used when the request is recognized as a Solana RPC request (via
/// [isSolanaRequest]). For non-Solana requests, standard `jsonEncode` and
/// `jsonDecode` are used instead.
///
/// ```dart
/// final transport = createHttpTransportForSolanaRpc(
///   url: 'https://api.mainnet-beta.solana.com',
/// );
/// ```
///
/// Optionally pass an [http.Client] via [client] to control the HTTP client
/// used for requests (useful for testing).
RpcTransport createHttpTransportForSolanaRpc({
  required String url,
  Map<String, String>? headers,
  http.Client? client,
}) {
  return createHttpTransport(
    HttpTransportConfig(
      url: url,
      headers: headers,
      fromJson: (String rawResponse, Object? payload) =>
          isSolanaRequest(payload)
          ? parseJsonWithBigInts(rawResponse)
          : jsonDecode(rawResponse),
      toJson: (Object? payload) => isSolanaRequest(payload)
          ? stringifyJsonWithBigInts(payload)
          : jsonEncode(payload),
    ),
    client: client,
  );
}
