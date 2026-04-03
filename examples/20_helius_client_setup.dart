// ignore_for_file: avoid_print
/// Example 20: Set up the Helius client (API-key placeholder).
///
/// Helius provides enhanced Solana APIs: DAS (Digital Asset Standard), smart
/// transactions, priority fees, webhooks, and more.
///
/// ⚠️  Replace `YOUR_API_KEY` with a real key from https://helius.dev to
///     actually connect.  Without a valid key the client is constructed but
///     all network calls will fail.
///
/// Run:
///   dart examples/20_helius_client_setup.dart
library;

import 'package:solana_kit_helius/solana_kit_helius.dart';

void main() {
  // ── 1. Minimal setup with an API key ──────────────────────────────────────
  // Replace this placeholder before running network calls.
  const apiKey = 'YOUR_API_KEY'; // ← fill in

  final config = HeliusConfig(
    apiKey: apiKey,
    cluster: HeliusCluster.devnet, // use devnet for safe experimentation
  );

  print('RPC URL  : ${config.rpcUrl}');
  print('REST base: ${config.restBaseUrl}');
  print('WS URL   : ${config.wsUrl}');

  // ── 2. Create the HeliusClient ─────────────────────────────────────────────
  final helius = createHelius(config);

  // `helius` exposes sub-clients for each API domain:
  //   helius.das            → Digital Asset Standard (NFTs, tokens)
  //   helius.priorityFee    → priority fee estimates
  //   helius.enhanced       → enhanced transactions
  //   helius.webhooks       → webhook management
  //   helius.zk             → ZK compression
  //   helius.transactions   → smart transaction sending
  //   helius.staking        → staking operations
  //   helius.wallet         → wallet-level helpers
  //   helius.auth           → API key authentication
  //   helius.websocket      → enhanced WebSocket subscriptions

  print('\nHeliusClient sub-clients available:');
  print('  das          : ${helius.das.runtimeType}');
  print('  priorityFee  : ${helius.priorityFee.runtimeType}');
  print('  enhanced     : ${helius.enhanced.runtimeType}');
  print('  webhooks     : ${helius.webhooks.runtimeType}');
  print('  transactions : ${helius.transactions.runtimeType}');

  // ── 3. Mainnet config ─────────────────────────────────────────────────────
  final mainnetConfig = HeliusConfig(
    apiKey: apiKey,
    // cluster defaults to HeliusCluster.mainnet if omitted
  );
  print('\nMainnet RPC: ${mainnetConfig.rpcUrl}');
}
