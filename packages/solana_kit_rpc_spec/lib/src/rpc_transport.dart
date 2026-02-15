/// Configuration for an RPC transport request.
class RpcTransportConfig {
  /// Creates a new [RpcTransportConfig].
  const RpcTransportConfig({required this.payload, this.signal});

  /// A value of arbitrary type to be sent to an RPC server.
  final Object? payload;

  /// An optional [Future] that, when completed, signals that the request
  /// should be cancelled.
  final Future<void>? signal;
}

/// A function that can act as a transport for an `Rpc`. It need only return
/// a [Future] for a response given the supplied config.
typedef RpcTransport = Future<Object?> Function(RpcTransportConfig config);

/// Returns `true` if the given [payload] is a JSON RPC v2 payload.
///
/// This means the payload is a [Map] such that:
///
/// - It has a `jsonrpc` key with a value of `'2.0'`.
/// - It has a `method` key that is a [String].
/// - It has a `params` key of any type.
///
/// ```dart
/// if (isJsonRpcPayload(payload)) {
///   final method = (payload as Map<String, Object?>)['method'] as String;
///   final params = (payload as Map<String, Object?>)['params'];
/// }
/// ```
bool isJsonRpcPayload(Object? payload) {
  if (payload == null || payload is! Map<String, Object?>) {
    return false;
  }

  return payload.containsKey('jsonrpc') &&
      payload['jsonrpc'] == '2.0' &&
      payload.containsKey('method') &&
      payload['method'] is String &&
      payload.containsKey('params');
}
