import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('createTransactionExecutionBoundary', () {
    test('returns planning failures as structured outcomes', () async {
      final boundary = createTransactionExecutionBoundary(
        TransactionExecutionBoundaryConfig(
          planTransactions: (_) async => throw StateError('planning failed'),
          signTransactionMessage: (_) async => throw UnimplementedError(),
          sendSignedTransaction: (_) async => throw UnimplementedError(),
        ),
      );

      final outcome = await boundary(
        singleInstructionPlan(
          const Instruction(
            programAddress: Address(
              '11111111111111111111111111111111',
            ),
          ),
        ),
      );

      expect(outcome, isA<FailedTransactionExecution>());
      final failed = outcome as FailedTransactionExecution;
      expect(failed.stage, TransactionExecutionFailureStage.planning);
      expect(failed.error, isA<StateError>());
      expect(failed.transactionPlan, isNull);
      expect(failed.transactionPlanResult, isNull);
    });

    test('returns signing failures without throwing', () async {
      final message = _createMessage();
      final boundary = createTransactionExecutionBoundary(
        TransactionExecutionBoundaryConfig(
          planTransactions: (_) async => singleTransactionPlan(message),
          signTransactionMessage: (_) async => throw StateError('signing failed'),
          sendSignedTransaction: (_) async => throw UnimplementedError(),
        ),
      );

      final outcome = await boundary(_singleInstructionPlan());

      expect(outcome, isA<FailedTransactionExecution>());
      final failed = outcome as FailedTransactionExecution;
      expect(failed.stage, TransactionExecutionFailureStage.signing);
      expect(failed.error, isA<StateError>());
      expect(failed.transactionPlan, isNotNull);
      expect(failed.transactionPlanResult, isA<FailedSingleTransactionPlanResult>());
    });

    test('returns sending failures without throwing', () async {
      final feePayer = generateKeyPairSigner();
      final message = _createMessage(feePayer: feePayer.address);
      final boundary = createTransactionExecutionBoundary(
        TransactionExecutionBoundaryConfig(
          planTransactions: (_) async => singleTransactionPlan(message),
          signTransactionMessage: (_) async => signTransactionWithSigners(
            <Object>[feePayer],
            compileTransaction(message),
          ),
          sendSignedTransaction: (_) async => throw StateError('sending failed'),
        ),
      );

      final outcome = await boundary(_singleInstructionPlan());

      expect(outcome, isA<FailedTransactionExecution>());
      final failed = outcome as FailedTransactionExecution;
      expect(failed.stage, TransactionExecutionFailureStage.sending);
      expect(failed.error, isA<StateError>());
    });
  });

  group('createSigningTransactionExecutionBoundary', () {
    test('plans, signs, and sends through one boundary', () async {
      final feePayer = generateKeyPairSigner();
      final sentTransactions = <Transaction>[];
      final boundary = createSigningTransactionExecutionBoundary(
        SigningTransactionExecutionBoundaryConfig(
          createTransactionMessage: () async {
            return _createMessage(feePayer: feePayer.address);
          },
          signers: <Object>[feePayer],
          sendSignedTransaction: (transaction) async {
            sentTransactions.add(transaction);
            return getSignatureFromTransaction(transaction);
          },
        ),
      );

      final outcome = await boundary(_singleInstructionPlan());

      expect(outcome, isA<SuccessfulTransactionExecution>());
      final success = outcome as SuccessfulTransactionExecution;
      expect(success.transactionPlan, isA<SingleTransactionPlan>());
      expect(
        success.transactionPlanResult,
        isA<SuccessfulSingleTransactionPlanResult>(),
      );
      expect(sentTransactions, hasLength(1));
    });
  });
}

InstructionPlan _singleInstructionPlan() {
  return singleInstructionPlan(
    Instruction(
      programAddress: const Address('11111111111111111111111111111111'),
      accounts: const <AccountMeta>[],
      data: Uint8List(0),
    ),
  );
}

TransactionMessage _createMessage({
  Address feePayer = const Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK'),
}) {
  return createTransactionMessage(version: TransactionVersion.v0).copyWith(
    feePayer: feePayer,
    lifetimeConstraint: BlockhashLifetimeConstraint(
      blockhash: 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
      lastValidBlockHeight: BigInt.from(100),
    ),
  );
}
