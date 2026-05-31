// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The address of the Solana Config program.
const solanaConfigProgramAddress = configProgramAddress;

/// Returns true when [programAddress] identifies the Solana Config program.
bool identifySolanaConfigProgram(Address programAddress) =>
    programAddress == solanaConfigProgramAddress;

/// Returns true when [instruction] targets the Solana Config program.
bool identifySolanaConfigInstruction(Instruction instruction) =>
    identifySolanaConfigProgram(instruction.programAddress);
