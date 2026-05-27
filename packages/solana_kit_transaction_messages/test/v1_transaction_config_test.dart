import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('V1TransactionConfig', () {
    test('supports value equality, hashing, and copies', () {
      final config = V1TransactionConfig(
        computeUnitLimit: 1,
        heapSize: 2,
        loadedAccountsDataSizeLimit: 3,
        priorityFeeLamports: BigInt.from(4),
      );
      final same = V1TransactionConfig(
        computeUnitLimit: 1,
        heapSize: 2,
        loadedAccountsDataSizeLimit: 3,
        priorityFeeLamports: BigInt.from(4),
      );

      expect(config, same);
      expect(config.hashCode, same.hashCode);
      expect(config.isEmpty, isFalse);
      expect(
        config
            .copyWith(
              clearComputeUnitLimit: true,
              clearHeapSize: true,
              clearLoadedAccountsDataSizeLimit: true,
              clearPriorityFeeLamports: true,
            )
            .isEmpty,
        isTrue,
      );
      expect(config.copyWith().heapSize, 2);
      expect(config.copyWith(heapSize: 5).heapSize, 5);
    });

    test('computes masks and values in wire order', () {
      final config = V1TransactionConfig(
        computeUnitLimit: 10,
        heapSize: 20,
        loadedAccountsDataSizeLimit: 30,
        priorityFeeLamports: BigInt.from(40),
      );

      expect(getTransactionConfigMask(config), 31);
      expect(
        getTransactionConfigValues(
          config,
        ).map((value) => (value.kind, value.value)),
        [('u64', BigInt.from(40)), ('u32', 10), ('u32', 30), ('u32', 20)],
      );
    });

    test('rejects invalid priority fee mask bits', () {
      expect(
        () => transactionConfigMaskHasPriorityFee(1),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.transactionInvalidConfigMaskPriorityFeeBits,
          ),
        ),
      );
    });

    test('merges config onto transaction messages', () {
      final message = createTransactionMessage(version: TransactionVersion.v1);
      final withConfig = setTransactionMessageConfig(
        const V1TransactionConfig(computeUnitLimit: 1),
        message,
      );
      final merged = setTransactionMessageConfig(
        const V1TransactionConfig(heapSize: 2),
        withConfig,
      );

      expect(merged.config?.computeUnitLimit, 1);
      expect(merged.config?.heapSize, 2);
      expect(merged.toString(), contains('config:'));
    });
  });
}
