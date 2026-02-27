// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final payload = <String, Object?>{
    'jsonrpc': '2.0',
    'method': 'getLatestBlockhash',
    'params': <Object?>[],
  };

  print('Is Solana request: ${isSolanaRequest(payload)}');
}
