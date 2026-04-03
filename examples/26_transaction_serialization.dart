// ignore_for_file: avoid_print
/// Example 26: Serialize a transaction to wire format (base64) and back.
///
/// Shows how to obtain the base64-encoded wire transaction that is submitted
/// to RPC nodes and how to decode it back.  Useful for offline signing,
/// transaction inspection, and fee calculation.
///
/// No network access required.
///
/// Run:
///   dart examples/26_transaction_serialization.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

Future<void> main() async {
  // ── 1. Build and sign a minimal transaction ───────────────────────────────
  final payer = generateKeyPairSigner();
  const memoProgram = Address('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr');

  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(payer.address)
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: '4FJML71TpEbUPnxJFTFwN1bGDPpR7bPTFWXxGmNnGRpZ',
          lastValidBlockHeight: BigInt.from(99999999),
        ),
      )
      .appendInstruction(
        Instruction(
          programAddress: memoProgram,
          data: Uint8List.fromList('hi'.codeUnits),
        ),
      );

  final compiled = compileTransaction(message);
  final signed = await signTransactionWithSigners([payer], compiled);

  // ── 2. Encode to base64 wire format ──────────────────────────────────────
  // getBase64EncodedWireTransaction is what sendTransaction() uses internally.
  final wireBase64 = getBase64EncodedWireTransaction(signed);
  print('Wire transaction (base64):');
  print('  ${wireBase64.substring(0, 40)}…');
  print('  Total length: ${wireBase64.length} chars');

  // ── 3. Get the transaction size ────────────────────────────────────────────
  // Transaction size affects both fees and the 1232-byte limit.
  final txSize = getTransactionSize(signed);
  print('\nTransaction size: $txSize bytes (limit: 1232 bytes)');

  // ── 4. Check if fully signed ──────────────────────────────────────────────
  print('isFullySignedTransaction: ${isFullySignedTransaction(signed)}');

  // ── 5. Inspect raw message bytes ─────────────────────────────────────────
  // compiled.messageBytes is the raw serialised CompiledTransactionMessage.
  print('Message bytes length: ${compiled.messageBytes.length} bytes');

  // ── 6. Read the signatures map ────────────────────────────────────────────
  final sigEntry = signed.signatures[payer.address];
  print('Signature present: ${sigEntry != null}');
  print('Signature length : ${sigEntry?.value.length} bytes');
}
