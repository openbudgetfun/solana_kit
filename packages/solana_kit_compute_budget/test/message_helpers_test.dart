import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart'
    hide provisoryComputeUnitLimit;
import 'package:test/test.dart';

void main() {
  group('compute budget transaction message helpers', () {
    test('finds and appends provisory compute unit limit', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);

      final updated = fillProvisorySetComputeUnitLimitInstruction(message);
      final details = findSetComputeUnitLimitInstructionIndexAndUnits(updated);

      expect(details, isNotNull);
      expect(details!.index, equals(0));
      expect(details.units, equals(provisoryComputeUnitLimit));
    });

    test('returns null when compute budget instructions are absent', () {
      final message = createTransactionMessage(version: TransactionVersion.v0)
          .appendInstruction(
            Instruction(
              programAddress: systemProgramAddress,
              accounts: const [],
              data: Uint8List(0),
            ),
          )
          .appendInstruction(
            Instruction(
              programAddress: computeBudgetProgramAddress,
              accounts: const [],
              data: Uint8List.fromList([setComputeUnitLimitDiscriminator]),
            ),
          );

      expect(findSetComputeUnitLimitInstructionIndexAndUnits(message), isNull);
      expect(
        findSetComputeUnitPriceInstructionIndexAndMicroLamports(message),
        isNull,
      );
    });

    test('does not duplicate an existing provisory compute unit limit', () {
      final message = updateOrAppendSetComputeUnitLimitInstruction(
        provisoryComputeUnitLimit,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final updated = fillProvisorySetComputeUnitLimitInstruction(message);

      expect(identical(updated, message), isTrue);
      expect(updated.instructions, hasLength(1));
    });

    test('updates existing compute unit limit without appending', () {
      final message = updateOrAppendSetComputeUnitLimitInstruction(
        100,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final updated = updateOrAppendSetComputeUnitLimitInstruction(
        (int? previousUnits) => previousUnits! * 2,
        message,
      );
      final details = findSetComputeUnitLimitInstructionIndexAndUnits(updated);

      expect(updated.instructions, hasLength(1));
      expect(details!.units, equals(200));
    });

    test('returns original message when compute unit limit is unchanged', () {
      final message = updateOrAppendSetComputeUnitLimitInstruction(
        100,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final updated = updateOrAppendSetComputeUnitLimitInstruction(
        100,
        message,
      );

      expect(identical(updated, message), isTrue);
    });

    test('appends compute unit price with update helper', () {
      final updated = updateOrAppendSetComputeUnitPriceInstruction(
        BigInt.from(700),
        createTransactionMessage(version: TransactionVersion.v0),
      );
      final details = findSetComputeUnitPriceInstructionIndexAndMicroLamports(
        updated,
      );

      expect(updated.instructions, hasLength(1));
      expect(details!.microLamports, equals(BigInt.from(700)));
    });

    test('sets and updates compute unit price', () {
      final message = setTransactionMessageComputeUnitPrice(
        BigInt.from(500),
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final updated = updateOrAppendSetComputeUnitPriceInstruction(
        (BigInt? previousMicroLamports) => previousMicroLamports! * BigInt.two,
        message,
      );
      final details = findSetComputeUnitPriceInstructionIndexAndMicroLamports(
        updated,
      );

      expect(updated.instructions, hasLength(1));
      expect(details!.index, equals(0));
      expect(details.microLamports, equals(BigInt.from(1000)));
    });

    test('returns original message when compute unit price is unchanged', () {
      final message = setTransactionMessageComputeUnitPrice(
        BigInt.from(500),
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final updated = updateOrAppendSetComputeUnitPriceInstruction(
        BigInt.from(500),
        message,
      );

      expect(identical(updated, message), isTrue);
    });
  });
}
