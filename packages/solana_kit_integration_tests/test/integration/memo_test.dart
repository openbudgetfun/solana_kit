/// On-chain integration tests for the Memo program client against SurfPool.
///
/// Run via the `test:integration` workspace script (which starts SurfPool) or
/// directly — `IntegrationTestEnv.create` starts a SurfPool instance when one
/// is not already running.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('addMemo instruction lands on-chain and logs the memo', () async {
    const memo = 'hello surfpool';
    final signature = await env.sendInstructions([
      getAddMemoInstruction(programAddress: memoProgramAddress, memo: memo),
    ]);

    // The memo program echoes the memo in its program log; assert the
    // confirmed transaction actually contains it on-chain.
    final logs = await env.transactionLogMessages(signature);
    expect(logs, anyElement(contains(memo)));
  });

  test('parsed addMemo instruction round-trips the memo text', () {
    const memo = 'solana-kit dart';
    final instruction = getAddMemoInstruction(
      programAddress: memoProgramAddress,
      memo: memo,
    );
    expect(parseAddMemoInstruction(instruction).memo, equals(memo));
  });
}
