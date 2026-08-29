import 'package:solana_kit_anchor/src/idl.dart';

/// An error reported by an Anchor program, resolved against the standard
/// Anchor error table or the program's own IDL errors.
class AnchorProgramError implements Exception {
  const AnchorProgramError._(this.code, this.name, this.message);

  /// The raw error code.
  final int code;

  /// The error name from the standard table or the IDL.
  final String name;

  /// The human-readable message.
  final String message;

  @override
  String toString() => 'AnchorProgramError($code, $name): $message';
}

/// Resolves an Anchor error code to a program error.
///
/// Program-defined codes (6000 and up, per the IDL `errors` list) take
/// precedence; other codes fall back to the standard Anchor error table.
/// Returns a generic entry when the code is unknown.
AnchorProgramError anchorProgramError(
  int code, {
  AnchorIdlProgram? idl,
}) {
  final custom = idl?.errors[code];
  if (custom != null) {
    return AnchorProgramError._(
      code,
      custom.name,
      custom.msg ?? 'Custom program error: $code',
    );
  }
  final standard = standardAnchorErrorMessages[code];
  return AnchorProgramError._(
    code,
    standard?.name ?? 'Unknown',
    standard?.message ?? 'Error code $code is not a known Anchor error',
  );
}

/// A standard Anchor error name and message.
typedef StandardAnchorError = ({String name, String message});

