

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';


// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the SecurityFixture program.
const securityFixtureProgramAddress = systemProgramAddress;

/// Known accounts for the SecurityFixture program.
enum SecurityFixtureAccount {
  secureState,
  exactState,
}

/// Known instructions for the SecurityFixture program.
enum SecurityFixtureInstruction {
  secureAction,
  legacyOptionalAction,
  exactAction,
}

/// Identifies the type of a SecurityFixture instruction.
SecurityFixtureInstruction identifySecurityFixtureInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(9), 0) && containsBytes(data, getU8Encoder().encode(9), 0) && data.length == 3) {
    return SecurityFixtureInstruction.secureAction;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'securityFixture',
    },
  );
}

/// A parsed instruction from the SecurityFixture program.
sealed class ParsedSecurityFixtureInstruction {
  const ParsedSecurityFixtureInstruction(this.instructionType);

  final SecurityFixtureInstruction instructionType;
}

/// A parsed SecureAction instruction.
final class ParsedSecureAction extends ParsedSecurityFixtureInstruction {
  const ParsedSecureAction({required this.data})
      : super(SecurityFixtureInstruction.secureAction);

  final SecureActionInstructionData data;
}

/// A parsed LegacyOptionalAction instruction.
final class ParsedLegacyOptionalAction extends ParsedSecurityFixtureInstruction {
  const ParsedLegacyOptionalAction({required this.data})
      : super(SecurityFixtureInstruction.legacyOptionalAction);

  final LegacyOptionalActionInstructionData data;
}

/// A parsed ExactAction instruction.
final class ParsedExactAction extends ParsedSecurityFixtureInstruction {
  const ParsedExactAction({required this.data})
      : super(SecurityFixtureInstruction.exactAction);

  final ExactActionInstructionData data;
}

/// Parses a SecurityFixture instruction.
ParsedSecurityFixtureInstruction parseSecurityFixtureInstruction(
  Instruction instruction,
) {
  return switch (identifySecurityFixtureInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    SecurityFixtureInstruction.secureAction => ParsedSecureAction(
      data: parseSecureActionInstruction(instruction),
    ),
    SecurityFixtureInstruction.legacyOptionalAction => ParsedLegacyOptionalAction(
      data: parseLegacyOptionalActionInstruction(instruction),
    ),
    SecurityFixtureInstruction.exactAction => ParsedExactAction(
      data: parseExactActionInstruction(instruction),
    ),
  };
}
