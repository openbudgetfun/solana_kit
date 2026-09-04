import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const originalFeePayer = Address('11111111111111111111111111111111');
  const replacementFeePayer = Address(
    'ComputeBudget111111111111111111111111111111',
  );
  const config = V1TransactionConfig(computeUnitLimit: 1000, heapSize: 32768);
  final signer = createNoopSigner(originalFeePayer);

  test('replacing the payer removes the previous payer signer', () {
    final message = setTransactionMessageFeePayerSigner(
      signer,
      createTransactionMessage(version: TransactionVersion.v1).copyWith(
        config: config,
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: originalFeePayer.value,
          lastValidBlockHeight: BigInt.one,
        ),
      ),
    );

    final updated = setTransactionMessageFeePayer(replacementFeePayer, message);

    expect(updated.feePayer, replacementFeePayer);
    expect(getSignersFromTransactionMessage(updated), isEmpty);
    expect(updated.config, config);
    expect(updated.lifetimeConstraint, message.lifetimeConstraint);
    expect(message.feePayer, originalFeePayer);
  });

  for (final hasFeePayerSigner in [false, true]) {
    test('adding signers preserves v1 config (payer: $hasFeePayerSigner)', () {
      final message = createTransactionMessage(version: TransactionVersion.v1)
          .copyWith(
            feePayer: originalFeePayer,
            config: config,
            instructions: const [
              Instruction(programAddress: replacementFeePayer),
            ],
          );
      final input = hasFeePayerSigner
          ? setTransactionMessageFeePayerSigner(signer, message)
          : message;

      final updated = addSignersToTransactionMessage([signer], input);

      expect(updated.config, config);
      expect(updated.feePayer, originalFeePayer);
      expect(getSignersFromTransactionMessage(updated), [signer]);
    });
  }
}
