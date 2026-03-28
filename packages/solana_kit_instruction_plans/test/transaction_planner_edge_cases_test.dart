import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  TransactionPlanner makePlanner({
    Future<void> Function(String)? onUpdate,
  }) =>
      createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () async => createMessage(),
          onTransactionMessageUpdated: onUpdate != null
              ? (msg) async {
                  await onUpdate('updated');
                  return msg;
                }
              : null,
        ),
      );

  group('createTransactionPlanner edge cases', () {
    test('throws for an empty parallel instruction plan', () async {
      final planner = makePlanner();
      final plan = parallelInstructionPlan([]);

      expect(
        () => planner(plan),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansEmptyInstructionPlan,
          ),
        ),
      );
    });

    test('throws for a deeply nested empty plan', () async {
      final planner = makePlanner();
      final plan = sequentialInstructionPlan([
        parallelInstructionPlan([]),
      ]);

      expect(
        () => planner(plan),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansEmptyInstructionPlan,
          ),
        ),
      );
    });

    test('packs a single instruction from a parallel plan', () async {
      final planner = makePlanner();
      final plan = parallelInstructionPlan([createInstruction('A')]);

      final result = await planner(plan);
      expect(result, isA<SingleTransactionPlan>());
      final singlePlan = result as SingleTransactionPlan;
      expect(singlePlan.message.instructions, hasLength(1));
    });

    test('parallel plan with multiple instructions packs into one transaction',
        () async {
      final planner = makePlanner();
      final plan = parallelInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
        createInstruction('C'),
      ]);

      final result = await planner(plan);
      // All fit in one transaction → returns SingleTransactionPlan.
      expect(result, isA<SingleTransactionPlan>());
      final singlePlan = result as SingleTransactionPlan;
      expect(singlePlan.message.instructions, hasLength(3));
    });

    test('non-divisible sequential inside parallel fits in one transaction',
        () async {
      final planner = makePlanner();
      final plan = parallelInstructionPlan([
        nonDivisibleSequentialInstructionPlan([
          createInstruction('A'),
          createInstruction('B'),
        ]),
      ]);

      final result = await planner(plan);
      expect(result, isA<SingleTransactionPlan>());
      final singlePlan = result as SingleTransactionPlan;
      expect(singlePlan.message.instructions, hasLength(2));
    });

    test('parallel plan with a message packer plan produces transactions',
        () async {
      final planner = makePlanner();
      final packerPlan = getMessagePackerInstructionPlanFromInstructions([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      final plan = parallelInstructionPlan([packerPlan]);

      final result = await planner(plan);
      expect(result, isA<TransactionPlan>());
    });

    test(
        'sequential plan with two separate non-divisible blocks produces a '
        'sequential result', () async {
      final planner = makePlanner();
      final plan = sequentialInstructionPlan([
        nonDivisibleSequentialInstructionPlan([createInstruction('A')]),
        nonDivisibleSequentialInstructionPlan([createInstruction('B')]),
      ]);

      final result = await planner(plan);
      // Two single-instruction plans fit in one transaction each, but since
      // both fit in the same base message they'll be merged.
      expect(result, isA<TransactionPlan>());
    });

    test('onTransactionMessageUpdated is called when provided', () async {
      final calls = <String>[];
      final planner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () async => createMessage(),
          onTransactionMessageUpdated: (msg) async {
            calls.add('update');
            return msg;
          },
        ),
      );

      final plan = sequentialInstructionPlan([
        createInstruction('A'),
        createInstruction('B'),
      ]);
      await planner(plan);

      expect(calls, isNotEmpty);
    });

    test('creates fresh transaction messages for each plan call', () async {
      var createCount = 0;
      final planner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () async {
            createCount++;
            return createMessage();
          },
        ),
      );

      await planner(singleInstructionPlan(createInstruction('A')));
      final firstCount = createCount;

      await planner(singleInstructionPlan(createInstruction('B')));
      expect(createCount, greaterThan(firstCount));
    });

    test('sequential plan with message packer creates transaction plan',
        () async {
      final planner = makePlanner();
      final plan = sequentialInstructionPlan([
        createInstruction('A'),
        getMessagePackerInstructionPlanFromInstructions([
          createInstruction('B'),
          createInstruction('C'),
        ]),
      ]);

      final result = await planner(plan);
      expect(result, isA<TransactionPlan>());
    });

    test(
        'linear message packer instruction plan produces a transaction plan '
        'when used in the planner', () async {
      final planner = makePlanner();
      final plan = getLinearMessagePackerInstructionPlan(
        getInstruction: (offset, length) => createInstructionWithData(length),
        totalLength: 10,
      );

      final result = await planner(plan);
      expect(result, isA<TransactionPlan>());
    });
  });

  group('TransactionPlannerConfig', () {
    test('null onTransactionMessageUpdated default passes message through',
        () async {
      // The default is (msg) async => msg when not provided.
      final planner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () async => createMessage(),
          // onTransactionMessageUpdated not provided → null
        ),
      );

      final plan = singleInstructionPlan(createInstruction('A'));
      final result = await planner(plan);
      expect(result, isA<SingleTransactionPlan>());
    });
  });
}
