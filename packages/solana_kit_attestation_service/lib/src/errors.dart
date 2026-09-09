import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

/// Custom error codes returned by the Attestation Service program.
///
/// Mirrors the `AttestationServiceError` enum in the program source at the
/// pinned reference commit; the discriminant is the on-chain custom error
/// code.
enum AttestationServiceError {
  /// The account is not the expected Credential account.
  invalidCredential(0),

  /// The account is not the expected Schema account.
  invalidSchema(1),

  /// The account is not the expected Attestation account.
  invalidAttestation(2),

  /// The authority was not found in the Credential's authorized signers.
  invalidAuthority(3),

  /// The Schema declares an unknown data type.
  invalidSchemaDataType(4),

  /// The signer is not one of the Credential's authorized signers.
  signerNotAuthorized(5),

  /// The Attestation data does not conform to the Schema.
  invalidAttestationData(6),

  /// The account is not the expected Event Authority account.
  invalidEventAuthority(7),

  /// The account is not the expected Mint account.
  invalidMint(8),

  /// The account is not the expected program signer.
  invalidProgramSigner(9),

  /// The account is not the expected Token account.
  invalidTokenAccount(10),

  /// The Schema is paused and does not accept new attestations.
  schemaPaused(11);

  const AttestationServiceError(this.code);

  /// The on-chain custom error code for this error.
  final int code;
}

/// Returns `true` when [error] is the given [code] raised by the Attestation
/// Service program.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
/// import 'package:solana_kit_programs/solana_kit_programs.dart';
///
/// Future<void> handleTransactionFailure(Object error) async {
///   final transactionMessage = TransactionMessageInput(
///     instructions: {
///       0: InstructionInput(
///         programAddress: solanaAttestationServiceProgramAddress,
///       ),
///     },
///   );
///
///   if (isAttestationServiceError(
///     error,
///     transactionMessage,
///     AttestationServiceError.schemaPaused,
///   )) {
///     // The schema was paused.
///   }
/// }
/// ```
bool isAttestationServiceError(
  Object? error,
  TransactionMessageInput transactionMessage,
  AttestationServiceError code,
) {
  return isProgramError(
    error,
    transactionMessage,
    solanaAttestationServiceProgramAddress,
    code.code,
  );
}
