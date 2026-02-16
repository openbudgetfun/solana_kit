import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('appendTransactionMessageInstructionPlan', () {
    test('appends a single instruction to a message', () {
      final instruction = createInstruction('A');
      final plan = singleInstructionPlan(instruction);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(1));
      expect(result.instructions[0], same(instruction));
    });

    test('appends instructions from a sequential plan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = sequentialInstructionPlan([instructionA, instructionB]);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(2));
      expect(result.instructions[0], same(instructionA));
      expect(result.instructions[1], same(instructionB));
    });

    test('appends instructions from a parallel plan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = parallelInstructionPlan([instructionA, instructionB]);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(2));
    });

    test('appends instructions from a nested plan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final plan = sequentialInstructionPlan([
        instructionA,
        parallelInstructionPlan([instructionB, instructionC]),
      ]);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(3));
    });

    test('appends instructions from a non-divisible sequential plan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = nonDivisibleSequentialInstructionPlan([
        instructionA,
        instructionB,
      ]);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(2));
    });

    test('handles a message packer instruction plan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = getMessagePackerInstructionPlanFromInstructions([
        instructionA,
        instructionB,
      ]);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(2));
    });

    test('preserves existing instructions on the message', () {
      final existingInstruction = createInstruction('existing');
      final newInstruction = createInstruction('new');
      final plan = singleInstructionPlan(newInstruction);
      final message = createMessage().copyWith(
        instructions: [existingInstruction],
      );

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(2));
      expect(result.instructions[0], same(existingInstruction));
      expect(result.instructions[1], same(newInstruction));
    });

    test('handles deeply nested plans', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final instructionD = createInstruction('D');
      final plan = sequentialInstructionPlan([
        parallelInstructionPlan([
          sequentialInstructionPlan([instructionA, instructionB]),
          instructionC,
        ]),
        instructionD,
      ]);
      final message = createMessage();

      final result = appendTransactionMessageInstructionPlan(plan, message);

      expect(result.instructions, hasLength(4));
    });
  });
}
