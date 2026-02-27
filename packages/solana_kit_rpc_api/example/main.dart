// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const target = Address('11111111111111111111111111111111');
  const config = GetBalanceConfig(commitment: Commitment.finalized);

  final params = getBalanceParams(target, config);

  print('RPC method params: $params');
}
