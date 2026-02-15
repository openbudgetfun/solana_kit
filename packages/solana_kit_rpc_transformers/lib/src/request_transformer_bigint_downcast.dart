import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transformers/src/request_transformer_bigint_downcast_internal.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// Creates a transformer that downcasts all [BigInt] values to [int].
///
/// This is necessary because JSON encoding does not support [BigInt] values
/// directly.
RpcRequestTransformer getBigIntDowncastRequestTransformer() {
  return getTreeWalkerRequestTransformer([
    downcastNodeToNumberIfBigint,
  ], const TraversalState(keyPath: []));
}
