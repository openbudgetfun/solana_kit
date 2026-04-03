/// The Solana Kit Dart SDK.
///
/// Use this umbrella library when you want one import that re-exports the core
/// Solana Kit packages for addresses, RPC, accounts, transactions, signers,
/// and supporting codecs.
///
/// <!-- {=docsCreateRpcClientSection} -->
///
/// ## Create an RPC client
///
/// Start with a typed RPC client. It gives you method-specific helpers instead of
/// building raw JSON-RPC requests by hand, while still letting you swap transports
/// or request middleware later.
///
/// ```dart
/// import 'package:solana_kit/solana_kit.dart';
///
/// Future<void> main() async {
///   final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
///
///   final slot = await rpc.getSlot().send();
///   final latestBlockhash = await rpc.getLatestBlockhashValue().send();
///
///   print('Current slot: $slot');
///   print('Latest blockhash: ${latestBlockhash.value.blockhash}');
/// }
/// ```
///
/// A call like `rpc.getSlot()` builds a typed request first and only hits the
/// network when you call `.send()`. That separation makes it easier to compose,
/// cache, batch, or decorate RPC interactions.
///
/// Use `solana_kit_rpc_subscriptions` alongside `solana_kit_rpc` when you also
/// need websocket notifications for accounts, signatures, logs, or slots.
///
/// <!-- {/docsCreateRpcClientSection} -->
///
/// <!-- {=docsGenerateSignerSection} -->
///
/// ## Generate a signer
///
/// Most app flows need a signer for fee payment, message signing, or transaction
/// submission. `generateKeyPairSigner()` creates a new Ed25519 key-pair-backed
/// `KeyPairSigner`.
///
/// ```dart
/// import 'package:solana_kit/solana_kit.dart';
///
/// Future<void> main() async {
///   final signer = generateKeyPairSigner();
///
///   print('Address: ${signer.address}');
/// }
/// ```
///
/// Use key-pair signers for local development, tests, automation, and server-side
/// flows. For wallet-driven applications, you can also model fee-payer, partial,
/// and sending signers explicitly with `solana_kit_signers`.
///
/// <!-- {/docsGenerateSignerSection} -->
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

// Core packages.
export 'package:solana_kit_accounts/solana_kit_accounts.dart';
export 'package:solana_kit_addresses/solana_kit_addresses.dart';
export 'package:solana_kit_codecs/solana_kit_codecs.dart';
export 'package:solana_kit_errors/solana_kit_errors.dart';
export 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';
export 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
export 'package:solana_kit_instructions/solana_kit_instructions.dart';
export 'package:solana_kit_keys/solana_kit_keys.dart';
export 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
export 'package:solana_kit_options/solana_kit_options.dart';
export 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';
export 'package:solana_kit_programs/solana_kit_programs.dart';
export 'package:solana_kit_rpc/solana_kit_rpc.dart';
export 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
export 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
// Hide names that conflict with solana_kit_rpc.
export 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart'
    hide createSolanaJsonRpcIntegerOverflowError;
export 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
// Hide names that conflict with solana_kit_transaction_messages.
export 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide AddressTableLookup, TransactionVersion;
export 'package:solana_kit_signers/solana_kit_signers.dart';
export 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
export 'package:solana_kit_system/solana_kit_system.dart'
    hide systemProgramAddress;
export 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
export 'package:solana_kit_token/solana_kit_token.dart';
export 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
export 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
export 'package:solana_kit_transactions/solana_kit_transactions.dart';

// Umbrella-specific helpers.
export 'src/get_minimum_balance_for_rent_exemption.dart';
