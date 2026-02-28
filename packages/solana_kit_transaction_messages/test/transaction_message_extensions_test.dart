import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const feePayer = Address('7mvYAxeCui21xYkAyQSjh6iBVZPpgVyt7PYv9km8V5mE');
  const programA = Address('AALQD2dt1k43Acrkp4SvdhZaN4S115Ff2Bi7rHPti3sL');
  const programB = Address('DNAbkMkoMLRXF7wuLCrTzouMyzi25krr3B94yW87VvxU');
  const nonceAccount = Address('5LHng8dLBxCYyR3jdDbobLiRQ6pR74pYtxKohY93RbZN');
  const nonceAuthority = Address(
    '6Bkt4j67rxzFF6s9DaMRyfitftRrGxe4oYHPRHuFChzi',
  );

  group('TransactionMessageFluentX', () {
    test('withFeePayer mirrors function helper behavior', () {
      final base = createTransactionMessage(version: TransactionVersion.v0);
      final withPayer = base.withFeePayer(feePayer);

      expect(withPayer.feePayer, feePayer);
      expect(withPayer.withFeePayer(feePayer), same(withPayer));
    });

    test('appendInstruction and prependInstruction preserve order', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .appendInstruction(const Instruction(programAddress: programA))
          .prependInstruction(const Instruction(programAddress: programB));

      expect(message.instructions.length, 2);
      expect(message.instructions[0].programAddress, programB);
      expect(message.instructions[1].programAddress, programA);
    });

    test('withBlockhashLifetime sets blockhash lifetime constraint', () {
      final lifetime = BlockhashLifetimeConstraint(
        blockhash: '11111111111111111111111111111111',
        lastValidBlockHeight: BigInt.from(123),
      );

      final message = createTransactionMessage(
        version: TransactionVersion.v0,
      ).withBlockhashLifetime(lifetime);

      expect(message.lifetimeConstraint, lifetime);
      expect(isTransactionMessageWithBlockhashLifetime(message), isTrue);
    });

    test('withDurableNonceLifetime sets durable nonce lifetime and advance '
        'nonce instruction', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .appendInstruction(const Instruction(programAddress: programA))
          .withDurableNonceLifetime(
            const DurableNonceConfig(
              nonce: '11111111111111111111111111111111',
              nonceAccountAddress: nonceAccount,
              nonceAuthorityAddress: nonceAuthority,
            ),
          );

      expect(isTransactionMessageWithDurableNonceLifetime(message), isTrue);
      expect(message.instructions.isNotEmpty, isTrue);
      expect(
        isAdvanceNonceAccountInstruction(message.instructions.first),
        isTrue,
      );
    });
  });
}
