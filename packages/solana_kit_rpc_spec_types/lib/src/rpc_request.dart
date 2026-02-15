/// Describes the elements of an RPC or RPC Subscriptions request.
class RpcRequest<TParams> {
  /// Creates a new [RpcRequest] with the given [methodName] and [params].
  const RpcRequest({required this.methodName, required this.params});

  /// The name of the RPC method or subscription requested.
  final String methodName;

  /// The parameters to be passed to the RPC server.
  final TParams params;
}

/// A function that accepts an [RpcRequest] and returns another [RpcRequest].
///
/// This allows the RPC API to transform the request before it is sent to the
/// RPC server.
typedef RpcRequestTransformer =
    RpcRequest<Object?> Function(RpcRequest<Object?> request);
