/// The Solana Kit Dart SDK.
///
/// This is the main entry point for building Solana apps in Dart. It
/// re-exports all public packages in the `@solana/kit` ecosystem and provides
/// additional convenience helpers.
///
/// ## Quick start
///
/// ```dart
/// import 'package:solana_kit/solana_kit.dart';
///
/// void main() async {
///   // Create an RPC client.
///   final rpc = createSolanaRpc('https://api.devnet.solana.com');
///
///   // Generate a keypair.
///   final keyPair = await generateKeyPair();
///   final signer = await createKeyPairSignerFromKeyPair(keyPair);
///
///   // Check balance.
///   final balance = await rpc.getBalance(signer.address).send();
///   print('Balance: ${balance.value}');
/// }
/// ```
library;

// Core packages.
export 'package:solana_kit_accounts/solana_kit_accounts.dart';
export 'package:solana_kit_addresses/solana_kit_addresses.dart';
export 'package:solana_kit_codecs/solana_kit_codecs.dart';
export 'package:solana_kit_errors/solana_kit_errors.dart';
export 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';
export 'package:solana_kit_functional/solana_kit_functional.dart';
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
export 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
export 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
export 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
export 'package:solana_kit_transactions/solana_kit_transactions.dart';

// Umbrella-specific helpers.
export 'src/get_minimum_balance_for_rent_exemption.dart';
