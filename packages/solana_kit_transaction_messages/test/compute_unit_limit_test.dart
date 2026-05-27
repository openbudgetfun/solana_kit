import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('getTransactionMessageComputeUnitLimit', () {
    test('returns null when no compute unit limit instruction exists', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);

      expect(getTransactionMessageComputeUnitLimit(message), isNull);
    });

    test('returns the first set compute unit limit instruction units', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .appendInstructions([
            _computeUnitLimitInstruction(123),
            _computeUnitLimitInstruction(456),
          ]);

      expect(getTransactionMessageComputeUnitLimit(message), 123);
    });

    test(
      'ignores non-compute-budget and non-limit compute-budget instructions',
      () {
        final message = createTransactionMessage(version: TransactionVersion.v0)
            .appendInstructions([
              Instruction(
                programAddress: const Address(
                  '11111111111111111111111111111111',
                ),
                data: _computeUnitLimitInstruction(123).data,
              ),
              Instruction(
                programAddress: computeBudgetProgramAddress,
                data: Uint8List.fromList([3]),
              ),
            ]);

        expect(getTransactionMessageComputeUnitLimit(message), isNull);
      },
    );
  });

  group('setTransactionMessageComputeUnitLimit', () {
    test('appends a compute unit limit instruction when none exists', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);
      final updated = setTransactionMessageComputeUnitLimit(200000, message);

      expect(updated.instructions, hasLength(1));
      expect(getTransactionMessageComputeUnitLimit(updated), 200000);
      expect(getTransactionMessageComputeUnitLimit(message), isNull);
    });

    test('returns the same message when setting the existing limit', () {
      final message = setTransactionMessageComputeUnitLimit(
        200000,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      expect(
        setTransactionMessageComputeUnitLimit(200000, message),
        same(message),
      );
    });

    test('replaces the first compute unit limit instruction', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .appendInstructions([
            _computeUnitLimitInstruction(1),
            _computeUnitLimitInstruction(2),
          ]);
      final updated = setTransactionMessageComputeUnitLimit(3, message);

      expect(updated.instructions, hasLength(2));
      expect(getTransactionMessageComputeUnitLimit(updated), 3);
      expect(_readComputeUnitLimit(updated.instructions[1]), 2);
    });

    test('removes the first compute unit limit instruction', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .appendInstructions([
            _computeUnitLimitInstruction(1),
            _computeUnitLimitInstruction(2),
          ]);
      final updated = setTransactionMessageComputeUnitLimit(null, message);

      expect(updated.instructions, hasLength(1));
      expect(getTransactionMessageComputeUnitLimit(updated), 2);
    });

    test('returns the same message when removing a missing limit', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);

      expect(
        setTransactionMessageComputeUnitLimit(null, message),
        same(message),
      );
    });
  });

  group('fillTransactionMessageProvisoryComputeUnitLimit', () {
    test('adds a provisory limit when no compute unit limit exists', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);
      final updated = fillTransactionMessageProvisoryComputeUnitLimit(message);

      expect(
        getTransactionMessageComputeUnitLimit(updated),
        provisoryComputeUnitLimit,
      );
    });

    test('preserves an existing limit', () {
      final message = setTransactionMessageComputeUnitLimit(
        400000,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      expect(
        fillTransactionMessageProvisoryComputeUnitLimit(message),
        same(message),
      );
    });
  });

  group('estimateAndSetComputeUnitLimitFactory', () {
    test('preserves existing non-provisory non-max limits', () async {
      var called = false;
      final message = setTransactionMessageComputeUnitLimit(
        400000,
        createTransactionMessage(version: TransactionVersion.v0),
      );
      final estimateAndSet = estimateAndSetComputeUnitLimitFactory((_) async {
        called = true;
        return 500000;
      });

      expect(await estimateAndSet(message), same(message));
      expect(called, isFalse);
    });

    test('replaces a provisory limit with the estimate', () async {
      final message = fillTransactionMessageProvisoryComputeUnitLimit(
        createTransactionMessage(version: TransactionVersion.v0),
      );
      final estimateAndSet = estimateAndSetComputeUnitLimitFactory((_) async {
        return 500000;
      });

      final updated = await estimateAndSet(message);

      expect(getTransactionMessageComputeUnitLimit(updated), 500000);
    });

    test('replaces a max limit with the estimate', () async {
      final message = setTransactionMessageComputeUnitLimit(
        maxComputeUnitLimit,
        createTransactionMessage(version: TransactionVersion.v0),
      );
      final estimateAndSet = estimateAndSetComputeUnitLimitFactory((_) async {
        return 600000;
      });

      final updated = await estimateAndSet(message);

      expect(getTransactionMessageComputeUnitLimit(updated), 600000);
    });
  });
}

Instruction _computeUnitLimitInstruction(int units) {
  return setTransactionMessageComputeUnitLimit(
    units,
    createTransactionMessage(version: TransactionVersion.v0),
  ).instructions.single;
}

int _readComputeUnitLimit(Instruction instruction) {
  return ByteData.sublistView(instruction.data!).getUint32(1, Endian.little);
}
