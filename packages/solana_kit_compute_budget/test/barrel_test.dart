import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:test/test.dart';

void main() {
  group('barrel exports', () {
    test('program address is accessible', () {
      expect(computeBudgetProgramAddress.value, isNotEmpty);
    });

    test('instruction enum has all variants', () {
      expect(ComputeBudgetInstruction.values, hasLength(5));
    });

    test('instruction builders are callable', () {
      final limitIx = getSetComputeUnitLimitInstruction(
        programAddress: computeBudgetProgramAddress,
        units: 100000,
      );
      expect(limitIx.programAddress, equals(computeBudgetProgramAddress));

      final priceIx = getSetComputeUnitPriceInstruction(
        programAddress: computeBudgetProgramAddress,
        microLamports: BigInt.from(1000),
      );
      expect(priceIx.programAddress, equals(computeBudgetProgramAddress));

      final heapIx = getRequestHeapFrameInstruction(
        programAddress: computeBudgetProgramAddress,
        bytes: 32768,
      );
      expect(heapIx.programAddress, equals(computeBudgetProgramAddress));

      final dataLimitIx = getSetLoadedAccountsDataSizeLimitInstruction(
        programAddress: computeBudgetProgramAddress,
        accountDataSizeLimit: 65536,
      );
      expect(dataLimitIx.programAddress, equals(computeBudgetProgramAddress));
    });
  });
}
