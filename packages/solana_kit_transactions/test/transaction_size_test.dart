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

  Transaction rawTransaction(List<int> messageBytes) {
    return Transaction(
      messageBytes: Uint8List.fromList(messageBytes),
      signatures: {},
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

    test('uses the v1 transaction size limit from message bytes', () {
      final messageBytes = [0x81, ...Uint8List(transactionSizeLimit + 1)];
      final transaction = rawTransaction(messageBytes);

      expect(getTransactionSize(transaction), lessThan(transactionV1SizeLimit));
      expect(isTransactionWithinSizeLimit(transaction), isTrue);
    });

    test('returns true for an empty transaction', () {
      expect(isTransactionWithinSizeLimit(rawTransaction([])), isTrue);
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

    test('does not throw for an empty transaction', () {
      expect(
        () => assertIsTransactionWithinSizeLimit(rawTransaction([])),
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

  group('getTransactionMessageSize', () {
    test('gets the size of a transaction message', () {
      final size = getTransactionMessageSize(smallMessage());
      expect(size, greaterThan(0));
      expect(size, lessThan(transactionSizeLimit));
    });
  });

  group('isTransactionMessageWithinSizeLimit', () {
    test('returns true when the message size is under the limit', () {
      expect(isTransactionMessageWithinSizeLimit(smallMessage()), isTrue);
    });

    test('returns false when the message size is above the limit', () {
      expect(isTransactionMessageWithinSizeLimit(oversizedMessage()), isFalse);
    });
  });

  group('assertIsTransactionMessageWithinSizeLimit', () {
    test('does not throw when the message size is under the limit', () {
      expect(
        () => assertIsTransactionMessageWithinSizeLimit(smallMessage()),
        returnsNormally,
      );
    });

    test('throws when the message size is above the limit', () {
      expect(
        () => assertIsTransactionMessageWithinSizeLimit(oversizedMessage()),
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

  group('getTransactionMessageSizeLimit', () {
    test('uses the transaction message version', () {
      expect(
        getTransactionMessageSizeLimit(smallMessage()),
        transactionSizeLimit,
      );
      expect(
        getTransactionMessageSizeLimit(
          const TransactionMessage(version: TransactionVersion.legacy),
        ),
        transactionSizeLimit,
      );
    });
  });

  group('transactionSizeLimit', () {
    test('equals 1232 (1280 - 48)', () {
      expect(transactionSizeLimit, 1232);
    });

    test('uses the legacy packet limit for legacy and version 0 messages', () {
      expect(
        getTransactionSizeLimit(TransactionVersion.legacy),
        transactionSizeLimit,
      );
      expect(
        getTransactionSizeLimit(TransactionVersion.v0),
        transactionSizeLimit,
      );
      expect(
        getTransactionSizeLimit(TransactionVersion.v1),
        transactionV1SizeLimit,
      );
    });

    test('detects the transaction limit from message bytes', () {
      expect(
        getTransactionSizeLimit(rawTransaction([0x80])),
        transactionSizeLimit,
      );
      expect(
        getTransactionSizeLimit(rawTransaction([0x81])),
        transactionV1SizeLimit,
      );
      expect(getTransactionSizeLimit(rawTransaction([])), transactionSizeLimit);
    });

    test('rejects unsupported inputs', () {
      expect(() => getTransactionSizeLimit('v1'), throwsArgumentError);
    });

    test('exposes upstream-compatible transaction size limit aliases', () {
      expect(legacyTransactionSizeLimit, transactionSizeLimit);
      expect(transactionV1SizeLimit, 4096);
      expect(v1TransactionSizeLimit, transactionV1SizeLimit);
    });
  });
}
