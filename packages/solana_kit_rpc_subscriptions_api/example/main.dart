// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const address = Address('11111111111111111111111111111111');

  final params = accountNotificationsParams(
    address,
    const AccountNotificationsConfig(
      commitment: Commitment.finalized,
      encoding: 'base64',
    ),
  );

  print('Subscription params: $params');
}
