// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  const programAddress = Address('11111111111111111111111111111111');

  final instruction = Instruction(
    programAddress: programAddress,
    accounts: const [
      AccountMeta(
        address: Address('11111111111111111111111111111111'),
        role: AccountRole.readonlySigner,
      ),
    ],
    data: Uint8List.fromList([1, 2, 3]),
  );

  print('Matches program: ${isInstructionForProgram(instruction, programAddress)}');
  print('Has accounts: ${isInstructionWithAccounts(instruction)}');
  print('Has data: ${isInstructionWithData(instruction)}');
}
