/// On-chain integration tests for the System program client against SurfPool.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;
  var surfPoolRunning = false;

  setUpAll(() async {
    if (!await isSurfPoolRunning()) return;
    surfPoolRunning = true;
    env = await IntegrationTestEnv.connect();
  });

  test('transferSol moves lamports between accounts', () async {
    if (!surfPoolRunning) return;
    final recipient = generateKeyPairSigner();
    await env.surfnet.fundSol(env.payer.address, 5_000_000_000);

    final before = await env.rpc.getBalanceValue(env.payer.address).send();
    final beforeBalance = before.value.value;

    await env.sendInstructions([
      getTransferSolInstruction(
        programAddress: systemProgramAddress,
        source: env.payer.address,
        destination: recipient.address,
        amount: BigInt.from(1_000_000),
      ),
    ]);

    final recipientBalance = await env.rpc
        .getBalanceValue(recipient.address)
        .send();
    expect(recipientBalance.value.value, equals(BigInt.from(1_000_000)));

    final after = await env.rpc.getBalanceValue(env.payer.address).send();
    expect(after.value.value, lessThan(beforeBalance));
  });
}
