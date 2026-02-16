import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('parseInstructionPlanInput', () {
    test('wraps a single Instruction in a SingleInstructionPlan', () {
      final instruction = createInstruction('A');
      final result = parseInstructionPlanInput(instruction);

      expect(result, isA<SingleInstructionPlan>());
      expect((result as SingleInstructionPlan).instruction, same(instruction));
    });

    test('returns an existing InstructionPlan as-is', () {
      final plan = singleInstructionPlan(createInstruction('A'));
      final result = parseInstructionPlanInput(plan);

      expect(result, same(plan));
    });

    test('unwraps a single-element list', () {
      final instruction = createInstruction('A');
      final result = parseInstructionPlanInput([instruction]);

      expect(result, isA<SingleInstructionPlan>());
    });

    test('wraps a multi-element list in a SequentialInstructionPlan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final result = parseInstructionPlanInput([instructionA, instructionB]);

      expect(result, isA<SequentialInstructionPlan>());
      final seqPlan = result as SequentialInstructionPlan;
      expect(seqPlan.plans, hasLength(2));
      expect(seqPlan.divisible, isTrue);
    });

    test('handles nested lists', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');
      final result = parseInstructionPlanInput([
        instructionA,
        [instructionB, instructionC],
      ]);

      expect(result, isA<SequentialInstructionPlan>());
      final seqPlan = result as SequentialInstructionPlan;
      expect(seqPlan.plans, hasLength(2));
      expect(seqPlan.plans[0], isA<SingleInstructionPlan>());
      expect(seqPlan.plans[1], isA<SequentialInstructionPlan>());
    });

    test('handles a list with an existing InstructionPlan', () {
      final instruction = createInstruction('A');
      final existingPlan = parallelInstructionPlan([createInstruction('B')]);
      final result = parseInstructionPlanInput([instruction, existingPlan]);

      expect(result, isA<SequentialInstructionPlan>());
      final seqPlan = result as SequentialInstructionPlan;
      expect(seqPlan.plans, hasLength(2));
      expect(seqPlan.plans[0], isA<SingleInstructionPlan>());
      expect(seqPlan.plans[1], isA<ParallelInstructionPlan>());
    });
  });

  group('parseTransactionPlanInput', () {
    test('wraps a single TransactionMessage in a SingleTransactionPlan', () {
      final message = createMessage();
      final result = parseTransactionPlanInput(message);

      expect(result, isA<SingleTransactionPlan>());
      expect((result as SingleTransactionPlan).message, same(message));
    });

    test('returns an existing TransactionPlan as-is', () {
      final plan = singleTransactionPlan(createMessage());
      final result = parseTransactionPlanInput(plan);

      expect(result, same(plan));
    });

    test('unwraps a single-element list', () {
      final message = createMessage();
      final result = parseTransactionPlanInput([message]);

      expect(result, isA<SingleTransactionPlan>());
    });

    test('wraps a multi-element list in a SequentialTransactionPlan', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final result = parseTransactionPlanInput([messageA, messageB]);

      expect(result, isA<SequentialTransactionPlan>());
      final seqPlan = result as SequentialTransactionPlan;
      expect(seqPlan.plans, hasLength(2));
      expect(seqPlan.divisible, isTrue);
    });

    test('handles a list with existing TransactionPlans', () {
      final message = createMessage();
      final existingPlan = parallelTransactionPlan([createMessage()]);
      final result = parseTransactionPlanInput([message, existingPlan]);

      expect(result, isA<SequentialTransactionPlan>());
      final seqPlan = result as SequentialTransactionPlan;
      expect(seqPlan.plans, hasLength(2));
      expect(seqPlan.plans[0], isA<SingleTransactionPlan>());
      expect(seqPlan.plans[1], isA<ParallelTransactionPlan>());
    });
  });

  group('parseInstructionOrTransactionPlanInput', () {
    test('parses an Instruction as an InstructionPlan', () {
      final instruction = createInstruction('A');
      final result = parseInstructionOrTransactionPlanInput(instruction);

      expect(result, isA<InstructionPlan>());
      expect(result, isA<SingleInstructionPlan>());
    });

    test('parses a TransactionPlan as a TransactionPlan', () {
      final plan = singleTransactionPlan(createMessage());
      final result = parseInstructionOrTransactionPlanInput(plan);

      expect(result, isA<TransactionPlan>());
      expect(result, same(plan));
    });

    test('parses a TransactionMessage as a TransactionPlan', () {
      final message = createMessage();
      final result = parseInstructionOrTransactionPlanInput(message);

      expect(result, isA<TransactionPlan>());
      expect(result, isA<SingleTransactionPlan>());
    });

    test('parses a list of Instructions as an InstructionPlan', () {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final result = parseInstructionOrTransactionPlanInput([
        instructionA,
        instructionB,
      ]);

      expect(result, isA<InstructionPlan>());
      expect(result, isA<SequentialInstructionPlan>());
    });

    test('parses a list of TransactionMessages as a TransactionPlan', () {
      final messageA = createMessage();
      final messageB = createMessage();
      final result = parseInstructionOrTransactionPlanInput([
        messageA,
        messageB,
      ]);

      expect(result, isA<TransactionPlan>());
    });

    test('handles an empty list as TransactionPlan', () {
      final result = parseInstructionOrTransactionPlanInput(<Object>[]);
      expect(result, isA<TransactionPlan>());
    });
  });
}
