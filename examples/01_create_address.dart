// ignore_for_file: avoid_print
/// Example 01: Create and validate Solana addresses.
///
/// Demonstrates how to construct [Address] values, validate arbitrary strings,
/// and catch [SolanaError] when the input is invalid.
///
/// Run:
///   dart examples/01_create_address.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  // ── 1. Construct from a known-good base58 string ─────────────────────────
  // The `Address(...)` constructor accepts any string.  Use it only when you
  // are certain the value is already a valid 32-byte base58 address.
  const systemProgram = Address('11111111111111111111111111111111');
  print('System program: ${systemProgram.value}');

  // ── 2. Validate an untrusted string ──────────────────────────────────────
  // `address()` (lowercase) validates and throws on failure.
  const devnetWallet = '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g';
  final validated = address(devnetWallet);
  print('Validated address: ${validated.value}');

  // ── 3. assertIsAddress helper ─────────────────────────────────────────────
  // Useful when you need to assert inside a larger validation pipeline.
  assertIsAddress('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  print('Token program address is valid');

  // ── 4. Handle an invalid address ──────────────────────────────────────────
  try {
    address('not-a-valid-address');
  } on SolanaError catch (e) {
    // SolanaErrorCode.addressesStringLengthOutOfRange is thrown here because
    // the string is too short.
    print('Caught expected error: code=${e.code}');
  }

  // ── 5. Address equality ───────────────────────────────────────────────────
  // Address is an extension type over String, so equality is string equality.
  const a1 = Address('11111111111111111111111111111111');
  const a2 = Address('11111111111111111111111111111111');
  print('Addresses equal: ${a1 == a2}');
}
