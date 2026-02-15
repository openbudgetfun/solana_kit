import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

/// A sentinel type used to match any key at a given position in a [KeyPath].
class KeyPathWildcard {
  const KeyPathWildcard._();
}

/// A path of keys used to navigate nested data structures.
///
/// Each element can be a [String] (object key), [int] (array index),
/// or [KEYPATH_WILDCARD] to match any key at that position.
typedef KeyPath = List<Object>;

/// Sentinel value that matches any key at a given level of a key path.
// ignore: constant_identifier_names
const KeyPathWildcard KEYPATH_WILDCARD = KeyPathWildcard._();

/// A function that visits a node during tree traversal.
///
/// Takes the current [value] and the traversal [state], and returns a
/// (potentially transformed) value.
typedef NodeVisitor = Object? Function(Object? value, TraversalState state);

/// The state maintained during tree traversal.
class TraversalState {
  /// Creates a new [TraversalState] with the given [keyPath].
  const TraversalState({required this.keyPath});

  /// The current key path in the tree being traversed.
  final KeyPath keyPath;
}

Object? Function(Object? node, TraversalState state) _getTreeWalker(
  List<NodeVisitor> visitors,
) {
  Object? traverse(Object? node, TraversalState state) {
    if (node is List) {
      return [
        for (var ii = 0; ii < node.length; ii++)
          traverse(node[ii], TraversalState(keyPath: [...state.keyPath, ii])),
      ];
    } else if (node is Map<String, Object?>) {
      final out = <String, Object?>{};
      for (final entry in node.entries) {
        final nextState = TraversalState(
          keyPath: [...state.keyPath, entry.key],
        );
        out[entry.key] = traverse(entry.value, nextState);
      }
      return out;
    } else {
      var result = node;
      for (final visitor in visitors) {
        result = visitor(result, state);
      }
      return result;
    }
  }

  return traverse;
}

/// Creates a transformer that traverses the request parameters and executes
/// the provided visitors at each node.
///
/// A custom initial state can be provided but must at least provide
/// `TraversalState(keyPath: [])`.
RpcRequestTransformer getTreeWalkerRequestTransformer(
  List<NodeVisitor> visitors,
  TraversalState initialState,
) {
  return (RpcRequest<Object?> request) {
    final traverse = _getTreeWalker(visitors);
    return RpcRequest(
      methodName: request.methodName,
      params: traverse(request.params, initialState),
    );
  };
}

/// Creates a transformer that traverses a response and executes the provided
/// visitors at each node.
RpcResponseTransformer<Object?> getTreeWalkerResponseTransformer(
  List<NodeVisitor> visitors,
  TraversalState initialState,
) {
  return (Object? json, RpcRequest<Object?> request) =>
      _getTreeWalker(visitors)(json, initialState);
}
