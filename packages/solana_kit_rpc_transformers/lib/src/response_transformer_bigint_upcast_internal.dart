import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// Creates a node visitor that upcasts integer values to [BigInt] unless the
/// current key path matches one of the [allowedNumericKeyPaths].
///
/// Values at allowed key paths remain as [int]. All other integer values are
/// converted to [BigInt].
NodeVisitor getBigIntUpcastVisitor(List<KeyPath> allowedNumericKeyPaths) {
  return (Object? value, TraversalState state) {
    final isInteger = (value is int) || (value is BigInt);
    if (!isInteger) return value;
    if (_keyPathIsAllowedToBeNumeric(state.keyPath, allowedNumericKeyPaths)) {
      if (value is BigInt) {
        return value.toInt();
      }
      return value;
    } else {
      if (value is int) {
        return BigInt.from(value);
      }
      return value;
    }
  };
}

bool _keyPathIsAllowedToBeNumeric(
  KeyPath keyPath,
  List<KeyPath> allowedNumericKeyPaths,
) {
  return allowedNumericKeyPaths.any((allowedKeyPath) {
    if (allowedKeyPath.length != keyPath.length) {
      return false;
    }
    for (var ii = keyPath.length - 1; ii >= 0; ii--) {
      final keyPathPart = keyPath[ii];
      final allowedKeyPathPart = allowedKeyPath[ii];
      if (allowedKeyPathPart != keyPathPart &&
          !(allowedKeyPathPart is KeyPathWildcard && keyPathPart is int)) {
        return false;
      }
    }
    return true;
  });
}
