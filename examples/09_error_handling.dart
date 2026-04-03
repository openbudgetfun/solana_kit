// ignore_for_file: avoid_print
/// Example 09: SolanaError and error-domain routing.
///
/// Demonstrates how to create, inspect, and route [SolanaError] values using
/// numeric error codes and [SolanaErrorDomain].
///
/// Run:
///   dart examples/09_error_handling.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  // ── 1. Construct a SolanaError directly ──────────────────────────────────
  final err = SolanaError(
    SolanaErrorCode.accountsAccountNotFound,
    {'address': '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g'},
  );
  print('Error code   : ${err.code}');
  print('Error message: $err');

  // ── 2. Catch from a validation helper ────────────────────────────────────
  try {
    address('too-short'); // throws SolanaError
  } on SolanaError catch (e) {
    print('\nCaught validation error:');
    print('  code : ${e.code}');
    print('  is addresses domain: ${e.isInDomain(SolanaErrorDomain.addresses)}');
  }

  // ── 3. Domain routing ─────────────────────────────────────────────────────
  void route(SolanaError e) {
    if (e.isInDomain(SolanaErrorDomain.addresses)) {
      print('  → address error');
    } else if (e.isInDomain(SolanaErrorDomain.keys)) {
      print('  → key/signature error');
    } else if (e.isInDomain(SolanaErrorDomain.rpc)) {
      print('  → RPC error');
    } else if (e.isInDomain(SolanaErrorDomain.transaction)) {
      print('  → transaction error');
    } else {
      print('  → other Solana error (code=${e.code})');
    }
  }

  print('\nRouting errors by domain:');
  final samples = [
    SolanaError(SolanaErrorCode.addressesInvalidByteLength),
    SolanaError(SolanaErrorCode.keysInvalidKeyPairByteLength),
    SolanaError(SolanaErrorCode.blockHeightExceeded),
  ];
  for (final e in samples) {
    print('code ${e.code}:');
    route(e);
  }

  // ── 4. isSolanaError type guard ────────────────────────────────────────────
  // Useful in catch blocks that handle both SolanaError and unexpected errors.
  Object thrown = SolanaError(SolanaErrorCode.accountsAccountNotFound);
  print('\nisSolanaError: ${isSolanaError(thrown)}');
  print('isSolanaError(String): ${isSolanaError("not an error")}');

  // ── 5. Specific-code guard ─────────────────────────────────────────────────
  print(
    'is accountsAccountNotFound: '
    '${isSolanaError(thrown, SolanaErrorCode.accountsAccountNotFound)}',
  );
}
