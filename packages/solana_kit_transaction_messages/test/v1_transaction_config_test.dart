import 'dart:typed_data';

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

    test('compiled config values support value equality', () {
      final priorityFee = CompiledTransactionConfigValue.u64(BigInt.from(40));
      final samePriorityFee = CompiledTransactionConfigValue.u64(
        BigInt.from(40),
      );
      const computeUnitLimit = CompiledTransactionConfigValue.u32(10);

      expect(priorityFee, samePriorityFee);
      expect(priorityFee.hashCode, samePriorityFee.hashCode);
      expect(priorityFee, isNot(computeUnitLimit));
    });

    test('v1 instruction header and payload support value equality', () {
      const header = V1InstructionHeader(
        programAccountIndex: 1,
        numInstructionAccounts: 2,
        numInstructionDataBytes: 3,
      );
      const sameHeader = V1InstructionHeader(
        programAccountIndex: 1,
        numInstructionAccounts: 2,
        numInstructionDataBytes: 3,
      );
      final payload = V1InstructionPayload(
        // ignore: prefer_const_literals_to_create_immutables
        instructionAccountIndices: [1, 2],
        instructionData: Uint8List.fromList([3, 4]),
      );
      final samePayload = V1InstructionPayload(
        // ignore: prefer_const_literals_to_create_immutables
        instructionAccountIndices: [1, 2],
        instructionData: Uint8List.fromList([3, 4]),
      );

      expect(header, sameHeader);
      expect(header.hashCode, sameHeader.hashCode);
      expect(payload, samePayload);
      expect(payload.hashCode, samePayload.hashCode);
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
