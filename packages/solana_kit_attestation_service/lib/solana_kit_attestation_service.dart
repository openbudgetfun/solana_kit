/// Solana Attestation Service program client for the Solana Kit Dart SDK.
///
/// Provides generated instruction builders, account codecs, and PDA helpers
/// for the Solana Attestation Service, the on-chain protocol for verifiable
/// credentials: issuers register credentials, declare schemas, and issue
/// attestations that verifiers can fetch and decode.
///
/// ## Quick start
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
///
/// Future<void> main() async {
///   const authority = Address('tbFevHibEdBNFJfZ7xKC8k1th8pt2YPEXTk4sGMxCGa');
///
///   // Derive the credential address of an issuer.
///   final (credential, _) = await findCredentialPda(
///     seeds: const CredentialSeeds(authority: authority, name: 'my-credential'),
///   );
///
///   // Build the create-credential instruction.
///   final instruction = getCreateCredentialInstruction(
///     programAddress: solanaAttestationServiceProgramAddress,
///     payer: authority,
///     credential: credential,
///     authority: authority,
///     systemProgram: systemProgramAddress,
///     name: 'my-credential',
///     signers: [authority],
///   );
///   print(instruction.programAddress);
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

export 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    show solanaAttestationServiceProgramAddress;
export 'src/errors.dart';
export 'src/generated/solana_attestation_service.dart'
    hide solanaAttestationServiceProgramAddress;
export 'src/pdas.dart';
export 'src/schema_codec.dart';
