/// Config program client for the Solana Kit Dart SDK.
///
/// Provides generated codecs, account decoders, and instruction builders for
/// Solana's native Config program, plus ergonomic helpers for storing
/// configuration data.
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
///

library;

export 'src/generated/config.dart';
export 'src/helpers/store_config.dart';
