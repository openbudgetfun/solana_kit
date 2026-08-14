/// On-chain integration tests for the Memo program client against SurfPool.
///
/// Run via the `test:integration` workspace script (which starts SurfPool) or
/// directly after `devenv shell -- surfpool start`.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
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

  test('addMemo instruction confirms on-chain', () async {
    if (!surfPoolRunning) return;
    final signature = await env.sendInstructions([
      getAddMemoInstruction(
        programAddress: memoProgramAddress,
        memo: 'hello surfpool',
      ),
    ]);
    expect(signature.value, isNotEmpty);
  });

  test('parsed addMemo instruction round-trips the memo text', () async {
    if (!surfPoolRunning) return;
    final instruction = getAddMemoInstruction(
      programAddress: memoProgramAddress,
      memo: 'solana-kit dart',
    );
    final parsed = parseAddMemoInstruction(instruction);
    expect(parsed.memo, equals('solana-kit dart'));
  });
}
