import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// JavaScript's `Number.MAX_SAFE_INTEGER` equivalent.
///
/// In the TS SDK, this is `2^53 - 1`, which is the largest integer that can be
/// represented exactly as a JavaScript `Number`.
const int _maxSafeInteger = 9007199254740991; // 2^53 - 1

/// Creates a node visitor that calls [onIntegerOverflow] when a [BigInt] value
/// exceeds the safe integer range (`-2^53 + 1` to `2^53 - 1`).
NodeVisitor getIntegerOverflowNodeVisitor(
  void Function(KeyPath keyPath, BigInt value) onIntegerOverflow,
) {
  return (Object? value, TraversalState state) {
    if (value is BigInt) {
      if (value > BigInt.from(_maxSafeInteger) ||
          value < BigInt.from(-_maxSafeInteger)) {
        onIntegerOverflow(state.keyPath, value);
      }
    }
    return value;
  };
}
