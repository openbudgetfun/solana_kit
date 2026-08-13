import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('max-instructions', () {
    group('resolveMaxInstructions', () {
      test('falls back to the default when null', () {
        expect(
          resolveMaxInstructions(null),
          defaultMaxInstructionsPerTransaction,
        );
        expect(defaultMaxInstructionsPerTransaction, 16);
      });

      test('returns the provided value when given', () {
        expect(resolveMaxInstructions(5), 5);
      });
    });

    group('assertValidMaxInstructionsPerTransaction', () {
      test('accepts null', () {
        expect(
          () => assertValidMaxInstructionsPerTransaction(null),
          returnsNormally,
        );
      });

      test('accepts positive integers up to the transaction limit', () {
        expect(
          () => assertValidMaxInstructionsPerTransaction(1),
          returnsNormally,
        );
        expect(
          () => assertValidMaxInstructionsPerTransaction(
            transactionInstructionLimit,
          ),
          returnsNormally,
        );
      });

      test('rejects zero', () {
        expect(
          () => assertValidMaxInstructionsPerTransaction(0),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .instructionPlansInvalidMaxInstructionsPerTransaction,
            ),
          ),
        );
      });

      test('rejects negative values', () {
        expect(
          () => assertValidMaxInstructionsPerTransaction(-1),
          throwsA(isA<SolanaError>()),
        );
      });

      test('rejects values greater than the transaction limit', () {
        expect(
          () => assertValidMaxInstructionsPerTransaction(
            transactionInstructionLimit + 1,
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .instructionPlansInvalidMaxInstructionsPerTransaction,
            ),
          ),
        );
      });
    });

    group('assertMaxInstructionsPerTransaction', () {
      test('passes when within the limit', () {
        expect(
          () => assertMaxInstructionsPerTransaction(3, 5),
          returnsNormally,
        );
      });

      test('throws when exceeding the limit', () {
        expect(
          () => assertMaxInstructionsPerTransaction(6, 5),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .instructionPlansMaxInstructionsPerTransactionExceeded,
            ),
          ),
        );
      });
    });

    group('MessagePacker.packMessageToCapacity maxInstructions', () {
      test(
        'splits instructions across messages when exceeding maxInstructions',
        () {
          // 5 instructions, maxInstructions of 2 → first pack holds 2.
          final plan = getMessagePackerInstructionPlanFromInstructions([
            createInstruction('A'),
            createInstruction('B'),
            createInstruction('C'),
            createInstruction('D'),
            createInstruction('E'),
          ]);
          final messagePacker = plan.getMessagePacker();

          final first = messagePacker.packMessageToCapacity(
            createMessage(),
            maxInstructions: 2,
          );
          expect(first.instructions, hasLength(2));
          expect(messagePacker.done(), isFalse);

          final second = messagePacker.packMessageToCapacity(
            createMessage(),
            maxInstructions: 2,
          );
          expect(second.instructions, hasLength(2));
          expect(messagePacker.done(), isFalse);

          final third = messagePacker.packMessageToCapacity(
            createMessage(),
            maxInstructions: 2,
          );
          expect(third.instructions, hasLength(1));
          expect(messagePacker.done(), isTrue);
        },
      );

      test('rejects an invalid maxInstructions value', () {
        final plan = getMessagePackerInstructionPlanFromInstructions([
          createInstruction('A'),
        ]);
        expect(
          () => plan.getMessagePacker().packMessageToCapacity(
            createMessage(),
            maxInstructions: 0,
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .instructionPlansInvalidMaxInstructionsPerTransaction,
            ),
          ),
        );
      });

      test('throws when the base message already exceeds the limit', () {
        // A message already holding `maxInstructions` instructions cannot accept
        // the base instruction (length + 1 > maxInstructions).
        final plan = getMessagePackerInstructionPlanFromInstructions([
          createInstruction('A'),
        ]);
        final fullMessage = createMessage().copyWith(
          instructions: [
            for (var i = 0; i < 2; i++) createInstruction(),
          ],
        );
        expect(
          () => plan.getMessagePacker().packMessageToCapacity(
            fullMessage,
            maxInstructions: 2,
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .instructionPlansMaxInstructionsPerTransactionExceeded,
            ),
          ),
        );
      });
    });

    group('createTransactionPlanner maxInstructionsPerTransaction', () {
      Future<TransactionMessage> Function() messageFactoryWith(
        int instructionCount,
      ) {
        return () async => createMessage().copyWith(
          instructions: [
            for (var i = 0; i < instructionCount; i++) createInstruction(),
          ],
        );
      }

      test('rejects an invalid configured maximum up front', () {
        expect(
          () => createTransactionPlanner(
            TransactionPlannerConfig(
              createTransactionMessage: () async => createMessage(),
              maxInstructionsPerTransaction: 0,
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .instructionPlansInvalidMaxInstructionsPerTransaction,
            ),
          ),
        );
      });

      test(
        'splits a plan when createTransactionMessage already exceeds the limit',
        () {
          // Each new message starts with 3 instructions; with a limit of 4 the
          // planner cannot add another instruction to a fresh message and must
          // throw the exceeded error (3 + 1 == 4 is allowed; here we use a limit
          // of 3 so 3 + 1 > 3).
          final planner = createTransactionPlanner(
            TransactionPlannerConfig(
              createTransactionMessage: messageFactoryWith(3),
              maxInstructionsPerTransaction: 3,
            ),
          );
          expect(
            () => planner(singleInstructionPlan(createInstruction())),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .instructionPlansMaxInstructionsPerTransactionExceeded,
              ),
            ),
          );
        },
      );

      test('plans within the configured limit', () {
        // A fresh empty message with a single instruction fits within 16.
        final planner = createTransactionPlanner(
          TransactionPlannerConfig(
            createTransactionMessage: () async => createMessage(),
            maxInstructionsPerTransaction: 16,
          ),
        );
        final plan = planner(
          sequentialInstructionPlan([
            for (var i = 0; i < 4; i++) createInstruction(),
          ]),
        );
        expect(plan, completion(isA<SingleTransactionPlan>()));
      });
    });
  });
}
