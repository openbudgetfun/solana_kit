// ignore_for_file: avoid_print
/// Example 22: Helius priority fee estimates (API-key required).
///
/// Priority fees help your transaction land faster during congestion.
/// Helius provides per-account and per-instruction fee estimates.
///
/// ⚠️  Replace `YOUR_API_KEY` with a real key from https://helius.dev.
///
/// Run:
///   dart examples/22_helius_priority_fee.dart
library;

import 'package:solana_kit_helius/solana_kit_helius.dart';

Future<void> main() async {
  const apiKey = 'YOUR_API_KEY'; // ← fill in

  if (apiKey == 'YOUR_API_KEY') {
    print('Set a real Helius API key to run this example.');
    print('Get one free at https://helius.dev');
    _printStructureDoc();
    return;
  }

  final helius = createHelius(HeliusConfig(apiKey: apiKey));

  // ── 1. Get fee estimates for common accounts ───────────────────────────────
  // Accounts that are read/written by your transaction influence fees.
  const accountAddresses = [
    'So11111111111111111111111111111111111111112', // wSOL mint
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', // USDC mint
  ];

  print('Fetching priority fee estimates for $accountAddresses …');
  final feeEstimate = await helius.priorityFee.getPriorityFeeEstimate(
    GetPriorityFeeEstimateRequest(accountKeys: accountAddresses),
  );

  // The response includes per-priority-level micro-lamports per compute-unit.
  print('Fee estimate: $feeEstimate');

  // ── 2. Interpret the priority levels ─────────────────────────────────────
  // Typical priority levels: min, low, medium, high, veryHigh, unsafeMax.
  // Use `high` for time-sensitive transactions and `medium` for routine ones.
  print('\nTip: multiply the fee by your compute units to get total lamports.');
  print('Example: 100_000 CUs × ${feeEstimate.priorityFeeEstimate ?? 0} '
      'µL/CU = '
      '${((feeEstimate.priorityFeeEstimate ?? 0) * 100000 / 1000).toStringAsFixed(0)} lamports');
}

void _printStructureDoc() {
  print('''
GetPriorityFeeEstimateRequest fields:
  accountKeys   List<String>   – accounts your transaction touches
  options       PriorityFeeEstimateOptions?

PriorityFeeEstimateResponse fields:
  priorityFeeEstimate  double?  – recommended fee in µL/CU
''');
}
