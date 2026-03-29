/// HTTP transports for the Solana Kit Dart SDK.
///
/// Use this library when you want to execute Solana JSON-RPC calls over HTTP,
/// customize request headers, or enable additive features such as isolate-based
/// BigInt-aware JSON decoding.
///
/// <!-- {=docsIsolateJsonDecodeHttpSection} -->
///
/// ### Optional Isolate JSON Decoding
///
/// For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a
/// background isolate so the main isolate stays responsive.
///
/// ```dart
/// import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
///
/// void main() {
///   final transport = createHttpTransportForSolanaRpc(
///     url: 'https://api.mainnet-beta.solana.com',
///     decodeSolanaJsonInIsolate: true,
///     solanaJsonIsolateThreshold: 262144,
///   );
///
///   print(transport);
/// }
/// ```
///
/// For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
/// `runInIsolate: true`. Reserve isolate parsing for larger payloads where the
/// extra hop is worth the reduced UI or server-request blocking.
///
/// <!-- {/docsIsolateJsonDecodeHttpSection} -->
library;

export 'src/http_transport.dart';
export 'src/http_transport_config.dart';
export 'src/http_transport_for_solana_rpc.dart';
export 'src/http_transport_headers.dart';
export 'src/is_solana_request.dart';
