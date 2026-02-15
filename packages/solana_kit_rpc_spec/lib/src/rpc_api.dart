import 'package:solana_kit_rpc_spec/src/rpc_transport.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

/// Configuration for creating a JSON RPC API via [createJsonRpcApi].
class RpcApiConfig {
  /// Creates a new [RpcApiConfig].
  const RpcApiConfig({this.requestTransformer, this.responseTransformer});

  /// An optional function that transforms the [RpcRequest] before it is sent
  /// to the JSON RPC server.
  ///
  /// This is useful when the params supplied by the caller need to be
  /// transformed before forwarding the message to the server. Use cases for
  /// this include applying defaults, forwarding calls to renamed methods, and
  /// serializing complex values.
  final RpcRequestTransformer? requestTransformer;

  /// An optional function that transforms the response before it is returned
  /// to the caller.
  ///
  /// Use cases for this include constructing complex data types from
  /// serialized data, and throwing exceptions.
  final RpcResponseTransformer<Object?>? responseTransformer;
}

/// Configuration passed to the `RpcPlan.execute` function.
class RpcPlanExecuteConfig {
  /// Creates a new [RpcPlanExecuteConfig].
  const RpcPlanExecuteConfig({required this.transport, this.signal});

  /// The transport used to send the RPC request.
  final RpcTransport transport;

  /// An optional [Future] that, when completed, signals that the request
  /// should be cancelled.
  final Future<void>? signal;
}

/// Describes how a particular RPC request should be issued to the JSON RPC
/// server.
///
/// Given a function that was called on an `Rpc`, this object exposes an
/// `execute` function that dictates which request will be sent, how the
/// underlying transport will be used, and how the responses will be
/// transformed.
class RpcPlan<TResponse> {
  /// Creates a new [RpcPlan].
  const RpcPlan({required this.execute});

  /// Executes the RPC plan using the provided [RpcPlanExecuteConfig].
  final Future<TResponse> Function(RpcPlanExecuteConfig config) execute;
}

/// A function that takes a method name and parameters and returns an
/// [RpcPlan].
///
/// This is the Dart equivalent of the TypeScript `RpcApi` proxy. Since Dart
/// does not have JavaScript-style proxies, methods are called through this
/// functional interface.
typedef RpcApiMethod =
    RpcPlan<Object?> Function(String methodName, List<Object?> params);

/// A JSON RPC API that converts method calls into [RpcPlan] instances.
///
/// Since Dart doesn't support JavaScript-style Proxy objects, this class
/// provides a [call] method that takes a method name and parameters and
/// returns an [RpcPlan] describing how to execute the request.
///
/// The [RpcPlan] will:
/// - Create a JSON-RPC 2.0 payload from the method name and params,
///   optionally transformed by [RpcApiConfig.requestTransformer].
/// - Transform the transport's response using
///   [RpcApiConfig.responseTransformer], if provided.
///
/// ```dart
/// // For example, given this JsonRpcApi:
/// final api = createJsonRpcApi(
///   config: RpcApiConfig(
///     requestTransformer: (request) => RpcRequest(
///       methodName: '${request.methodName}Transformed',
///       params: request.params,
///     ),
///     responseTransformer: (response, request) =>
///         (response as int) * 2,
///   ),
/// );
///
/// // ...the following call:
/// final plan = api.call('foo', ['bar', {'baz': 'bat'}]);
///
/// // ...will produce an RpcPlan that:
/// // - Uses the method name 'fooTransformed'.
/// // - Doubles the response from the transport.
/// ```
class JsonRpcApi {
  /// Creates a new [JsonRpcApi] with an optional [config].
  const JsonRpcApi({this.config});

  /// The configuration for this API.
  final RpcApiConfig? config;

  /// Creates an [RpcPlan] for the given [methodName] and [params].
  RpcPlan<Object?> call(String methodName, List<Object?> params) {
    final rawRequest = RpcRequest<Object?>(
      methodName: methodName,
      params: List<Object?>.unmodifiable(params),
    );
    final request = config?.requestTransformer != null
        ? config!.requestTransformer!(rawRequest)
        : rawRequest;

    final apiConfig = config;
    return RpcPlan<Object?>(
      execute: (executeConfig) async {
        final payload = createRpcMessage(request);
        final response = await executeConfig.transport(
          RpcTransportConfig(payload: payload, signal: executeConfig.signal),
        );
        if (apiConfig?.responseTransformer == null) {
          return response;
        }
        return apiConfig!.responseTransformer!(response, request);
      },
    );
  }
}

/// Creates a [JsonRpcApi] that converts method calls into [RpcPlan] instances
/// with JSON-RPC 2.0 payloads.
///
/// The created API will:
/// - Set the transport payload to a JSON RPC v2 payload object with the
///   requested method name and params properties, optionally transformed by
///   [RpcApiConfig.requestTransformer].
/// - Transform the transport's response using
///   [RpcApiConfig.responseTransformer], if provided.
JsonRpcApi createJsonRpcApi({RpcApiConfig? config}) {
  return JsonRpcApi(config: config);
}
