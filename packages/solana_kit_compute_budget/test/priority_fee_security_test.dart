import 'dart:typed_data';

import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('unsigned priority fee security', () {
    for (final (bytes, expected) in [
      ([0, 0, 0, 0, 0, 0, 0, 128], BigInt.one << 63),
      (List<int>.filled(8, 255), (BigInt.one << 64) - BigInt.one),
      ([1, 0, 0, 0, 0, 0, 32, 0], (BigInt.one << 53) + BigInt.one),
    ]) {
      test('preserves the unsigned wire price $expected', () {
        final message = _messageWithPrice(bytes);
        final details = findSetComputeUnitPriceInstructionIndexAndMicroLamports(
          message,
        );

        expect(details!.microLamports, expected);
        expect(details.microLamports.isNegative, isFalse);
      });
    }

    test('an attacker-supplied high price cannot pass an upper fee cap', () {
      final message = _messageWithPrice(List<int>.filled(8, 255));
      final maximumMicroLamports = BigInt.from(1000000);
      final details = findSetComputeUnitPriceInstructionIndexAndMicroLamports(
        message,
      )!;

      // Wallets must compare the actual unsigned on-chain price to their cap.
      final passesFeeCap = details.microLamports <= maximumMicroLamports;
      expect(passesFeeCap, isFalse);
    });

    test('fee-capping updaters receive the unsigned existing price', () {
      final message = _messageWithPrice(List<int>.filled(8, 255));
      final maximumMicroLamports = BigInt.from(1000000);
      final updated = updateOrAppendSetComputeUnitPriceInstruction(
        (BigInt? previous) =>
            previous! > maximumMicroLamports ? maximumMicroLamports : previous,
        message,
      );
      final details = findSetComputeUnitPriceInstructionIndexAndMicroLamports(
        updated,
      )!;

      expect(details.microLamports, maximumMicroLamports);
      expect(updated.instructions, hasLength(1));
    });
  });
}

TransactionMessage _messageWithPrice(List<int> bytes) =>
    createTransactionMessage(version: TransactionVersion.v0).appendInstruction(
      Instruction(
        programAddress: computeBudgetProgramAddress,
        data: Uint8List.fromList([3, ...bytes]),
      ),
    );
