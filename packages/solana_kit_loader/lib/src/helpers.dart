import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_loader/src/generated/instructions/loader_v3.dart';

/// Default number of program bytes included in each loader write instruction.
const defaultLoaderWriteChunkSize = 900;

/// Returns a non-divisible plan that writes [programBytes] to a buffer and then
/// deploys it through BPF Loader v3 (Upgradeable).
InstructionPlan getDeployProgramInstructionPlan({
  required Address payerAccount,
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address authority,
  required Uint8List programBytes,
  BigInt? maxDataLen,
  int chunkSize = defaultLoaderWriteChunkSize,
  Address rentSysvar = rentSysvarAddress,
  Address clockSysvar = clockSysvarAddress,
  Address systemProgram = systemProgramAddress,
}) {
  final writes = _getWriteInstructions(
    bufferAccount: bufferAccount,
    bufferAuthority: authority,
    programBytes: programBytes,
    chunkSize: chunkSize,
  );

  return nonDivisibleSequentialInstructionPlan([
    ...writes,
    getDeployWithMaxProgramLenInstruction(
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

/// Returns a non-divisible plan that writes [programBytes] to a buffer and then
/// upgrades an existing BPF Loader v3 (Upgradeable) program.
InstructionPlan getUpgradeProgramInstructionPlan({
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address spillAccount,
  required Address authority,
  required Uint8List programBytes,
  int chunkSize = defaultLoaderWriteChunkSize,
  Address rentSysvar = rentSysvarAddress,
  Address clockSysvar = clockSysvarAddress,
}) {
  final writes = _getWriteInstructions(
    bufferAccount: bufferAccount,
    bufferAuthority: authority,
    programBytes: programBytes,
    chunkSize: chunkSize,
  );

  return nonDivisibleSequentialInstructionPlan([
    ...writes,
    getUpgradeInstruction(
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
      getLoaderV3WriteInstruction(
        bufferAccount: bufferAccount,
        bufferAuthority: bufferAuthority,
        offset: offset,
        bytes: Uint8List.fromList(programBytes.sublist(offset, end)),
      ),
    );
  }
  return instructions;
}
