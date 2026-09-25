import 'package:solana_kit_rpc_spec_types/src/rpc_request.dart';

int _nextMessageId = 0;

String _getNextMessageId() {
  final id = _nextMessageId;
  _nextMessageId++;
  return id.toString();
}

/// Returns a spec-compliant JSON RPC 2.0 message, given an [RpcRequest].
///
/// Generates a new `id` on each call by incrementing an integer and casting it
/// to a string.
Map<String, Object?> createRpcMessage<TParams>(RpcRequest<TParams> request) {
  return Map<String, Object?>.unmodifiable({
    'id': _getNextMessageId(),
    'jsonrpc': '2.0',
    'method': request.methodName,
    'params': request.params,
  });
}