/// The standard Anchor runtime error table, mirroring the well-known codes
/// emitted by `anchor-lang`'s `ErrorCode` enum (6000 and above are reserved
/// for program-defined errors, so they are absent here).
const Map<int, StandardAnchorError> standardAnchorErrorMessages = {
  100: (
    name: 'InstructionFallbackNotFound',
    message: 'Fallback functions are not supported.',
  ),
  101: (
    name: 'InstructionDidNotDeserialize',
    message: 'The program could not deserialize the given instruction.',
  ),
  102: (
    name: 'InstructionDidNotSerialize',
    message: 'The program could not serialize the given instruction.',
  ),
  1000: (
    name: 'AccountsExhausted',
    message: 'The program could not add the account to the context.',
  ),
  1001: (
    name: 'AccountDiscriminatorNotFound',
    message: 'No discriminator was found on the account.',
  ),
  1002: (
    name: 'AccountDiscriminatorMismatch',
    message: '8 byte discriminator did not match what was expected.',
  ),
  1003: (
    name: 'AccountDiscriminatorAlreadySet',
    message: 'Discriminator already initialized.',
  ),
  1004: (
    name: 'AccountDataTooSmall',
    message: 'The account was not able to fit all the data.',
  ),
  1005: (
    name: 'AccountNotEnoughKeys',
    message: 'The account did not have the expected number of keys.',
  ),
  1006: (
    name: 'AccountNotMutable',
    message: 'The given account is not mutable',
  ),
  1007: (
    name: 'AccountOwnedByWrongProgram',
    message: 'The given account is owned by a different program than expected',
  ),
  1008: (
    name: 'InvalidProgramId',
    message: 'Program ID was not as expected',
  ),
  1009: (
    name: 'InvalidProgramExecutable',
    message: 'Program account is not executable',
  ),
  1010: (
    name: 'AccountNotSigner',
    message: 'The given account did not sign',
  ),
  1011: (
    name: 'AccountNotInitialized',
    message: 'The account was already initialized',
  ),
  1012: (
    name: 'AccountDuplicateSigners',
    message: 'The given account is not owned by the declaring program',
  ),
  1013: (
    name: 'AccountSeedsChanged',
    message: 'Rerunning the instruction will create a different PDA',
  ),
  1014: (
    name: 'AccountHasNoOwner',
    message: 'The account owner is not set',
  ),
  1015: (
    name: 'AccountInvalidPda',
    message: 'The given account is not a PDA',
  ),
  1016: (
    name: 'AccountInvalidOwner',
    message: 'The given account is owned by a different program than expected',
  ),
  1017: (
    name: 'AccountConstraintClose',
    message: 'The expected close account is not close',
  ),
  1018: (
    name: 'AccountConstraintAddress',
    message: 'The expected address was not provided',
  ),
  1019: (
    name: 'AccountConstraintAssociated',
    message: 'The expected associated address was not provided',
  ),
  1020: (
    name: 'AccountConstraintSeeds',
    message: 'The provided seeds do not create a valid PDA',
  ),
  1021: (
    name: 'RequireEQViolated',
    message: 'A require expression was violated',
  ),
  1022: (
    name: 'RequireKeysEqViolated',
    message: 'A require keys expression was violated',
  ),
  1023: (
    name: 'RequireNeqViolated',
    message: 'A require neq expression was violated',
  ),
  1024: (
    name: 'RequireKeysNeqViolated',
    message: 'A require keys neq expression was violated',
  ),
  1025: (
    name: 'RequireGtViolated',
    message: 'A require gt expression was violated',
  ),
  1026: (
    name: 'RequireGteViolated',
    message: 'A require gte expression was violated',
  ),
  1027: (
    name: 'RequireLtViolated',
    message: 'A require lt expression was violated',
  ),
  1028: (
    name: 'RequireLteViolated',
    message: 'A require lte expression was violated',
  ),
  1029: (
    name: 'AccountDidNotDeserialize',
    message: 'The account could not be deserialized',
  ),
  1030: (
    name: 'AccountDidNotSerialize',
    message: 'The account could not be serialized',
  ),
  1031: (
    name: 'AccountNotEnoughLamports',
    message: 'The account does not have the lamports required',
  ),
  1032: (
    name: 'InstructionNotAllowed',
    message: 'The instruction is not allowed',
  ),
  1500: (
    name: 'StateInvalidAddress',
    message: 'The given state account is not in the instruction account list',
  ),
  2000: (
    name: 'DeclaredProgramIdMismatch',
    message: 'The declared program id does not match the actual program id',
  ),
  2500: (
    name: 'Deprecated',
    message: 'The API being used is deprecated',
  ),
  3000: (
    name: 'RequireEqViolated',
    message: 'A require expression was violated',
  ),
  3001: (
    name: 'RequireKeysEqViolated',
    message: 'A require keys eq expression was violated',
  ),
  3002: (
    name: 'RequireNeqViolated',
    message: 'A require neq expression was violated',
  ),
  3003: (
    name: 'RequireKeysNeqViolated',
    message: 'A require keys neq expression was violated',
  ),
  3004: (
    name: 'RequireGtViolated',
    message: 'A require gt expression was violated',
  ),
  3005: (
    name: 'RequireGteViolated',
    message: 'A require gte expression was violated',
  ),
  3006: (
    name: 'RequireLtViolated',
    message: 'A require lt expression was violated',
  ),
  3007: (
    name: 'RequireLteViolated',
    message: 'A require lte expression was violated',
  ),
  4100: (
    name: 'AccountDiscriminatorNotFound',
    message: 'No discriminator was found on the account.',
  ),
  4101: (
    name: 'AccountDiscriminatorMismatch',
    message: '8 byte discriminator did not match what was expected.',
  ),
  4102: (
    name: 'AccountDidNotDeserialize',
    message: 'Failed to deserialize the account.',
  ),
  4103: (
    name: 'AccountDidNotSerialize',
    message: 'Failed to serialize the account.',
  ),
  4104: (
    name: 'AccountNotEnoughKeys',
    message: 'Not enough account keys given to the instruction.',
  ),
  5000: (
    name: 'ArithmeticOverflow',
    message: 'Arithmetic operation overflowed.',
  ),
  5001: (
    name: 'ArithmeticUnderflow',
    message: 'Arithmetic operation underflowed.',
  ),
  5002: (
    name: 'DenominatorIsZero',
    message: 'Division by zero.',
  ),
  5003: (
    name: 'RangeOverflow',
    message: 'The provided range does not fit in an integer type.',
  ),
  5004: (
    name: 'RangeNegateOverflow',
    message: 'Negating the provided range would overflow.',
  ),
  6000: (
    name: 'PermissionDenied',
    message: 'The program id is not allowed.',
  ),
  6001: (
    name: 'InvalidArgument',
    message: 'The provided argument is invalid.',
  ),
};
