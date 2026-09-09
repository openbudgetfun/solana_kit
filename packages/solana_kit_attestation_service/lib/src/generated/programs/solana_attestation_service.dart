// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

/// The address of the SolanaAttestationService program.
const solanaAttestationServiceProgramAddress = Address(
  '22zoJMtdu4tQc2PzL74ZUT7FrwgB1Udec8DdW4yw4BdG',
);

/// Known accounts for the SolanaAttestationService program.
enum SolanaAttestationServiceAccount { attestation, credential, schema }

/// Known instructions for the SolanaAttestationService program.
enum SolanaAttestationServiceInstruction {
  createCredential,
  createSchema,
  changeSchemaStatus,
  changeAuthorizedSigners,
  changeSchemaDescription,
  changeSchemaVersion,
  createAttestation,
  closeAttestation,
  tokenizeSchema,
  createTokenizedAttestation,
  closeTokenizedAttestation,
  emitEvent,
}

/// Identifies the type of a SolanaAttestationService instruction.
SolanaAttestationServiceInstruction identifySolanaAttestationServiceInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return SolanaAttestationServiceInstruction.createCredential;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return SolanaAttestationServiceInstruction.createSchema;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return SolanaAttestationServiceInstruction.changeSchemaStatus;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return SolanaAttestationServiceInstruction.changeAuthorizedSigners;
  }
  if (containsBytes(data, getU8Encoder().encode(4), 0)) {
    return SolanaAttestationServiceInstruction.changeSchemaDescription;
  }
  if (containsBytes(data, getU8Encoder().encode(5), 0)) {
    return SolanaAttestationServiceInstruction.changeSchemaVersion;
  }
  if (containsBytes(data, getU8Encoder().encode(6), 0)) {
    return SolanaAttestationServiceInstruction.createAttestation;
  }
  if (containsBytes(data, getU8Encoder().encode(7), 0)) {
    return SolanaAttestationServiceInstruction.closeAttestation;
  }
  if (containsBytes(data, getU8Encoder().encode(9), 0)) {
    return SolanaAttestationServiceInstruction.tokenizeSchema;
  }
  if (containsBytes(data, getU8Encoder().encode(10), 0)) {
    return SolanaAttestationServiceInstruction.createTokenizedAttestation;
  }
  if (containsBytes(data, getU8Encoder().encode(11), 0)) {
    return SolanaAttestationServiceInstruction.closeTokenizedAttestation;
  }
  if (containsBytes(data, getU8Encoder().encode(228), 0)) {
    return SolanaAttestationServiceInstruction.emitEvent;
  }

  throw SolanaError(SolanaErrorCode.programClientsFailedToIdentifyInstruction, {
    'instructionData': data,
    'programName': 'solanaAttestationService',
  });
}

/// A parsed instruction from the SolanaAttestationService program.
sealed class ParsedSolanaAttestationServiceInstruction {
  const ParsedSolanaAttestationServiceInstruction(this.instructionType);

  final SolanaAttestationServiceInstruction instructionType;
}

/// A parsed CreateCredential instruction.
final class ParsedCreateCredential
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedCreateCredential({required this.data})
    : super(SolanaAttestationServiceInstruction.createCredential);

  final CreateCredentialInstructionData data;
}

/// A parsed CreateSchema instruction.
final class ParsedCreateSchema
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedCreateSchema({required this.data})
    : super(SolanaAttestationServiceInstruction.createSchema);

  final CreateSchemaInstructionData data;
}

/// A parsed ChangeSchemaStatus instruction.
final class ParsedChangeSchemaStatus
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedChangeSchemaStatus({required this.data})
    : super(SolanaAttestationServiceInstruction.changeSchemaStatus);

  final ChangeSchemaStatusInstructionData data;
}

/// A parsed ChangeAuthorizedSigners instruction.
final class ParsedChangeAuthorizedSigners
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedChangeAuthorizedSigners({required this.data})
    : super(SolanaAttestationServiceInstruction.changeAuthorizedSigners);

  final ChangeAuthorizedSignersInstructionData data;
}

