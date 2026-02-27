// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  const request = RpcRequest<List<Object?>>(
    methodName: 'getBalance',
    params: ['11111111111111111111111111111111'],
  );

  final message = createRpcMessage(request);

  print('Method: ${message['method']}');
  print('JSON-RPC version: ${message['jsonrpc']}');
}
