// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';

void main() {
  const parsed = RpcParsedType(
    type: 'spl-token-account',
    info: {'mint': 'So11111111111111111111111111111111111111112'},
  );

  print('Parsed type: ${parsed.type}');
  print('Parsed info: ${parsed.info}');
}
