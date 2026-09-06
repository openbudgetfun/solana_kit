/// Address Lookup Table program client for the Solana Kit Dart SDK.
///
/// Provides instruction builders, codecs, account decoders, and parsers for the
/// Address Lookup Table program, which manages lookup tables used in versioned
/// (v0) transactions.
///
/// ## Quick start
///
/// ```dart
/// import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
/// import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
///
/// Future<void> main() async {
///   const authority = Address('11111111111111111111111111111112');
///   final (tableAddress, bump) = await getProgramDerivedAddress(
///     programAddress: addressLookupTableProgramAddress,
///     seeds: [authority.value, 'my-table'],
///   );
///
///   // Create a lookup table
///   final createIx = getCreateLookupTableInstruction(  // ignore: unused_local_variable
///     programAddress: addressLookupTableProgramAddress,
///     address: tableAddress,
///     authority: authority,
///     payer: authority,
///     systemProgram: systemProgramAddress,
///     recentSlot: BigInt.from(123),
///     bump: bump,
///   );
///
///   // Extend a lookup table with new addresses
///   final extendIx = getExtendLookupTableInstruction(  // ignore: unused_local_variable
///     programAddress: addressLookupTableProgramAddress,
///     address: tableAddress,
///     authority: authority,
///     payer: authority,
///     systemProgram: systemProgramAddress,
///     addresses: [Address('11111111111111111111111111111113')],
///   );
/// }
/// ```
///
/// <!-- {=generatedProgramClientSection} -->
///
/// ## How generated program clients work
///
/// Generated program clients share one API shape, so what you learn in one program transfers to the next:
///
/// - **Program address constant** — a `...ProgramAddress` constant identifies the program on-chain.
/// - **Identification helpers** — `identify...Program` and `identify...Instruction` match programs and instructions without string comparisons.
/// - **Instruction builders and parsers** — `get...Instruction` encodes parameters, `parse...Instruction` decodes a transaction instruction back into typed arguments.
/// - **Account codecs** — `get...AccountCodec` and `decode...Account` turn on-chain bytes into typed account objects.
/// - **Plan helpers** — `get...InstructionPlan` helpers compose multi-instruction flows (such as creating an account before acting on it) into transaction plans the standard executor can run.
///
/// Errors thrown by these helpers and by transaction execution surface as `SolanaError`; match program-specific failures with the program error helpers.
///
/// <!-- {/generatedProgramClientSection} -->
///
/// <!-- {=programErrorHandlingSection} -->
///
/// ## Match program errors from your program
///
/// Transaction failures surface as `SolanaError` values. When a transaction fails with a custom program error, the RPC response identifies the failing instruction by index — pair it with the transaction message to attribute the error to a program and match custom error codes.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_programs/solana_kit_programs.dart';
///
/// Future<void> handleTransactionFailure(Object error) async {
///   const myProgramAddress = Address('11111111111111111111111111111111');
///   final transactionMessage = TransactionMessageInput(
///     instructions: {0: InstructionInput(programAddress: myProgramAddress)},
///   );
///
///   if (isProgramError(error, transactionMessage, myProgramAddress, 42)) {
///     // Custom program error code 42 from this program.
///   } else if (isProgramError(error, transactionMessage, myProgramAddress)) {
///     // Any other custom error from this program.
///   }
/// }
/// ```
///
/// `transactionMessage` is a lightweight `TransactionMessageInput` — a map from instruction index to `InstructionInput(programAddress: ...)`. Build it from the same instructions you sent, so matching stays accurate even when the transaction mixes instructions from several programs.
///
/// <!-- {/programErrorHandlingSection} -->

library;

export 'src/generated/address_lookup_table.dart';