/// A parsed ChangeSchemaDescription instruction.
final class ParsedChangeSchemaDescription
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedChangeSchemaDescription({required this.data})
    : super(SolanaAttestationServiceInstruction.changeSchemaDescription);

  final ChangeSchemaDescriptionInstructionData data;
}

/// A parsed ChangeSchemaVersion instruction.
final class ParsedChangeSchemaVersion
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedChangeSchemaVersion({required this.data})
    : super(SolanaAttestationServiceInstruction.changeSchemaVersion);

  final ChangeSchemaVersionInstructionData data;
}

/// A parsed CreateAttestation instruction.
final class ParsedCreateAttestation
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedCreateAttestation({required this.data})
    : super(SolanaAttestationServiceInstruction.createAttestation);

  final CreateAttestationInstructionData data;
}

/// A parsed CloseAttestation instruction.
final class ParsedCloseAttestation
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedCloseAttestation({required this.data})
    : super(SolanaAttestationServiceInstruction.closeAttestation);

  final CloseAttestationInstructionData data;
}

/// A parsed TokenizeSchema instruction.
final class ParsedTokenizeSchema
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedTokenizeSchema({required this.data})
    : super(SolanaAttestationServiceInstruction.tokenizeSchema);

  final TokenizeSchemaInstructionData data;
}

/// A parsed CreateTokenizedAttestation instruction.
final class ParsedCreateTokenizedAttestation
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedCreateTokenizedAttestation({required this.data})
    : super(SolanaAttestationServiceInstruction.createTokenizedAttestation);

  final CreateTokenizedAttestationInstructionData data;
}

/// A parsed CloseTokenizedAttestation instruction.
final class ParsedCloseTokenizedAttestation
    extends ParsedSolanaAttestationServiceInstruction {
  const ParsedCloseTokenizedAttestation({required this.data})
    : super(SolanaAttestationServiceInstruction.closeTokenizedAttestation);

  final CloseTokenizedAttestationInstructionData data;
}

/// A parsed EmitEvent instruction.
final class ParsedEmitEvent extends ParsedSolanaAttestationServiceInstruction {
  const ParsedEmitEvent({required this.data})
    : super(SolanaAttestationServiceInstruction.emitEvent);

  final EmitEventInstructionData data;
}

/// Parses a SolanaAttestationService instruction.
ParsedSolanaAttestationServiceInstruction
parseSolanaAttestationServiceInstruction(Instruction instruction) {
  return switch (identifySolanaAttestationServiceInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    SolanaAttestationServiceInstruction.createCredential =>
      ParsedCreateCredential(
        data: parseCreateCredentialInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.createSchema => ParsedCreateSchema(
      data: parseCreateSchemaInstruction(instruction),
    ),
    SolanaAttestationServiceInstruction.changeSchemaStatus =>
      ParsedChangeSchemaStatus(
        data: parseChangeSchemaStatusInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.changeAuthorizedSigners =>
      ParsedChangeAuthorizedSigners(
        data: parseChangeAuthorizedSignersInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.changeSchemaDescription =>
      ParsedChangeSchemaDescription(
        data: parseChangeSchemaDescriptionInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.changeSchemaVersion =>
      ParsedChangeSchemaVersion(
        data: parseChangeSchemaVersionInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.createAttestation =>
      ParsedCreateAttestation(
        data: parseCreateAttestationInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.closeAttestation =>
      ParsedCloseAttestation(
        data: parseCloseAttestationInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.tokenizeSchema => ParsedTokenizeSchema(
      data: parseTokenizeSchemaInstruction(instruction),
    ),
    SolanaAttestationServiceInstruction.createTokenizedAttestation =>
      ParsedCreateTokenizedAttestation(
        data: parseCreateTokenizedAttestationInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.closeTokenizedAttestation =>
      ParsedCloseTokenizedAttestation(
        data: parseCloseTokenizedAttestationInstruction(instruction),
      ),
    SolanaAttestationServiceInstruction.emitEvent => ParsedEmitEvent(
      data: parseEmitEventInstruction(instruction),
    ),
  };
}
