// ignore_for_file: avoid_print
/// Example 19: Sort and compare Solana addresses.
///
/// Demonstrates [getAddressComparator] for sorting address lists
/// deterministically – useful when building account-meta arrays that must be
/// in a stable order matching the Solana runtime's base58 collation rules.
///
/// Run:
///   dart examples/19_address_comparator.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  // ── 1. Obtain the comparator ───────────────────────────────────────────────
  final cmp = getAddressComparator();

  const systemProgram = Address('11111111111111111111111111111111');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  const walletAddr = Address('9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g');

  // ── 2. Simple two-address comparison ──────────────────────────────────────
  final result = cmp(systemProgram, tokenProgram);
  print('compare(systemProgram, tokenProgram): $result '
      '(negative = system < token by base58 order)');

  // ── 3. Sort a list of addresses ───────────────────────────────────────────
  final addresses = [tokenProgram, walletAddr, systemProgram];
  addresses.sort(cmp);
  print('\nSorted addresses:');
  for (final addr in addresses) {
    print('  ${addr.value}');
  }

  // ── 4. Verify determinism ─────────────────────────────────────────────────
  final list2 = [walletAddr, systemProgram, tokenProgram];
  list2.sort(cmp);
  final same = addresses
      .map((a) => a.value)
      .toList()
      .join(',') == list2.map((a) => a.value).toList().join(',');
  print('\nTwo differently-ordered inputs sort identically: $same');

  // ── 5. Equality by byte value ─────────────────────────────────────────────
  const dup1 = Address('11111111111111111111111111111111');
  const dup2 = Address('11111111111111111111111111111111');
  print('cmp(dup1, dup2) == 0: ${cmp(dup1, dup2) == 0}');

  // ── 6. Use in a sorted set (via List.sort) ────────────────────────────────
  // This mirrors how the Solana runtime orders static accounts in a compiled
  // transaction message.
  final accounts = [
    const Address('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr'),
    systemProgram,
    walletAddr,
  ]..sort(cmp);

  print('\nAccounts in runtime order:');
  for (final a in accounts) {
    print('  ${a.value}');
  }
}
