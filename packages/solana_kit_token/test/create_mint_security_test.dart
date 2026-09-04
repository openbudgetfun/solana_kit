import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const payer = Address('E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ');
  const mint = Address('11111111111111111111111111111112');

  InstructionPlan createMint() => getCreateMintInstructionPlan(
    const CreateMintInput(
      payer: payer,
      newMint: mint,
      decimals: 6,
      mintAuthority: payer,
    ),
  );

  TransactionPlanner planner(int maxInstructions) => createTransactionPlanner(
    TransactionPlannerConfig(
      maxInstructionsPerTransaction: maxInstructions,
      createTransactionMessage: () async => TransactionMessage(
        version: TransactionVersion.v0,
        feePayer: payer,
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.one,
        ),
      ),
    ),
  );

  group('mint initialization atomicity', () {
    test('creation and initialization fit in a single transaction', () async {
      final plan = await planner(2)(createMint());
      expect(plan, isA<SingleTransactionPlan>());
      final instructions = (plan as SingleTransactionPlan).message.instructions;
      expect(instructions, hasLength(2));
      expect(instructions[0].programAddress, systemProgramAddress);
      expect(
        parseInitializeMint2Instruction(instructions[1]).mintAuthority,
        payer,
      );
    });

    test(
      'a transaction limit preserves the atomic initialization group',
      () async {
        final plan = await planner(1)(createMint());
        expect(plan, isA<SequentialTransactionPlan>());
        final sequence = plan as SequentialTransactionPlan;
        expect(sequence.plans, hasLength(2));
        expect(
          sequence.divisible,
          isFalse,
          reason:
              'An uninitialized mint accepts any caller as its first authority.',
        );
      },
    );

    test(
      'executor rejects a split mint before funding an uninitialized account',
      () async {
        final plan = await planner(1)(createMint());
        var submitted = 0;
        final execute = createTransactionPlanExecutor(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, message) async {
              submitted++;
              return {'signature': 'test-signature'};
            },
          ),
        );

        await expectLater(
          execute(plan),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode
                  .instructionPlansNonDivisibleTransactionPlansNotSupported,
            ),
          ),
        );
        expect(submitted, 0);
      },
    );
  });
}
