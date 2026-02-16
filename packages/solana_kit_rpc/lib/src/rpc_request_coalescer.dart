import 'dart:async';

import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// A function that produces a deduplication key for a given payload.
///
/// Returns `null` if the payload should not be deduplicated.
typedef GetDeduplicationKeyFn = String? Function(Object? payload);

/// Wraps the given [transport] with request coalescing logic.
///
/// When multiple identical requests (as determined by [getDeduplicationKey])
/// are made within the same microtask, only a single request is sent to the
/// underlying transport. All callers receive the same response.
///
/// The coalescing cache is cleared at the end of each microtask via
/// [scheduleMicrotask].
RpcTransport getRpcTransportWithRequestCoalescing(
  RpcTransport transport,
  GetDeduplicationKeyFn getDeduplicationKey,
) {
  Map<String, Future<Object?>>? coalescedRequestsByDeduplicationKey;

  return (RpcTransportConfig config) async {
    final deduplicationKey = getDeduplicationKey(config.payload);
    if (deduplicationKey == null) {
      return transport(config);
    }

    if (coalescedRequestsByDeduplicationKey == null) {
      coalescedRequestsByDeduplicationKey = {};
      scheduleMicrotask(() {
        coalescedRequestsByDeduplicationKey = null;
      });
    }

    final existingRequest =
        coalescedRequestsByDeduplicationKey![deduplicationKey];
    if (existingRequest != null) {
      return existingRequest;
    }

    final responsePromise = transport(config);
    coalescedRequestsByDeduplicationKey![deduplicationKey] = responsePromise;
    return responsePromise;
  };
}
