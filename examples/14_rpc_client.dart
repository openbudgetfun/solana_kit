// ignore_for_file: avoid_print
/// Example 14: Create an RPC client and fetch cluster info (devnet).
///
/// Demonstrates [createSolanaRpc] and common read-only RPC calls:
///   getSlot, getLatestBlockhash, getBalance, getEpochInfo.
///
/// ⚠️  This example makes live network requests to the Solana devnet.
///     Run it only when you have internet access.
///
/// Run:
///   dart examples/14_rpc_client.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  // ── 1. Create an RPC client pointing at devnet ────────────────────────────
  // createSolanaRpc builds an HTTP-transport-backed client with default
  // transformers (BigInt coercion, commitment injection, etc.).
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
  print('Connected to devnet');

  // ── 2. Fetch the current slot ─────────────────────────────────────────────
  // `rpc.getSlot()` returns a PendingRpcRequest; calling `.send()` executes it.
  final slot = await rpc.getSlot().send();
  print('Current slot: $slot');

  // ── 3. Fetch the latest blockhash ─────────────────────────────────────────
  // The blockhash is needed to set a transaction's lifetime constraint.
  final blockhashResult = await rpc.getLatestBlockhashValue().send();
  final blockhash = blockhashResult.value;
  print('Latest blockhash  : ${blockhash.blockhash}');
  print('Last valid height : ${blockhash.lastValidBlockHeight}');

  // ── 4. Fetch the balance of a well-known address ──────────────────────────
  // The system program always exists; its balance will be 1 lamport.
  const systemProgram = Address('11111111111111111111111111111111');
  final balanceResult = await rpc.getBalanceValue(systemProgram).send();
  print('System program balance: ${balanceResult.value} lamports');

  // ── 5. Get epoch info ─────────────────────────────────────────────────────
  final epochInfo = await rpc.getEpochInfo().send();
  print('Epoch info: $epochInfo');
}
