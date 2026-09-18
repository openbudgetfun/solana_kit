// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the AssociatedToken program.

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show associatedTokenProgramAddress;

/// Known instructions for the AssociatedToken program.
enum AssociatedTokenInstruction {
  createAssociatedToken,
  createAssociatedTokenIdempotent,
  recoverNestedAssociatedToken,
}

/// Identifies the type of a AssociatedToken instruction.
AssociatedTokenInstruction identifyAssociatedTokenInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return AssociatedTokenInstruction.createAssociatedToken;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return AssociatedTokenInstruction.createAssociatedTokenIdempotent;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return AssociatedTokenInstruction.recoverNestedAssociatedToken;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'associatedToken',
    },
  );
}

/// A parsed instruction from the AssociatedToken program.
sealed class ParsedAssociatedTokenInstruction {
  const ParsedAssociatedTokenInstruction(this.instructionType);

  final AssociatedTokenInstruction instructionType;
}

/// A parsed CreateAssociatedToken instruction.
final class ParsedCreateAssociatedToken
    extends ParsedAssociatedTokenInstruction {
  const ParsedCreateAssociatedToken({required this.data})
    : super(AssociatedTokenInstruction.createAssociatedToken);

  final CreateAssociatedTokenInstructionData data;
}

/// A parsed CreateAssociatedTokenIdempotent instruction.
final class ParsedCreateAssociatedTokenIdempotent
    extends ParsedAssociatedTokenInstruction {
  const ParsedCreateAssociatedTokenIdempotent({required this.data})
    : super(AssociatedTokenInstruction.createAssociatedTokenIdempotent);

  final CreateAssociatedTokenIdempotentInstructionData data;
}

/// A parsed RecoverNestedAssociatedToken instruction.
final class ParsedRecoverNestedAssociatedToken
    extends ParsedAssociatedTokenInstruction {
  const ParsedRecoverNestedAssociatedToken({required this.data})
    : super(AssociatedTokenInstruction.recoverNestedAssociatedToken);

  final RecoverNestedAssociatedTokenInstructionData data;
}

/// Parses a AssociatedToken instruction.
ParsedAssociatedTokenInstruction parseAssociatedTokenInstruction(
  Instruction instruction,
) {
  return switch (identifyAssociatedTokenInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    AssociatedTokenInstruction.createAssociatedToken =>
      ParsedCreateAssociatedToken(
        data: parseCreateAssociatedTokenInstruction(instruction),
      ),
    AssociatedTokenInstruction.createAssociatedTokenIdempotent =>
      ParsedCreateAssociatedTokenIdempotent(
        data: parseCreateAssociatedTokenIdempotentInstruction(instruction),
      ),
    AssociatedTokenInstruction.recoverNestedAssociatedToken =>
      ParsedRecoverNestedAssociatedToken(
        data: parseRecoverNestedAssociatedTokenInstruction(instruction),
      ),
  };
}
