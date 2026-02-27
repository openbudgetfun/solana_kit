// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

void main() {
  print('MWA retry delays: $mwaRetryDelayScheduleMs');
  print('MWA connection timeout (ms): $mwaConnectionTimeoutMs');
  print('MWA association port range: $mwaMinAssociationPort-$mwaMaxAssociationPort');
}
