// ignore_for_file: avoid_print
/// Example 24: Fetch and inspect encoded account data (devnet).
///
/// Demonstrates the account-fetch helpers from [solana_kit_accounts]:
///   fetchEncodedAccount, fetchEncodedAccounts, and the MaybeAccount sealed
///   class (ExistingAccount / NonExistingAccount).
///
/// ⚠️  Requires internet access (devnet).
///
/// Run:
///   dart examples/24_fetch_encoded_account.dart
library;

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

  // ── 1. Fetch the system program (always exists) ───────────────────────────
  const systemProgram = Address('11111111111111111111111111111111');

  final maybeAccount = await fetchEncodedAccount(rpc, systemProgram);

  switch (maybeAccount) {
    case ExistingAccount(:final account):
      print('System program exists');
      print('  address    : ${account.address.value}');
      print('  lamports   : ${account.lamports.value}');
      print('  owner      : ${account.programAddress.value}');
      print('  executable : ${account.executable}');
      print('  data bytes : ${account.data.length}');

    case NonExistingAccount():
      print('Account not found (unexpected for system program)');
  }

  // ── 2. Fetch a non-existent account ──────────────────────────────────────
  const nonExistent = Address('11111111111111111111111111111112');
  final missing = await fetchEncodedAccount(rpc, nonExistent);

  if (!missing.exists) {
    print('\nNon-existent account correctly has exists=false');
    print('  address: ${missing.address.value}');
  }

  // ── 3. Fetch multiple accounts ────────────────────────────────────────────
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  const ataProgram = Address('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe1bsn');

  final accounts = await fetchEncodedAccounts(
    rpc,
    [systemProgram, tokenProgram, ataProgram],
  );

  print('\nMultiple accounts:');
  for (final acct in accounts) {
    switch (acct) {
      case ExistingAccount(:final account):
        print('  ${account.address.value}: '
            '${account.data.length} bytes, owner=${account.programAddress.value}');
      case NonExistingAccount(:final address):
        print('  ${address.value}: MISSING');
    }
  }
}
