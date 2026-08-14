/// On-chain integration tests for the Compute Budget program client against
/// SurfPool.
///
/// Compute Budget instructions are prepend-only modifiers that affect the
/// transaction they are included in. They confirm successfully when paired
/// with a real instruction (here, a memo).
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
  var surfPoolRunning = false;

  setUpAll(() async {
    if (!await isSurfPoolRunning()) return;
    surfPoolRunning = true;
    env = await IntegrationTestEnv.connect();
  });

  test(
    'setComputeUnitLimit and setComputeUnitPrice confirm on-chain',
    () async {
      if (!surfPoolRunning) return;
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
          memo: 'compute-budget integration',
        ),
      ]);
      expect(signature.value, isNotEmpty);
    },
  );
}
