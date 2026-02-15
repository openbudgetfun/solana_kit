import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_instructions/src/accounts.dart';

/// An instruction destined for a given program.
class Instruction {
  /// Creates an [Instruction] with the given [programAddress], optional
  /// [accounts], and optional [data].
  const Instruction({required this.programAddress, this.accounts, this.data});

  /// The base58-encoded address of the program to invoke.
  final Address programAddress;

  /// The accounts that this instruction references.
  final List<AccountMeta>? accounts;

  /// The opaque data to pass to the program.
  final Uint8List? data;
}

/// Returns `true` if [instruction] is destined for the program at
/// [programAddress].
bool isInstructionForProgram(Instruction instruction, Address programAddress) =>
    instruction.programAddress == programAddress;

/// Asserts that [instruction] is destined for the program at
/// [programAddress].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionProgramIdMismatch] if the addresses do not
/// match.
void assertIsInstructionForProgram(
  Instruction instruction,
  Address programAddress,
) {
  if (instruction.programAddress != programAddress) {
    throw SolanaError(SolanaErrorCode.instructionProgramIdMismatch, {
      'actualProgramAddress': instruction.programAddress.value,
      'expectedProgramAddress': programAddress.value,
    });
  }
}

/// Returns `true` if [instruction] has an accounts list (even if empty).
bool isInstructionWithAccounts(Instruction instruction) =>
    instruction.accounts != null;

/// Asserts that [instruction] has an accounts list.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionExpectedToHaveAccounts] if the accounts list
/// is `null`.
void assertIsInstructionWithAccounts(Instruction instruction) {
  if (instruction.accounts == null) {
    throw SolanaError(SolanaErrorCode.instructionExpectedToHaveAccounts, {
      'data': instruction.data,
      'programAddress': instruction.programAddress.value,
    });
  }
}

/// Returns `true` if [instruction] has data (even if empty).
bool isInstructionWithData(Instruction instruction) => instruction.data != null;

/// Asserts that [instruction] has data.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionExpectedToHaveData] if data is `null`.
void assertIsInstructionWithData(Instruction instruction) {
  if (instruction.data == null) {
    throw SolanaError(SolanaErrorCode.instructionExpectedToHaveData, {
      'accountAddresses': instruction.accounts?.map((a) => a.address.value),
      'programAddress': instruction.programAddress.value,
    });
  }
}
