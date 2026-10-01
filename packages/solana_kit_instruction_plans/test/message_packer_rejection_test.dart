import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

/// Builds a packer plan that appends [instructions] one message at a time,
/// refusing any message for which [rejectReason] returns a reason.
MessagePackerInstructionPlan createRejectingMessagePackerInstructionPlan(
  List<Instruction> instructions,
  String? Function(TransactionMessage message) rejectReason,
) {
  var index = 0;
  return MessagePackerInstructionPlan(
    getMessagePacker: () => MessagePacker(
      done: () => index >= instructions.length,
      packMessageToCapacity: (message, {maxInstructions}) {
        final reason = rejectReason(message);
        if (reason != null) {
          throw SolanaError(
            SolanaErrorCode.instructionPlansMessageRejectedByPacker,
            {'reason': reason},
          );
        }
        return appendTransactionMessageInstruction(
          instructions[index++],
          message,
        );
      },
    ),
  );
}

/// Rejects any message that already holds instructions.
String? rejectNonEmptyMessages(TransactionMessage message) =>
    message.instructions.isEmpty ? null : 'message already has instructions';

void main() {
  late TransactionPlanner planner;

  setUp(() {
    planner = createTransactionPlanner(
      TransactionPlannerConfig(
        createTransactionMessage: () async => createMessage(),
      ),
    );
  });

  group('message packer rejection', () {
    test(
      'opens a new transaction message when a packer rejects the candidate message',
      () async {
        final instructionA = createInstruction('A');
        final instructionB = createInstruction('B');
        final instructionC = createInstruction('C');
        final rejectingPacker = createRejectingMessagePackerInstructionPlan(
          [instructionB, instructionC],
          rejectNonEmptyMessages,
        );

        final transactionPlan = await planner(
          sequentialInstructionPlan([
            singleInstructionPlan(instructionA),
            rejectingPacker,
          ]),
        );

        // The packer refuses to append B and C onto the message holding A,
        // so each instruction lands in its own transaction message.
        expect(transactionPlan, isA<SequentialTransactionPlan>());
        final plans = (transactionPlan as SequentialTransactionPlan).plans;
        expect(plans, hasLength(3));
        expect(
          (plans[0] as SingleTransactionPlan).message.instructions,
          [same(instructionA)],
        );
        expect(
          (plans[1] as SingleTransactionPlan).message.instructions,
          [same(instructionB)],
        );
        expect(
          (plans[2] as SingleTransactionPlan).message.instructions,
          [same(instructionC)],
        );
      },
    );

    test(
      'falls back to a new transaction message when a packer rejects the parent candidate of a non-divisible plan',
      () async {
        final instructionA = createInstruction('A');
        final instructionB = createInstruction('B');
        final rejectingPacker = createRejectingMessagePackerInstructionPlan(
          [instructionB],
          rejectNonEmptyMessages,
        );

        final transactionPlan = await planner(
          sequentialInstructionPlan([
            singleInstructionPlan(instructionA),
            nonDivisibleSequentialInstructionPlan([rejectingPacker]),
          ]),
        );

        // The non-divisible plan first tries the parent candidate (holding
        // A); the packer rejects it, so the plan gets its own message.
        expect(transactionPlan, isA<SequentialTransactionPlan>());
        final plans = (transactionPlan as SequentialTransactionPlan).plans;
        expect(plans, hasLength(2));
        expect(
          (plans[0] as SingleTransactionPlan).message.instructions,
          [same(instructionA)],
        );
        expect(
          (plans[1] as SingleTransactionPlan).message.instructions,
          [same(instructionB)],
        );
      },
    );

    test(
      'propagates the rejection when a packer rejects a fresh transaction message',
      () async {
        final instructionA = createInstruction('A');
        final alwaysRejectingPacker =
            createRejectingMessagePackerInstructionPlan(
              [instructionA],
              (_) => 'this packer rejects every message',
            );

        await expectLater(
          planner(alwaysRejectingPacker),
          throwsA(
            isA<SolanaError>()
                .having(
                  (e) => e.code,
                  'code',
                  SolanaErrorCode.instructionPlansMessageRejectedByPacker,
                )
                .having(
                  (e) => e.context,
                  'context',
                  {'reason': 'this packer rejects every message'},
                ),
          ),
        );
      },
    );
  });
}
