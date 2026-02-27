// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart'
    as tc;

void main() {
  final orderA = tc.commitmentComparator(
    Commitment.processed,
    Commitment.confirmed,
  );
  final orderB = tc.commitmentComparator(
    Commitment.finalized,
    Commitment.confirmed,
  );

  print('processed vs confirmed: $orderA');
  print('finalized vs confirmed: $orderB');
}
