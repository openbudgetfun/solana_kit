import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
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
  });
}
