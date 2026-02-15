import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsTransactionMessageWithBlockhashLifetime', () {
    test('throws for a transaction with no lifetime constraint', () {
      final transaction = createTransactionMessage(
        version: TransactionVersion.v0,
      );
      expect(
        () => assertIsTransactionMessageWithBlockhashLifetime(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionExpectedBlockhashLifetime,
          ),
        ),
      );
    });

    test('throws for a transaction with a durable nonce constraint', () {
      final transaction = createTransactionMessage(
        version: TransactionVersion.v0,
      ).copyWith(
        lifetimeConstraint: const DurableNonceLifetimeConstraint(
          nonce: 'abcd',
        ),
      );
      expect(
        () => assertIsTransactionMessageWithBlockhashLifetime(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionExpectedBlockhashLifetime,
          ),
        ),
      );
    });

    test(
      'does not throw for a transaction with a valid blockhash lifetime '
      'constraint',
      () {
        final transaction = createTransactionMessage(
          version: TransactionVersion.v0,
        ).copyWith(
          lifetimeConstraint: BlockhashLifetimeConstraint(
            blockhash: '11111111111111111111111111111111',
            lastValidBlockHeight: BigInt.from(1234),
          ),
        );
        expect(
          () => assertIsTransactionMessageWithBlockhashLifetime(transaction),
          returnsNormally,
        );
      },
    );
  });

  group('setTransactionMessageLifetimeUsingBlockhash', () {
    late TransactionMessage baseTx;

    final blockhashConstraintA = BlockhashLifetimeConstraint(
      blockhash: 'F7vmkY3DTaxfagttWjQweib42b6ZHADSx94Tw8gHx3W7',
      lastValidBlockHeight: BigInt.from(123),
    );
    final blockhashConstraintB = BlockhashLifetimeConstraint(
      blockhash: '6bjroqDcZgTv6Vavhqf81oBHTv3aMnX19UTB51YhAZnN',
      lastValidBlockHeight: BigInt.from(123),
    );

    setUp(() {
      baseTx = createTransactionMessage(version: TransactionVersion.v0);
    });

    test(
      'sets the lifetime constraint on the transaction to the supplied '
      'blockhash lifetime constraint',
      () {
        final txWithBlockhash = setTransactionMessageLifetimeUsingBlockhash(
          blockhashConstraintA,
          baseTx,
        );
        expect(
          txWithBlockhash.lifetimeConstraint,
          isA<BlockhashLifetimeConstraint>()
              .having(
                (c) => c.blockhash,
                'blockhash',
                blockhashConstraintA.blockhash,
              )
              .having(
                (c) => c.lastValidBlockHeight,
                'lastValidBlockHeight',
                blockhashConstraintA.lastValidBlockHeight,
              ),
        );
      },
    );

    group('given a transaction with a blockhash lifetime already set', () {
      late TransactionMessage txWithBlockhashA;

      setUp(() {
        txWithBlockhashA = setTransactionMessageLifetimeUsingBlockhash(
          blockhashConstraintA,
          baseTx,
        );
      });

      test(
        'sets the new blockhash lifetime constraint on the transaction when '
        'it differs from the existing one',
        () {
          final txWithBlockhashB =
              setTransactionMessageLifetimeUsingBlockhash(
                blockhashConstraintB,
                txWithBlockhashA,
              );
          expect(
            txWithBlockhashB.lifetimeConstraint,
            isA<BlockhashLifetimeConstraint>().having(
              (c) => c.blockhash,
              'blockhash',
              blockhashConstraintB.blockhash,
            ),
          );
        },
      );

      test(
        'returns the original transaction when trying to set the same '
        'blockhash lifetime constraint again',
        () {
          final txWithSameBlockhash =
              setTransactionMessageLifetimeUsingBlockhash(
                blockhashConstraintA,
                txWithBlockhashA,
              );
          expect(identical(txWithBlockhashA, txWithSameBlockhash), isTrue);
        },
      );
    });
  });
}
