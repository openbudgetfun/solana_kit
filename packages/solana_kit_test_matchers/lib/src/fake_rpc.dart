import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Builds a fake RPC response from [params].
typedef FakeRpcResponseFactory = Object? Function(List<Object?> params);

/// A fake [RpcTransport] that returns canned JSON-RPC responses.
class FakeRpcTransport {
  /// Creates a [FakeRpcTransport].
  FakeRpcTransport(this._responses);

  final Map<String, Object?> _responses;

  /// Every transport config observed by [call].
  final List<RpcTransportConfig> calls = <RpcTransportConfig>[];

  /// Handles a single transport request.
  Future<Object?> call(RpcTransportConfig config) async {
    calls.add(config);

    final payload = config.payload;
    if (payload is! Map<String, Object?>) {
      return {'jsonrpc': '2.0', 'id': 1, 'result': null};
    }

    final method = payload['method'] as String?;
    final id = payload['id'];
    final params = (payload['params'] as List<Object?>?) ?? const <Object?>[];
    final configured = method == null ? null : _responses[method];
    final result = configured is FakeRpcResponseFactory
        ? configured(params)
        : configured;

    return {'jsonrpc': '2.0', 'id': id, 'result': result};
  }
}

/// Creates a Solana RPC client backed by a [FakeRpcTransport].
({Rpc rpc, FakeRpcTransport transport}) createFakeRpc(
  Map<String, Object?> responses,
) {
  final transport = FakeRpcTransport(responses);
  return (
    rpc: createSolanaRpcFromTransport(transport.call),
    transport: transport,
  );
}
