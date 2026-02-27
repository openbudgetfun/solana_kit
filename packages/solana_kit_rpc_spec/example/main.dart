// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

Future<void> main() async {
  final rpc = createRpc(
    RpcConfig(
      api: MapRpcApi({
        'ping': (params) {
          return RpcPlan<Object?>(
            execute: (config) => config.transport(
              RpcTransportConfig(
                payload: createRpcMessage(
                  RpcRequest<List<Object?>>(
                    methodName: 'ping',
                    params: params,
                  ),
                ),
                signal: config.signal,
              ),
            ),
          );
        },
      }),
      transport: (_) async => <String, Object?>{'ok': true},
    ),
  );

  final result = await rpc.request('ping', ['demo']).send();
  print('RPC result: $result');
}
