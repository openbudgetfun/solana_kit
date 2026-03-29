/// Signed transaction primitives and wire-format helpers for the Solana Kit
/// Dart SDK.
///
/// Exports transaction models, signature collections, compile helpers, and
/// serialization utilities for sending Solana transactions.
///
/// <!-- {=docsCompileTransactionSection} -->
///
/// ## Compile a transaction for signing
///
/// Once a transaction message has a fee payer, lifetime, and instructions, compile
/// it into the wire-ready transaction shape that signers and senders consume.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_instructions/solana_kit_instructions.dart';
/// import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
/// import 'package:solana_kit_transactions/solana_kit_transactions.dart';
///
/// void main() {
///   final message = createTransactionMessage(version: TransactionVersion.v0)
///       .withFeePayer(const Address('11111111111111111111111111111111'))
///       .withBlockhashLifetime(
///         BlockhashLifetimeConstraint(
///           blockhash: '11111111111111111111111111111111',
///           lastValidBlockHeight: BigInt.zero,
///         ),
///       )
///       .appendInstruction(
///         Instruction(
///           programAddress: const Address('11111111111111111111111111111111'),
///           accounts: const [
///             AccountMeta(
///               address: Address('11111111111111111111111111111111'),
///               role: AccountRole.readonly,
///             ),
///           ],
///           data: Uint8List(0),
///         ),
///       );
///
///   final transaction = compileTransaction(message);
///
///   print(transaction.signatures.length);
/// }
/// ```
///
/// Compilation is the boundary where account ordering, signer sets, and lifetime
/// constraints are frozen into the bytes that will actually be signed.
///
/// <!-- {/docsCompileTransactionSection} -->
library;

export 'src/codecs/signatures_encoder.dart';
export 'src/codecs/transaction_codec.dart';
export 'src/compile_transaction.dart';
export 'src/lifetime.dart';
export 'src/sendable_transaction.dart';
export 'src/signatures.dart';
export 'src/transaction.dart';
export 'src/transaction_size.dart';
export 'src/wire_transaction.dart';
