// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const raw = '11111111111111111111111111111111';

  assertIsBlockhash(raw);
  final normalized = blockhash(raw);

  print('Blockhash is valid: ${normalized.value}');
}
