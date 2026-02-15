import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const feePayer = Address('7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK');
  const programAddress = Address(
    'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
  );

  group('compileTransactionMessage', () {
    test('throws when there is no fee payer', () {
      final tx = createTransactionMessage(version: TransactionVersion.v0);
      expect(
        () => compileTransactionMessage(tx),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFeePayerMissing,
          ),
        ),
      );
    });

    test('compiles a simple transaction with no instructions', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);
      final compiled = compileTransactionMessage(tx);

      expect(compiled.version, TransactionVersion.v0);
      expect(compiled.header.numSignerAccounts, 1);
      expect(compiled.header.numReadonlySignerAccounts, 0);
      expect(compiled.header.numReadonlyNonSignerAccounts, 0);
      expect(compiled.staticAccounts, [feePayer]);
      expect(compiled.instructions, isEmpty);
    });

    test('compiles a transaction with a blockhash lifetime', () {
      final tx = createTransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: feePayer,
            lifetimeConstraint: BlockhashLifetimeConstraint(
              blockhash: 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
              lastValidBlockHeight: BigInt.from(100),
            ),
          );
      final compiled = compileTransactionMessage(tx);

      expect(
        compiled.lifetimeToken,
        'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
      );
    });

    test('compiles a transaction with a durable nonce lifetime', () {
      final tx = createTransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: feePayer,
            lifetimeConstraint: const DurableNonceLifetimeConstraint(
              nonce: '27kqzE1RifbyoFtibDRTjbnfZ894jsNpuR77JJkt3vgH',
            ),
          );
      final compiled = compileTransactionMessage(tx);

      expect(
        compiled.lifetimeToken,
        '27kqzE1RifbyoFtibDRTjbnfZ894jsNpuR77JJkt3vgH',
      );
    });

    test('compiles a transaction with an instruction', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);
      final txWithInstruction = appendTransactionMessageInstruction(
        Instruction(
          programAddress: programAddress,
          accounts: const [
            AccountMeta(
              address: Address('H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x'),
              role: AccountRole.writableSigner,
            ),
            AccountMeta(
              address: Address('3LeBzRE9Yna5zi9R8vdT3MiNQYuEp4gJgVyhhwmqfCtd'),
              role: AccountRole.writable,
            ),
          ],
          data: Uint8List.fromList([1, 2, 3]),
        ),
        tx,
      );

      final compiled = compileTransactionMessage(txWithInstruction);

      // Fee payer (writable signer), instruction account (writable signer),
      // instruction account (writable), program (readonly)
      expect(compiled.staticAccounts.length, 4);
      expect(compiled.header.numSignerAccounts, 2);
      expect(compiled.instructions.length, 1);
      expect(compiled.instructions[0].data, Uint8List.fromList([1, 2, 3]));
    });

    test('does not include addressTableLookups for legacy transactions', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.legacy,
      ).copyWith(feePayer: feePayer);
      final compiled = compileTransactionMessage(tx);

      expect(compiled.addressTableLookups, isNull);
    });

    test('includes addressTableLookups for v0 transactions', () {
      final tx = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(feePayer: feePayer);
      final compiled = compileTransactionMessage(tx);

      expect(compiled.addressTableLookups, isNotNull);
      expect(compiled.addressTableLookups, isEmpty);
    });
  });
}
