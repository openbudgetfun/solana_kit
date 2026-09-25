import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transformers/src/response_transformer_allowed_numeric_values.dart';
import 'package:solana_kit_rpc_transformers/src/response_transformer_bigint_upcast_internal.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// Keypaths for simulateTransaction result that should remain as int (not
/// BigInt). These are relative to the error.data root.
List<KeyPath> _getSimulateTransactionAllowedNumericKeypaths() {
  return [
    ['loadedAccountsDataSize'],
    ...jsonParsedAccountsConfigs.map(
      (c) => ['accounts', KEYPATH_WILDCARD, ...c],
    ),
    ...innerInstructionsConfigs.map(
      (c) => ['innerInstructions', KEYPATH_WILDCARD, ...c],
    ),
  ];
}

/// Returns a transformer that throws a [SolanaError] with the appropriate
/// RPC error code if the body of the RPC response contains an error.
///
/// For sendTransaction preflight failures (error code -32002), BigInt values
/// in `error.data` are transformed before the error is thrown.
RpcResponseTransformer<Object?> getThrowSolanaErrorResponseTransformer() {
  return (Object? json, RpcRequest<Object?> request) {
    if (json is Map<String, Object?> && json.containsKey('error')) {
      final error = json['error'];

      // Check if this is a sendTransaction preflight failure (error code
      // -32002). These errors contain RpcSimulateTransactionResult in
      // error.data which needs BigInt values downcast to int for fields
      // that should be numbers.
      if (error is Map<String, Object?> &&
          error.containsKey('code') &&
          (error['code'] == -32002 ||
              (error['code'] is BigInt &&
                  error['code'] == BigInt.from(-32002)))) {
        if (error.containsKey('data') && error['data'] != null) {
          // Apply BigInt upcast transformation to error.data.
          final treeWalker = getTreeWalkerResponseTransformer([
            getBigIntUpcastVisitor(
              _getSimulateTransactionAllowedNumericKeypaths(),
            ),
          ], const TraversalState(keyPath: []));
          final transformedData = treeWalker(error['data'], request);

          // Reconstruct error with transformed data.
          final transformedError = <String, Object?>{
            ...error,
            'data': transformedData,
          };
          throw getSolanaErrorFromJsonRpcError(transformedError);
        }
      }

      throw getSolanaErrorFromJsonRpcError(json['error']);
    }
    return json;
  };
}
