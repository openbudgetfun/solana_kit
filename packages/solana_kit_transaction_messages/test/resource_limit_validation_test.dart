import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsValidComputeUnitLimit', () {
    test('accepts zero', () {
      expect(() => assertIsValidComputeUnitLimit(0), returnsNormally);
    });

    test('accepts the maximum compute unit limit', () {
      expect(
        () => assertIsValidComputeUnitLimit(maxComputeUnitLimit),
        returnsNormally,
      );
    });

    test('rejects a negative compute unit limit', () {
      expect(
        () => assertIsValidComputeUnitLimit(-1),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionComputeUnitLimitOutOfRange,
          ),
        ),
      );
    });

    test('rejects a compute unit limit above the maximum', () {
      expect(
        () => assertIsValidComputeUnitLimit(maxComputeUnitLimit + 1),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.transactionComputeUnitLimitOutOfRange,
              )
              .having(
                (e) => e.context['computeUnitLimit'],
                'computeUnitLimit',
                maxComputeUnitLimit + 1,
              )
              .having(
                (e) => e.context['maxComputeUnitLimit'],
                'maxComputeUnitLimit',
                maxComputeUnitLimit,
              ),
        ),
      );
    });

    test('renders the upstream error message', () {
      try {
        assertIsValidComputeUnitLimit(maxComputeUnitLimit + 1);
        fail('expected a SolanaError');
      } on SolanaError catch (error) {
        expect(
          error.toString(),
          'SolanaError#5663039: Transaction compute unit limit must be an '
          'integer in the range [0, 1400000]. `1400001` given',
        );
      }
    });
  });

  group('assertIsValidHeapSize', () {
    test('accepts the minimum heap size', () {
      expect(() => assertIsValidHeapSize(minHeapSize), returnsNormally);
    });

    test('accepts the maximum heap size', () {
      expect(() => assertIsValidHeapSize(maxHeapSize), returnsNormally);
    });

    test('rejects a heap size below the minimum', () {
      expect(
        () => assertIsValidHeapSize(minHeapSize - 1024),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionInvalidHeapSize,
          ),
        ),
      );
    });

    test('rejects a heap size above the maximum', () {
      expect(
        () => assertIsValidHeapSize(maxHeapSize + 1024),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionInvalidHeapSize,
          ),
        ),
      );
    });

    test('rejects a heap size that is not a multiple of 1 KiB', () {
      expect(
        () => assertIsValidHeapSize(minHeapSize + 1),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionInvalidHeapSize,
          ),
        ),
      );
    });

    test('renders the upstream error message', () {
      try {
        assertIsValidHeapSize(32);
        fail('expected a SolanaError');
      } on SolanaError catch (error) {
        expect(
          error.toString(),
          'SolanaError#5663040: Transaction heap size must be an integer '
          'multiple of 1024 bytes in the range [32768, 262144]. `32` given',
        );
      }
    });
  });

  group('setTransactionMessageConfig validation', () {
    test('accepts valid compute unit and heap sizes', () {
      final message = setTransactionMessageConfig(
        const V1TransactionConfig(computeUnitLimit: 200000, heapSize: 65536),
        createTransactionMessage(version: TransactionVersion.v1),
      );

      expect(message.config?.computeUnitLimit, 200000);
      expect(message.config?.heapSize, 65536);
    });

    test('rejects an out-of-range compute unit limit', () {
      expect(
        () => setTransactionMessageConfig(
          const V1TransactionConfig(computeUnitLimit: maxComputeUnitLimit + 1),
          createTransactionMessage(version: TransactionVersion.v1),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionComputeUnitLimitOutOfRange,
          ),
        ),
      );
    });

    test('rejects an invalid heap size', () {
      expect(
        () => setTransactionMessageConfig(
          const V1TransactionConfig(heapSize: 1024),
          createTransactionMessage(version: TransactionVersion.v1),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionInvalidHeapSize,
          ),
        ),
      );
    });

    test('rejects an invalid heap size merged onto an existing config', () {
      final message = setTransactionMessageConfig(
        const V1TransactionConfig(computeUnitLimit: 200000),
        createTransactionMessage(version: TransactionVersion.v1),
      );

      expect(
        () => setTransactionMessageConfig(
          const V1TransactionConfig(heapSize: 1024),
          message,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionInvalidHeapSize,
          ),
        ),
      );
    });
  });
}
