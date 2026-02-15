import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/src/rpc_api.dart';
import 'package:solana_kit_rpc_spec/src/rpc_transport.dart';

/// Options for sending an RPC request.
class RpcSendOptions {
  /// Creates a new [RpcSendOptions].
  const RpcSendOptions({this.abortSignal});

  /// An optional [Future] that you can supply when triggering a
  /// [PendingRpcRequest] that you might later need to abort.
  final Future<void>? abortSignal;
}

/// A pending request that encapsulates all the information necessary to make
/// an RPC request without actually making it.
///
/// Calling [send] will trigger the request and return a [Future] for the
/// response.
class PendingRpcRequest<TResponse> {
  /// Creates a new [PendingRpcRequest].
  const PendingRpcRequest({required this.plan, required this.transport});

  /// The RPC plan that describes how to execute this request.
  final RpcPlan<TResponse> plan;

  /// The transport used to send the request.
  final RpcTransport transport;

  /// Sends the RPC request and returns the response.
  Future<TResponse> send([RpcSendOptions? options]) {
    return plan.execute(
      RpcPlanExecuteConfig(transport: transport, signal: options?.abortSignal),
    );
  }
}

/// Configuration for creating an [Rpc] instance via [createRpc].
class RpcConfig {
  /// Creates a new [RpcConfig].
  const RpcConfig({required this.api, required this.transport});

  /// The RPC API that defines how method calls are converted into
  /// [RpcPlan] instances.
  final RpcApi api;

  /// The transport used to send RPC requests.
  final RpcTransport transport;
}

/// An RPC API definition that maps method names to [RpcPlan] instances.
///
/// This serves as the base class for APIs. Concrete implementations should
/// expose methods that return [RpcPlan] instances.
///
/// There are two ways to create an [RpcApi]:
///
/// 1. Use [JsonRpcApiAdapter] (wrapping a [JsonRpcApi] from
///    [createJsonRpcApi]) for a dynamic approach where method names and
///    params are passed as arguments.
///
/// 2. Use [MapRpcApi] with a map of method handlers.
///
/// 3. Create a custom subclass that overrides [getPlan].
// ignore: one_member_abstracts
abstract class RpcApi {
  /// Returns an [RpcPlan] for the given [methodName] and [params].
  ///
  /// Returns `null` if no plan is available for the given method.
  RpcPlan<Object?>? getPlan(String methodName, List<Object?> params);
}

/// An [RpcApi] implementation backed by a [JsonRpcApi].
///
/// This adapter wraps a [JsonRpcApi] to conform to the [RpcApi] interface.
class JsonRpcApiAdapter extends RpcApi {
  /// Creates a new [JsonRpcApiAdapter].
  JsonRpcApiAdapter(this._jsonRpcApi);

  final JsonRpcApi _jsonRpcApi;

  @override
  RpcPlan<Object?> getPlan(String methodName, List<Object?> params) {
    return _jsonRpcApi.call(methodName, params);
  }
}

/// An [RpcApi] backed by a map of method name to handler function.
///
/// This allows creating an API with concrete method implementations.
class MapRpcApi extends RpcApi {
  /// Creates a new [MapRpcApi] from a map of method handlers.
  MapRpcApi(this._methods);

  final Map<String, RpcPlan<Object?> Function(List<Object?> params)> _methods;

  @override
  RpcPlan<Object?>? getPlan(String methodName, List<Object?> params) {
    final handler = _methods[methodName];
    if (handler == null) {
      return null;
    }
    return handler(params);
  }
}

/// The main RPC client.
///
/// An [Rpc] wraps an [RpcApi] and an [RpcTransport] to provide a way to
/// call RPC methods and get [PendingRpcRequest] instances back.
///
/// Since Dart doesn't support JavaScript-style Proxy objects, methods are
/// called through the [request] method which takes a method name and
/// optional parameters.
///
/// ```dart
/// final rpc = createRpc(
///   RpcConfig(
///     api: JsonRpcApiAdapter(createJsonRpcApi()),
///     transport: myTransport,
///   ),
/// );
///
/// final result = await rpc.request<int>('getBalance', ['address']).send();
/// ```
class Rpc {
  /// Creates a new [Rpc].
  const Rpc({required this.api, required this.transport});

  /// The RPC API.
  final RpcApi api;

  /// The transport used to send RPC requests.
  final RpcTransport transport;

  /// Creates a [PendingRpcRequest] for the given [methodName] and [params].
  ///
  /// Throws a [SolanaError] with code
  /// [SolanaErrorCode.rpcApiPlanMissingForRpcMethod] if no API plan is
  /// available for the given method.
  PendingRpcRequest<Object?> request(
    String methodName, [
    List<Object?> params = const [],
  ]) {
    final plan = api.getPlan(methodName, params);
    if (plan == null) {
      throw SolanaError(SolanaErrorCode.rpcApiPlanMissingForRpcMethod, {
        'method': methodName,
        'params': params,
      });
    }
    return PendingRpcRequest<Object?>(plan: plan, transport: transport);
  }
}

/// Creates an [Rpc] instance from the given [config].
///
/// The [Rpc] wraps the provided [RpcApi] and [RpcTransport] to create
/// [PendingRpcRequest] instances when RPC methods are called.
Rpc createRpc(RpcConfig config) {
  return Rpc(api: config.api, transport: config.transport);
}
