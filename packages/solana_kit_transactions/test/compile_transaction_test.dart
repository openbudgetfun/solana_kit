import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('compileTransaction', () {
    final mockBlockhash = BlockhashLifetimeConstraint(
      blockhash: '11111111111111111111111111111111',
      lastValidBlockHeight: BigInt.one,
    );

    TransactionMessage createMessage() {
      return const TransactionMessage(version: TransactionVersion.v0).copyWith(
        feePayer: const Address('22222222222222222222222222222222222222222222'),
        lifetimeConstraint: mockBlockhash,
      );
    }

    test('compiles the supplied TransactionMessage and sets messageBytes', () {
      final message = createMessage();
      final transaction = compileTransaction(message);
      expect(transaction.messageBytes, isA<Uint8List>());
      expect(transaction.messageBytes.isNotEmpty, isTrue);
    });

    test('compiles signatures with correct number of entries', () {
      final message = createMessage();
      final transaction = compileTransaction(message);
      // Fee payer is the only signer.
      expect(transaction.signatures.length, 1);
    });

    test('inserts signers into the correct position in the signatures map', () {
      final message = createMessage();
      final transaction = compileTransaction(message);
      expect(
        transaction.signatures.keys.first,
        const Address('22222222222222222222222222222222222222222222'),
      );
    });

    test('inserts a null signature into the map for each signer', () {
      final message = createMessage();
      final transaction = compileTransaction(message);
      expect(transaction.signatures.values.toList(), [null]);
    });

    test('returns a blockhash lifetime constraint when the transaction message '
        'has a blockhash constraint', () {
      final message = createMessage();
      final transaction = compileTransaction(message);
      expect(transaction, isA<TransactionWithLifetime>());
      final lifetime = transaction.lifetimeConstraint;
      expect(lifetime, isA<TransactionBlockhashLifetime>());
      final blockhashLifetime = lifetime as TransactionBlockhashLifetime;
      expect(blockhashLifetime.blockhash, '11111111111111111111111111111111');
      expect(blockhashLifetime.lastValidBlockHeight, BigInt.one);
    });

    test('returns a durable nonce lifetime constraint when the transaction '
        'message has a nonce constraint', () {
      final baseMessage =
          const TransactionMessage(version: TransactionVersion.v0).copyWith(
            feePayer: const Address(
              '22222222222222222222222222222222222222222222',
            ),
          );
      final nonceMessage = setTransactionMessageLifetimeUsingDurableNonce(
        const DurableNonceConfig(
          nonce: '33333333333333333333333333333333',
          nonceAccountAddress: Address(
            '44444444444444444444444444444444444444444444',
          ),
          nonceAuthorityAddress: Address(
            '55555555555555555555555555555555555555555555',
          ),
        ),
        baseMessage,
      );

      final transaction = compileTransaction(nonceMessage);
      expect(transaction, isA<TransactionWithLifetime>());
      final lifetime = transaction.lifetimeConstraint;
      expect(lifetime, isA<TransactionDurableNonceLifetime>());
      final nonceLifetime = lifetime as TransactionDurableNonceLifetime;
      expect(nonceLifetime.nonce, '33333333333333333333333333333333');
      expect(
        nonceLifetime.nonceAccountAddress,
        const Address('44444444444444444444444444444444444444444444'),
      );
    });

    test('compiles a message with multiple signers', () {
      final message = const TransactionMessage(version: TransactionVersion.v0)
          .copyWith(
            feePayer: const Address(
              '22222222222222222222222222222222222222222222',
            ),
            lifetimeConstraint: mockBlockhash,
            instructions: [
              const Instruction(
                programAddress: Address(
                  '55555555555555555555555555555555555555555555',
                ),
                accounts: [
                  AccountMeta(
                    address: Address(
                      '66666666666666666666666666666666666666666666',
                    ),
                    role: AccountRole.readonlySigner,
                  ),
                ],
              ),
            ],
          );

      final transaction = compileTransaction(message);
      // Fee payer + the readonly signer = 2 signers.
      expect(transaction.signatures.length, 2);
      expect(
        transaction.signatures.keys.toList(),
        contains(const Address('22222222222222222222222222222222222222222222')),
      );
    });
  });
}
