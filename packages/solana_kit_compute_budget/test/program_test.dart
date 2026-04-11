import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  group('identifyComputeBudgetInstruction', () {
    test('identifies RequestUnits (disc 0)', () {
      final data = Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(
        identifyComputeBudgetInstruction(data),
        equals(ComputeBudgetInstruction.requestUnits),
      );
    });

    test('identifies RequestHeapFrame (disc 1)', () {
      final data = Uint8List.fromList([1, 0, 0, 0, 0]);
      expect(
        identifyComputeBudgetInstruction(data),
        equals(ComputeBudgetInstruction.requestHeapFrame),
      );
    });

    test('identifies SetComputeUnitLimit (disc 2)', () {
      final data = Uint8List.fromList([2, 0, 0, 0, 0]);
      expect(
        identifyComputeBudgetInstruction(data),
        equals(ComputeBudgetInstruction.setComputeUnitLimit),
      );
    });

    test('identifies SetComputeUnitPrice (disc 3)', () {
      final data = Uint8List.fromList([3, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(
        identifyComputeBudgetInstruction(data),
        equals(ComputeBudgetInstruction.setComputeUnitPrice),
      );
    });

    test('identifies SetLoadedAccountsDataSizeLimit (disc 4)', () {
      final data = Uint8List.fromList([4, 0, 0, 0, 0]);
      expect(
        identifyComputeBudgetInstruction(data),
        equals(ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit),
      );
    });

    test('throws on empty data', () {
      expect(
        () => identifyComputeBudgetInstruction(Uint8List(0)),
        throwsArgumentError,
      );
    });

    test('throws on unknown discriminator', () {
      final data = Uint8List.fromList([255]);
      expect(
        () => identifyComputeBudgetInstruction(data),
        throwsArgumentError,
      );
    });
  });

  group('parseComputeBudgetInstruction', () {
    test('parses SetComputeUnitLimit instruction', () {
      final ix = getSetComputeUnitLimitInstruction(units: 300000);
      final parsed = parseComputeBudgetInstruction(ix);
      expect(parsed, isA<ParsedSetComputeUnitLimit>());
      final typed = parsed as ParsedSetComputeUnitLimit;
      expect(
        typed.instructionType,
        equals(ComputeBudgetInstruction.setComputeUnitLimit),
      );
      expect(typed.data.units, equals(300000));
    });

    test('parses SetComputeUnitPrice instruction', () {
      final ix = getSetComputeUnitPriceInstruction(
        microLamports: BigInt.from(99999),
      );
      final parsed = parseComputeBudgetInstruction(ix);
      expect(parsed, isA<ParsedSetComputeUnitPrice>());
      final typed = parsed as ParsedSetComputeUnitPrice;
      expect(
        typed.instructionType,
        equals(ComputeBudgetInstruction.setComputeUnitPrice),
      );
      expect(typed.data.microLamports, equals(BigInt.from(99999)));
    });

    test('parses RequestHeapFrame instruction', () {
      final ix = getRequestHeapFrameInstruction(bytes: 65536);
      final parsed = parseComputeBudgetInstruction(ix);
      expect(parsed, isA<ParsedRequestHeapFrame>());
      final typed = parsed as ParsedRequestHeapFrame;
      expect(
        typed.instructionType,
        equals(ComputeBudgetInstruction.requestHeapFrame),
      );
      expect(typed.data.bytes, equals(65536));
    });

    test('parses SetLoadedAccountsDataSizeLimit instruction', () {
      final ix = getSetLoadedAccountsDataSizeLimitInstruction(
        accountDataSizeLimit: 32000,
      );
      final parsed = parseComputeBudgetInstruction(ix);
      expect(parsed, isA<ParsedSetLoadedAccountsDataSizeLimit>());
      final typed = parsed as ParsedSetLoadedAccountsDataSizeLimit;
      expect(
        typed.instructionType,
        equals(ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit),
      );
      expect(typed.data.accountDataSizeLimit, equals(32000));
    });

    test('throws on instruction with no data', () {
      const ix = Instruction(
        programAddress: computeBudgetProgramAddress,
        accounts: [],
      );
      expect(
        () => parseComputeBudgetInstruction(ix),
        throwsArgumentError,
      );
    });

    test('throws on instruction with unknown discriminator', () {
      final ix = Instruction(
        programAddress: computeBudgetProgramAddress,
        accounts: const [],
        data: Uint8List.fromList([99, 0, 0, 0]),
      );
      expect(
        () => parseComputeBudgetInstruction(ix),
        throwsArgumentError,
      );
    });
  });

  group('custom program address', () {
    test('SetComputeUnitLimit uses custom address when provided', () {
      const custom = Address('11111111111111111111111111111111');
      final ix = getSetComputeUnitLimitInstruction(
        units: 100,
        programAddress: custom,
      );
      expect(ix.programAddress, equals(custom));
    });

    test('SetComputeUnitPrice uses custom address when provided', () {
      const custom = Address('11111111111111111111111111111111');
      final ix = getSetComputeUnitPriceInstruction(
        microLamports: BigInt.one,
        programAddress: custom,
      );
      expect(ix.programAddress, equals(custom));
    });
  });
}
