/// Transaction message builders and transforms for the Solana Kit Dart SDK.
///
/// Use this library to assemble immutable transaction messages, configure
/// lifetimes, append instructions, and compile or decompile message state.
///
/// <!-- {=docsBuildTransactionSection} -->
///
/// ## Build a transaction message
///
/// Transaction messages are assembled incrementally. The most common pattern is:
///
/// 1. Create an empty message.
/// 2. Set the fee payer.
/// 3. Set a lifetime constraint using a recent blockhash.
/// 4. Append one or more instructions.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit/solana_kit.dart';
///
/// Future<void> main() async {
///   final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
///   final feePayer = generateKeyPairSigner();
///   final latestBlockhash = await rpc.getLatestBlockhashValue().send();
///
///   final instruction = Instruction(
///     programAddress: const Address('11111111111111111111111111111111'),
///     accounts: [
///       AccountMeta(
///         address: feePayer.address,
///         role: AccountRole.writableSigner,
///       ),
///     ],
///     data: Uint8List(0),
///   );
///
///   final message = createTransactionMessage(version: TransactionVersion.v0)
///       .withFeePayer(feePayer.address)
///       .withBlockhashLifetime(
///         BlockhashLifetimeConstraint(
///           blockhash: latestBlockhash.value.blockhash.value,
///           lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
///         ),
///       )
///       .appendInstruction(instruction);
///
///   print(message);
/// }
/// ```
///
/// This separation keeps transaction construction explicit and makes it easier to
/// reason about fee payment, expiry, and instruction ordering. If you prefer a
/// more fluent style, the transaction-message extension methods build on the same
/// underlying model.
///
/// <!-- {/docsBuildTransactionSection} -->
library;

export 'src/addresses_by_lookup_table_address.dart';
export 'src/blockhash.dart';
export 'src/codecs/address_table_lookup_codec.dart';
export 'src/codecs/header_codec.dart';
export 'src/codecs/instruction_codec.dart';
export 'src/codecs/message_codec.dart';
export 'src/codecs/transaction_version_codec.dart';
export 'src/compile_accounts.dart';
export 'src/compile_address_table_lookups.dart';
export 'src/compile_header.dart';
export 'src/compile_instructions.dart';
export 'src/compile_lifetime_token.dart';
export 'src/compile_static_accounts.dart';
export 'src/compile_transaction_message.dart';
export 'src/compiled_transaction_message.dart';
export 'src/compress_transaction_message.dart';
export 'src/create_transaction_message.dart';
export 'src/decompile_message.dart';
export 'src/durable_nonce.dart';
export 'src/durable_nonce_instruction.dart';
export 'src/fee_payer.dart';
export 'src/instructions.dart';
export 'src/lifetime.dart';
export 'src/pipe.dart';
export 'src/transaction_message.dart';
export 'src/transaction_message_extensions.dart';
