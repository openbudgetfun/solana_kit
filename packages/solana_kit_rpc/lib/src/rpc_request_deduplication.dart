import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Returns a deduplication key for the given RPC [payload], or `null` if the
/// payload is not a valid JSON-RPC 2.0 payload.
///
/// Two materially identical JSON-RPC payloads (same method and params, but
/// possibly different `id` or key ordering) produce the same key. This
/// enables request coalescing for duplicate in-flight requests.
String? getSolanaRpcPayloadDeduplicationKey(Object? payload) {
  if (!isJsonRpcPayload(payload)) {
    return null;
  }
  final map = payload! as Map<String, Object?>;
  return fastStableStringify([map['method'], map['params']]);
}
