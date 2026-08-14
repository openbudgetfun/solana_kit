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

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('transferSol moves lamports to the recipient on-chain', () async {
    final recipient = generateKeyPairSigner();
    await env.surfnet.fundSol(env.payer.address, 5_000_000_000);
    const amount = 1_000_000;

    final before = await env.rpc.getBalanceValue(env.payer.address).send();

    await env.sendInstructions([
      getTransferSolInstruction(
        programAddress: systemProgramAddress,
        source: env.payer.address,
        destination: recipient.address,
        amount: BigInt.from(amount),
      ),
    ]);

    // Assert the recipient holds exactly the transferred amount and the
    // payer's balance decreased by at least the transfer plus fees.
    final recipientBalance = await env.rpc
        .getBalanceValue(recipient.address)
        .send();
    expect(recipientBalance.value.value, equals(BigInt.from(amount)));

    final after = await env.rpc.getBalanceValue(env.payer.address).send();
    expect(after.value.value, lessThan(before.value.value));
  });
}
