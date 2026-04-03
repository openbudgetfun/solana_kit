// ignore_for_file: avoid_print
/// Example 11: Build and compile a transaction message.
///
/// Demonstrates the step-by-step pipeline:
///   create message → set fee payer → set lifetime → append instruction
///   → compile → sign.
///
/// No network access required; uses a placeholder blockhash.
///
/// Run:
///   dart examples/11_build_transaction.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

Future<void> main() async {
  // ── 1. Generate a fee-payer signer ────────────────────────────────────────
  final feePayer = generateKeyPairSigner();
  print('Fee payer: ${feePayer.address.value}');

  // ── 2. Create an empty v0 transaction message ─────────────────────────────
  // TransactionVersion.v0 is the modern versioned-transaction format that
  // supports address-lookup tables.
  final emptyMessage = createTransactionMessage(version: TransactionVersion.v0);

  // ── 3. Set the fee payer ──────────────────────────────────────────────────
  final withFeePayer = emptyMessage.withFeePayer(feePayer.address);

  // ── 4. Set a blockhash lifetime ───────────────────────────────────────────
  // In production call rpc.getLatestBlockhashValue().send() to fetch a real
  // blockhash; here we use a placeholder.
  const placeholderBlockhash = '4FJML71TpEbUPnxJFTFwN1bGDPpR7bPTFWXxGmNnGRpZ';
  final withLifetime = withFeePayer.withBlockhashLifetime(
    BlockhashLifetimeConstraint(
      blockhash: placeholderBlockhash,
      lastValidBlockHeight: BigInt.from(9999999),
    ),
  );

  // ── 5. Build a memo instruction ───────────────────────────────────────────
  // The Memo program (MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr) accepts
  // a UTF-8 string as its sole instruction data.
  const memoProgram = Address('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr');
  final memoData = Uint8List.fromList('Hello from Dart!'.codeUnits);

  final memoInstruction = Instruction(
    programAddress: memoProgram,
    accounts: [
      AccountMeta(
        address: feePayer.address,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: memoData,
  );

  // ── 6. Append the instruction ─────────────────────────────────────────────
  final readyMessage = withLifetime.appendInstruction(memoInstruction);

  print('Instructions : ${readyMessage.instructions.length}');
  print('Fee payer    : ${readyMessage.feePayer?.value}');

  // ── 7. Compile the message into a wire-format Transaction ─────────────────
  final transaction = compileTransaction(readyMessage);
  print('Compiled transaction signatures: ${transaction.signatures.length}');

  // ── 8. Sign the transaction ───────────────────────────────────────────────
  final signedTx = await signTransactionWithSigners(
    [feePayer],
    transaction,
  );

  final sig = signedTx.signatures[feePayer.address];
  print('Signed: ${sig != null}');
  print('Signature length: ${sig?.value.length} bytes');
}
