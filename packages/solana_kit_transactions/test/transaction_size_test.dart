import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  final mockBlockhash = BlockhashLifetimeConstraint(
    blockhash: '11111111111111111111111111111111',
    lastValidBlockHeight: BigInt.zero,
  );

  TransactionMessage smallMessage() {
    return const TransactionMessage(version: TransactionVersion.v0).copyWith(
      feePayer: const Address('22222222222222222222222222222222222222222222'),
      lifetimeConstraint: mockBlockhash,
    );
  }

  TransactionMessage oversizedMessage() {
    return smallMessage().copyWith(
      instructions: [
        Instruction(
          data: Uint8List(transactionSizeLimit + 1),
          programAddress: const Address(
            '33333333333333333333333333333333333333333333',
          ),
        ),
      ],
    );
  }

  group('getTransactionSize', () {
    test('gets the size of a transaction', () {
      final transaction = compileTransaction(smallMessage());
      final size = getTransactionSize(transaction);
      // The size should be a reasonable small value.
      expect(size, greaterThan(0));
      expect(size, lessThan(transactionSizeLimit));
    });

    test('gets the size of an oversized transaction', () {
      final transaction = compileTransaction(oversizedMessage());
      final size = getTransactionSize(transaction);
      expect(size, greaterThan(transactionSizeLimit));
    });
  });

  group('isTransactionWithinSizeLimit', () {
    test('returns true when the transaction size is under the limit', () {
      final transaction = compileTransaction(smallMessage());
      expect(isTransactionWithinSizeLimit(transaction), isTrue);
    });

    test('returns false when the transaction size is above the limit', () {
      final transaction = compileTransaction(oversizedMessage());
      expect(isTransactionWithinSizeLimit(transaction), isFalse);
    });
  });

  group('assertIsTransactionWithinSizeLimit', () {
    test('does not throw when the transaction size is under the limit', () {
      final transaction = compileTransaction(smallMessage());
      expect(
        () => assertIsTransactionWithinSizeLimit(transaction),
        returnsNormally,
      );
    });

    test('throws when the transaction size is above the limit', () {
      final transaction = compileTransaction(oversizedMessage());
      expect(
        () => assertIsTransactionWithinSizeLimit(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionExceedsSizeLimit,
          ),
        ),
      );
    });
  });

  group('transactionSizeLimit', () {
    test('equals 1232 (1280 - 48)', () {
      expect(transactionSizeLimit, 1232);
    });
  });
}
