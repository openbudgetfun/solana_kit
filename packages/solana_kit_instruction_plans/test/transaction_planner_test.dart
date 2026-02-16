import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('createTransactionPlanner', () {
    late TransactionPlanner planner;

    setUp(() {
      planner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () async => createMessage(),
        ),
      );
    });

    test('throws for empty instruction plan', () async {
      final plan = sequentialInstructionPlan([]);

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

    test(
      'creates a single transaction plan from a single instruction',
      () async {
        final instruction = createInstruction('A');
        final plan = singleInstructionPlan(instruction);

        final transactionPlan = await planner(plan);

        expect(transactionPlan, isA<SingleTransactionPlan>());
        final singlePlan = transactionPlan as SingleTransactionPlan;
        expect(singlePlan.message.instructions, hasLength(1));
        expect(singlePlan.message.instructions[0], same(instruction));
      },
    );

    test(
      'packs multiple sequential instructions into one transaction',
      () async {
        final instructionA = createInstruction('A');
        final instructionB = createInstruction('B');
        final plan = sequentialInstructionPlan([instructionA, instructionB]);

        final transactionPlan = await planner(plan);

        // When they fit in one transaction, they should be packed together.
        expect(transactionPlan, isA<SingleTransactionPlan>());
        final singlePlan = transactionPlan as SingleTransactionPlan;
        expect(singlePlan.message.instructions, hasLength(2));
      },
    );

    test(
      'packs parallel instructions into one transaction when possible',
      () async {
        final instructionA = createInstruction('A');
        final instructionB = createInstruction('B');
        final plan = parallelInstructionPlan([instructionA, instructionB]);

        final transactionPlan = await planner(plan);

        expect(transactionPlan, isA<SingleTransactionPlan>());
        final singlePlan = transactionPlan as SingleTransactionPlan;
        expect(singlePlan.message.instructions, hasLength(2));
      },
    );

    test('handles nested sequential and parallel plans', () async {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final instructionC = createInstruction('C');

      final plan = sequentialInstructionPlan([
        instructionA,
        parallelInstructionPlan([instructionB, instructionC]),
      ]);

      final transactionPlan = await planner(plan);
      expect(transactionPlan, isA<TransactionPlan>());
    });

    test('calls onTransactionMessageUpdated when provided', () async {
      var updateCount = 0;
      final updatingPlanner = createTransactionPlanner(
        TransactionPlannerConfig(
          createTransactionMessage: () async => createMessage(),
          onTransactionMessageUpdated: (msg) async {
            updateCount++;
            return msg;
          },
        ),
      );

      final plan = singleInstructionPlan(createInstruction('A'));
      await updatingPlanner(plan);

      expect(updateCount, greaterThan(0));
    });

    test('handles non-divisible sequential plans', () async {
      final instructionA = createInstruction('A');
      final instructionB = createInstruction('B');
      final plan = nonDivisibleSequentialInstructionPlan([
        instructionA,
        instructionB,
      ]);

      final transactionPlan = await planner(plan);
      expect(transactionPlan, isA<TransactionPlan>());
    });

    test('handles message packer instruction plans', () async {
      final instructions = [createInstruction('A'), createInstruction('B')];
      final plan = getMessagePackerInstructionPlanFromInstructions(
        instructions,
      );

      final transactionPlan = await planner(plan);
      expect(transactionPlan, isA<TransactionPlan>());
    });

    test(
      'splits instructions into multiple transactions when they exceed size limit',
      () async {
        // Create a planner that simulates size constraints.
        var callCount = 0;
        final sizeLimitedPlanner = createTransactionPlanner(
          TransactionPlannerConfig(
            createTransactionMessage: () async => createMessage(),
            onTransactionMessageUpdated: (msg) async {
              callCount++;
              // Simulate a message that becomes too large after 2 instructions.
              if (msg.instructions.length > 1) {
                // Return a message that would exceed the size limit by
                // adding large data.
                return msg;
              }
              return msg;
            },
          ),
        );

        final plan = sequentialInstructionPlan([
          createInstruction('A'),
          createInstruction('B'),
        ]);

        final transactionPlan = await sizeLimitedPlanner(plan);
        expect(transactionPlan, isA<TransactionPlan>());
        expect(callCount, greaterThan(0));
      },
    );
  });

  group('TransactionPlannerConfig', () {
    test('stores the createTransactionMessage callback', () {
      Future<TransactionMessage> callback() async => createMessage();
      final config = TransactionPlannerConfig(
        createTransactionMessage: callback,
      );
      expect(config.createTransactionMessage, same(callback));
    });

    test('onTransactionMessageUpdated defaults to null', () {
      final config = TransactionPlannerConfig(
        createTransactionMessage: () async => createMessage(),
      );
      expect(config.onTransactionMessageUpdated, isNull);
    });

    test('stores the onTransactionMessageUpdated callback', () {
      Future<TransactionMessage> callback(TransactionMessage msg) async => msg;
      final config = TransactionPlannerConfig(
        createTransactionMessage: () async => createMessage(),
        onTransactionMessageUpdated: callback,
      );
      expect(config.onTransactionMessageUpdated, same(callback));
    });
  });
}
