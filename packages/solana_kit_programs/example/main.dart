// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

void main() {
  const programAddress = Address('11111111111111111111111111111111');
  const message = TransactionMessageInput(
    instructions: {
      0: InstructionInput(programAddress: programAddress),
    },
  );

  final error = SolanaError(
    SolanaErrorCode.instructionErrorCustom,
    {'index': 0, 'code': 6000},
  );

  final isForProgram = isProgramError(error, message, programAddress);
  print('Program error detected: $isForProgram');
}
