import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

/// Returns a transformer that extracts the `result` field from the body of
/// the RPC response.
///
/// For instance, `{'jsonrpc': '2.0', 'result': 'foo', 'id': 1}` becomes
/// `'foo'`.
RpcResponseTransformer<Object?> getResultResponseTransformer() {
  return (Object? json, RpcRequest<Object?> request) {
    if (json is Map<String, Object?>) {
      return json['result'];
    }
    return json;
  };
}
