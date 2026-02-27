// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc/solana_kit_rpc.dart';

void main() {
  final payload = <String, Object?>{
    'id': '1',
    'jsonrpc': '2.0',
    'method': 'getBalance',
    'params': ['11111111111111111111111111111111'],
  };

  final dedupeKey = getSolanaRpcPayloadDeduplicationKey(payload);

  print('Deduplication key: $dedupeKey');
}
