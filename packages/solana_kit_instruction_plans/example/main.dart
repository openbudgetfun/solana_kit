// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  const instructionA = Instruction(
    programAddress: Address('11111111111111111111111111111111'),
  );
  const instructionB = Instruction(
    programAddress: Address('11111111111111111111111111111111'),
  );

  final plan = sequentialInstructionPlan([
    singleInstructionPlan(instructionA),
    parallelInstructionPlan([instructionB]),
  ]);

  print('Instruction plan kind: ${plan.kind}');
  print('Instruction plan steps: ${plan.plans.length}');
}
