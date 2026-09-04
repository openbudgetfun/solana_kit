import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('message packing preserves every instruction', () {
    test('keeps the overflowing instruction for the next message', () {
      final instructions = [
        createInstructionWithData(800),
        createInstructionWithData(800),
      ];
      final packer = getMessagePackerInstructionPlanFromInstructions(
        instructions,
      ).getMessagePacker();

      final first = packer.packMessageToCapacity(createMessage());
      final second = packer.packMessageToCapacity(createMessage());

      expect(first.instructions, [instructions.first]);
      expect(second.instructions, [instructions.last]);
      expect(packer.done(), isTrue);
      for (final message in [first, second]) {
        expect(
          getTransactionMessageSize(message),
          lessThanOrEqualTo(getTransactionMessageSizeLimit(message)),
        );
      }
    });

    test(
      'does not silently omit an instruction from a rejected candidate',
      () async {
        final initial = createInstructionWithData(800);
        final guard = createInstructionWithData(100);
        final action = createInstructionWithData(800);
        final planner = createTransactionPlanner(
          TransactionPlannerConfig(
            createTransactionMessage: () async => createMessage(),
          ),
        );

        final result = await planner(
          sequentialInstructionPlan([
            initial,
            getMessagePackerInstructionPlanFromInstructions([guard, action]),
          ]),
        );
        final messages = flattenTransactionPlan(
          result,
        ).map((plan) => plan.message).toList();

        expect(
          messages.expand((message) => message.instructions),
          [initial, guard, action],
        );
        for (final message in messages) {
          expect(
            getTransactionMessageSize(message),
            lessThanOrEqualTo(getTransactionMessageSizeLimit(message)),
          );
        }
      },
    );

    for (final overflow in ['bytes', 'instructions', 'callback']) {
      test(
        'rejects a $overflow overflow after consuming packed instructions',
        () async {
          final initial = createInstructionWithData(800);
          final guard = createInstructionWithData(100);
          final action = createInstructionWithData(
            overflow == 'bytes' ? 800 : 100,
          );
          var updates = 0;
          final planner = createTransactionPlanner(
            TransactionPlannerConfig(
              createTransactionMessage: () async => createMessage(),
              maxInstructionsPerTransaction: overflow == 'bytes' ? 3 : 2,
              onTransactionMessageUpdated: (message) async {
                updates++;
                if (updates != 2) return message;
                if (overflow == 'callback') {
                  throw SolanaError(
                    SolanaErrorCode.transactionTooManyInstructions,
                  );
                }
                return appendTransactionMessageInstruction(
                  createInstructionWithData(overflow == 'bytes' ? 800 : 0),
                  message,
                );
              },
            ),
          );

          await expectLater(
            planner(
              sequentialInstructionPlan([
                initial,
                getMessagePackerInstructionPlanFromInstructions([
                  guard,
                  action,
                ]),
              ]),
            ),
            throwsA(
              isA<SolanaError>().having(
                (error) => error.code,
                'code',
                switch (overflow) {
                  'bytes' =>
                    SolanaErrorCode
                        .instructionPlansMessageCannotAccommodatePlan,
                  'instructions' =>
                    SolanaErrorCode
                        .instructionPlansMaxInstructionsPerTransactionExceeded,
                  _ => SolanaErrorCode.transactionTooManyInstructions,
                },
              ),
            ),
          );
        },
      );
    }
  });
}
