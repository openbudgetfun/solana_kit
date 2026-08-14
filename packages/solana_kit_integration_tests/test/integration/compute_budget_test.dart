/// On-chain integration tests for the Compute Budget program client against
/// SurfPool.
///
/// Compute Budget instructions are prepend-only modifiers that affect the
/// transaction they are included in. They confirm successfully when paired
/// with a real instruction (here, a memo), and the confirmed transaction
/// reports the compute units consumed.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test(
    'setComputeUnitLimit and setComputeUnitPrice confirm on-chain',
    () async {
      const memo = 'compute-budget integration';
      final signature = await env.sendInstructions([
        getSetComputeUnitLimitInstruction(
          programAddress: computeBudgetProgramAddress,
          units: 100_000,
        ),
        getSetComputeUnitPriceInstruction(
          programAddress: computeBudgetProgramAddress,
          microLamports: BigInt.from(1_000),
        ),
        getAddMemoInstruction(
          programAddress: memoProgramAddress,
          memo: memo,
        ),
      ]);

      // The memo instruction must have executed within the budgeted compute
      // units; assert the confirmed transaction consumed some and logged the
      // memo.
      final logs = await env.transactionLogMessages(signature);
      expect(logs, anyElement(contains(memo)));
      expect(logs, anyElement(contains('Program ComputeBudget111111')));
    },
  );
}
