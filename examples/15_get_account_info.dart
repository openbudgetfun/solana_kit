// ignore_for_file: avoid_print
/// Example 15: Fetch and inspect account info via RPC (devnet).
///
/// Demonstrates [getAccountInfo], [getAccountInfoValue], and how to detect
/// a missing account.
///
/// ⚠️  This example makes live network requests to the Solana devnet.
///
/// Run:
///   dart examples/15_get_account_info.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

  // ── 1. System program account (always exists) ─────────────────────────────
  const systemProgram = Address('11111111111111111111111111111111');

  final rawInfo = await rpc.getAccountInfo(systemProgram).send();
  print('System program raw response keys: ${(rawInfo['value'] as Map?)?.keys}');

  // ── 2. Typed wrapper: SolanaRpcResponse<Map?> ─────────────────────────────
  // getAccountInfoValue parses the result into a typed response wrapper
  // that includes context (slot) and value (account or null).
  final typedInfo = await rpc.getAccountInfoValue(
    systemProgram,
    GetAccountInfoConfig(encoding: AccountEncoding.base64),
  ).send();

  final account = typedInfo.value;
  if (account != null) {
    print('\nSystem program exists.');
    print('  owner     : ${account['owner']}');
    print('  lamports  : ${account['lamports']}');
    print('  executable: ${account['executable']}');
  }

  // ── 3. Account that likely does not exist on devnet ───────────────────────
  // A freshly generated public key almost certainly has no account.
  const nonExistent = Address('11111111111111111111111111111112');
  final missing = await rpc.getAccountInfoValue(nonExistent).send();

  if (missing.value == null) {
    print('\nAccount $nonExistent does not exist (expected).');
  }

  // ── 4. Fetch multiple accounts in one call ────────────────────────────────
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  final multi = await rpc.getMultipleAccountsValue(
    [systemProgram, tokenProgram],
  ).send();

  print('\ngetMultipleAccounts returned ${multi.value.length} results:');
  for (var i = 0; i < multi.value.length; i++) {
    final a = multi.value[i];
    print('  [$i] ${a == null ? 'null' : 'owner=${a['owner']}'}');
  }
}
