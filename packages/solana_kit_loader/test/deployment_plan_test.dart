import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

const _payer = Address('11111111111111111111111111111112');
const _programData = Address('11111111111111111111111111111113');
const _program = Address('11111111111111111111111111111114');
const _buffer = Address('11111111111111111111111111111115');
const _authority = Address('11111111111111111111111111111116');

void main() {
  for (final upgrade in [false, true]) {
    test(
      'executes a multi-transaction ${upgrade ? 'upgrade' : 'deploy'}',
      () async {
        final bytes = Uint8List.fromList(
          List<int>.generate(2700, (index) => index % 256),
        );
        final instructionPlan = upgrade
            ? getUpgradeProgramInstructionPlan(
                programDataAccount: _programData,
                programAccount: _program,
                bufferAccount: _buffer,
                spillAccount: _payer,
                authority: _authority,
                programBytes: bytes,
              )
            : getDeployProgramInstructionPlan(
                payerAccount: _payer,
                programDataAccount: _programData,
                programAccount: _program,
                bufferAccount: _buffer,
                authority: _authority,
                programBytes: bytes,
              );
        final planner = createTransactionPlanner(
          TransactionPlannerConfig(
            createTransactionMessage: () async => TransactionMessage(
              version: TransactionVersion.v0,
              feePayer: _payer,
              lifetimeConstraint: BlockhashLifetimeConstraint(
                blockhash: '11111111111111111111111111111111',
                lastValidBlockHeight: BigInt.one,
              ),
            ),
          ),
        );
        final transactionPlan = await planner(instructionPlan);
        final sent = <List<Instruction>>[];
        final executor = createTransactionPlanExecutor(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (_, message) async {
              sent.add(message.instructions);
              return <String, Object?>{'signature': 'test signature'};
            },
          ),
        );

        await executor(transactionPlan);

        expect(sent.length, greaterThan(1));
        final instructions = sent
            .expand((instructions) => instructions)
            .toList();
        final writes = instructions
            .take(instructions.length - 1)
            .map(
              (instruction) =>
                  getWriteInstructionDataDecoder().decode(instruction.data!),
            );
        expect(writes.map((write) => write.offset), [0, 900, 1800]);
        expect(writes.expand((write) => write.bytes), bytes);
        expect(
          instructions.last.data!.first,
          upgrade ? 3 : 2,
        );
      },
    );
  }
}
