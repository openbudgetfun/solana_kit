import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_loader/src/generated/solana_loader_v3_program.dart';

/// Default number of program bytes included in each loader write instruction.
const defaultLoaderWriteChunkSize = 900;

/// Returns a sequential plan that writes [programBytes] to a buffer and then
/// deploys it through BPF Loader v3 (Upgradeable).
///
/// Prepare the buffer and program accounts first. Writes may span transactions;
/// deployment runs only after every buffer write succeeds.
InstructionPlan getDeployProgramInstructionPlan({
  required Address payerAccount,
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address authority,
  required Uint8List programBytes,
  BigInt? maxDataLen,
  int chunkSize = defaultLoaderWriteChunkSize,
  Address rentSysvar = sysvarRentAddress,
  Address clockSysvar = sysvarClockAddress,
  Address systemProgram = systemProgramAddress,
}) {
  final writes = _getWriteInstructions(
    bufferAccount: bufferAccount,
    bufferAuthority: authority,
    programBytes: programBytes,
    chunkSize: chunkSize,
  );

  return sequentialInstructionPlan([
    ...writes,
    getDeployWithMaxDataLenInstruction(
      programAddress: solanaLoaderV3ProgramProgramAddress,
      payerAccount: payerAccount,
      programDataAccount: programDataAccount,
      programAccount: programAccount,
      bufferAccount: bufferAccount,
      authority: authority,
      maxDataLen: maxDataLen ?? BigInt.from(programBytes.length),
      rentSysvar: rentSysvar,
      clockSysvar: clockSysvar,
      systemProgram: systemProgram,
    ),
  ]);
}

/// Returns a sequential plan that writes [programBytes] to a buffer and then
/// upgrades an existing BPF Loader v3 (Upgradeable) program.
///
/// Prepare the buffer account first. Writes may span transactions; the upgrade
/// runs only after every buffer write succeeds.
InstructionPlan getUpgradeProgramInstructionPlan({
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address spillAccount,
  required Address authority,
  required Uint8List programBytes,
  int chunkSize = defaultLoaderWriteChunkSize,
  Address rentSysvar = sysvarRentAddress,
  Address clockSysvar = sysvarClockAddress,
}) {
  final writes = _getWriteInstructions(
    bufferAccount: bufferAccount,
    bufferAuthority: authority,
    programBytes: programBytes,
    chunkSize: chunkSize,
  );

  return sequentialInstructionPlan([
    ...writes,
    getUpgradeInstruction(
      programAddress: solanaLoaderV3ProgramProgramAddress,
      programDataAccount: programDataAccount,
      programAccount: programAccount,
      bufferAccount: bufferAccount,
      spillAccount: spillAccount,
      authority: authority,
      rentSysvar: rentSysvar,
      clockSysvar: clockSysvar,
    ),
  ]);
}

List<Object> _getWriteInstructions({
  required Address bufferAccount,
  required Address bufferAuthority,
  required Uint8List programBytes,
  required int chunkSize,
}) {
  if (chunkSize <= 0) {
    throw ArgumentError.value(chunkSize, 'chunkSize', 'must be greater than 0');
  }

  final instructions = <Object>[];
  for (var offset = 0; offset < programBytes.length; offset += chunkSize) {
    final end = (offset + chunkSize).clamp(0, programBytes.length);
    instructions.add(
      getWriteInstruction(
        programAddress: solanaLoaderV3ProgramProgramAddress,
        bufferAccount: bufferAccount,
        bufferAuthority: bufferAuthority,
        offset: offset,
        bytes: Uint8List.fromList(programBytes.sublist(offset, end)),
      ),
    );
  }
  return instructions;
}
