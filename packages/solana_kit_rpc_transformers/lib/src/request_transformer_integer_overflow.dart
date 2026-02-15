import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transformers/src/request_transformer_integer_overflow_internal.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// A callback function that is invoked when an integer overflow is detected
/// in request parameters.
///
/// The [request] is the original RPC request, [keyPath] indicates the
/// location of the overflowing value in the parameter tree, and [value]
/// is the [BigInt] value that exceeded the safe integer range.
typedef IntegerOverflowHandler =
    void Function(RpcRequest<Object?> request, KeyPath keyPath, BigInt value);

/// Creates a transformer that traverses the request parameters and executes
/// the provided handler when an integer overflow is detected.
///
/// An integer overflow occurs when a [BigInt] value exceeds
/// `Number.MAX_SAFE_INTEGER` (2^53 - 1) or is below its negative counterpart.
RpcRequestTransformer getIntegerOverflowRequestTransformer(
  IntegerOverflowHandler onIntegerOverflow,
) {
  return (RpcRequest<Object?> request) {
    final transformer = getTreeWalkerRequestTransformer([
      getIntegerOverflowNodeVisitor(
        (keyPath, value) => onIntegerOverflow(request, keyPath, value),
      ),
    ], const TraversalState(keyPath: []));
    return transformer(request);
  };
}
