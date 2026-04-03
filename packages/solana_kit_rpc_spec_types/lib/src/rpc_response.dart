import 'package:solana_kit_rpc_spec_types/src/rpc_request.dart';

/// A function that accepts an RPC response and returns a transformed response.
///
/// This allows the RPC API to transform the response before it is returned to
/// the caller.
typedef RpcResponseTransformer<TResponse> =
    TResponse Function(Object? response, RpcRequest<Object?> request);

/// Represents the error payload of an RPC error response.
class RpcErrorResponsePayload {
  /// Creates a new [RpcErrorResponsePayload].
  const RpcErrorResponsePayload({
    required this.code,
    required this.message,
    this.data,
  });

  /// The error code.
  final int code;

  /// The error message.
  final String message;

  /// Optional additional data about the error.
  final Object? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RpcErrorResponsePayload &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, code, message, data);

  @override
  String toString() =>
      'RpcErrorResponsePayload(code: $code, message: $message, data: $data)';
}

/// Represents the data of an RPC response, which is either an error or a
/// result.
sealed class RpcResponseData<TResponse> {
  const RpcResponseData({required this.id});

  /// The unique identifier of this response.
  final String id;
}

/// An RPC response containing a successful result.
class RpcResponseResult<TResponse> extends RpcResponseData<TResponse> {
  /// Creates a new [RpcResponseResult].
  const RpcResponseResult({required super.id, required this.result});

  /// The result data.
  final TResponse result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RpcResponseResult<TResponse> &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          result == other.result;

  @override
  int get hashCode => Object.hash(runtimeType, id, result);

  @override
  String toString() => 'RpcResponseResult(id: $id, result: $result)';
}

/// An RPC response containing an error.
class RpcResponseError<TResponse> extends RpcResponseData<TResponse> {
  /// Creates a new [RpcResponseError].
  const RpcResponseError({required super.id, required this.error});

  /// The error payload.
  final RpcErrorResponsePayload error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RpcResponseError<TResponse> &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          error == other.error;

  @override
  int get hashCode => Object.hash(runtimeType, id, error);

  @override
  String toString() => 'RpcResponseError(id: $id, error: $error)';
}
