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
      final limitIx = getSetComputeUnitLimitInstruction(units: 100000);
      expect(limitIx.programAddress, equals(computeBudgetProgramAddress));

      final priceIx = getSetComputeUnitPriceInstruction(
        microLamports: BigInt.from(1000),
      );
      expect(priceIx.programAddress, equals(computeBudgetProgramAddress));

      final heapIx = getRequestHeapFrameInstruction(bytes: 32768);
      expect(heapIx.programAddress, equals(computeBudgetProgramAddress));

      final dataLimitIx = getSetLoadedAccountsDataSizeLimitInstruction(
        accountDataSizeLimit: 65536,
      );
      expect(dataLimitIx.programAddress, equals(computeBudgetProgramAddress));
    });
  });
}
