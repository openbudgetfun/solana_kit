// ignore_for_file: avoid_print
/// Example 23: Send and confirm a transaction on devnet.
///
/// Demonstrates the full pipeline:
///   airdrop → build message → compile → sign → send → confirm.
///
/// ⚠️  Requires internet access (devnet).  Airdrops can fail if the devnet
///     faucet is rate-limited; retry after a few seconds if that happens.
///
/// Run:
///   dart examples/23_transaction_send_and_confirm.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart' hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

  // ── 1. Create a payer key pair and request an airdrop ─────────────────────
  final payer = generateKeyPairSigner();
  print('Payer: ${payer.address.value}');

  print('Requesting 0.1 SOL airdrop …');
  await rpc
      .requestAirdrop(payer.address, Lamports(BigInt.from(100_000_000)))
      .send();

  // Wait briefly for the airdrop to land.
  await Future<void>.delayed(const Duration(seconds: 3));
  final balance = await rpc.getBalanceValue(payer.address).send();
  print('Balance after airdrop: ${balance.value} lamports');

  // ── 2. Fetch a recent blockhash ───────────────────────────────────────────
  final blockhashResult = await rpc.getLatestBlockhashValue().send();
  final blockhash = blockhashResult.value;

  // ── 3. Build the transaction message ──────────────────────────────────────
  // We send a Memo instruction as the simplest possible transaction.
  const memoProgram = Address('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr');
  final memoData = Uint8List.fromList('Hello devnet!'.codeUnits);

  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(payer.address)
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: blockhash.blockhash.value,
          lastValidBlockHeight: blockhash.lastValidBlockHeight,
        ),
      )
      .appendInstruction(
        Instruction(
          programAddress: memoProgram,
          accounts: [
            AccountMeta(
              address: payer.address,
              role: AccountRole.readonlySigner,
            ),
          ],
          data: memoData,
        ),
      );

  // ── 4. Compile and sign ───────────────────────────────────────────────────
  final transaction = compileTransaction(message);
  final signed = await signTransactionWithSigners([payer], transaction);

  // ── 5. Send and confirm ───────────────────────────────────────────────────
  print('\nSending transaction …');
  final sig = await sendAndConfirmTransaction(rpc: rpc, transaction: signed);
  print('Confirmed! Signature: $sig');
  print('Explorer: https://explorer.solana.com/tx/$sig?cluster=devnet');
}
