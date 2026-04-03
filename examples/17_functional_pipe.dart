// ignore_for_file: avoid_print
/// Example 17: Functional pipeline with `.pipe()`.
///
/// The [Pipe] extension adds a `.pipe(fn)` method to any Dart value, enabling
/// readable left-to-right function composition – a common pattern in the
/// Solana Kit codebase for building transaction messages.
///
/// Run:
///   dart examples/17_functional_pipe.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  // ── 1. Basic pipe on primitive values ─────────────────────────────────────
  final result = 'hello'
      .pipe((String s) => s.toUpperCase())
      .pipe((String s) => '$s, SOLANA!')
      .pipe((String s) => s.split(', '));

  print('Piped result: $result');

  // ── 2. Pipe to build a transaction message ────────────────────────────────
  // `.pipe()` lets you compose message transformations in a readable chain
  // without deeply nested function calls.
  const feePayer = Address('9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g');
  const memoProgram = Address('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr');

  final message = createTransactionMessage(version: TransactionVersion.v0)
      .pipe((TransactionMessage m) => m.withFeePayer(feePayer))
      .pipe(
        (TransactionMessage m) => m.withBlockhashLifetime(
          BlockhashLifetimeConstraint(
            blockhash: '4FJML71TpEbUPnxJFTFwN1bGDPpR7bPTFWXxGmNnGRpZ',
            lastValidBlockHeight: BigInt.from(99999999),
          ),
        ),
      )
      .pipe(
        (TransactionMessage m) => m.appendInstruction(
          const Instruction(programAddress: memoProgram),
        ),
      );

  print('\nTransaction message version  : ${message.version}');
  print('Fee payer                    : ${message.feePayer?.value}');
  print('Instruction count            : ${message.instructions.length}');
  print('Has blockhash lifetime       : '
      '${message.lifetimeConstraint is BlockhashLifetimeConstraint}');

  // ── 3. Pipe for data transforms ───────────────────────────────────────────
  final lamports = BigInt.from(1_000_000_000)
      .pipe((BigInt n) => n / BigInt.from(1_000_000_000)) // to SOL
      .pipe((num sol) => '${sol.toStringAsFixed(3)} SOL');

  print('\n1 SOL in lamports → $lamports');
}
