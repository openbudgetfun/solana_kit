import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transformers/src/response_transformer_bigint_upcast_internal.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// Returns a transformer that upcasts all integer values to [BigInt] unless
/// they match within the provided [KeyPath]s.
///
/// In other words, the provided [KeyPath]s will remain as [int] values; any
/// other numeric value will be upcasted to a [BigInt].
///
/// You can use [KEYPATH_WILDCARD] to match any key within a [KeyPath].
RpcResponseTransformer<Object?> getBigIntUpcastResponseTransformer(
  List<KeyPath> allowedNumericKeyPaths,
) {
  return getTreeWalkerResponseTransformer([
    getBigIntUpcastVisitor(allowedNumericKeyPaths),
  ], const TraversalState(keyPath: []));
}
