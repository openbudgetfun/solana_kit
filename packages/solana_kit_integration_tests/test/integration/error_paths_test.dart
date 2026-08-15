/// On-chain error-path integration tests against SurfPool.
///
/// These exercise *failing* transactions to prove the Dart client surfaces
/// the real on-chain error (via `getSolanaErrorFromTransactionError`) instead
/// of masking it — e.g. an insufficient-funds transfer and a compute-unit
/// limit set too low for the instructions that follow.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test(
    'transfer with insufficient funds fails with the on-chain error',
    () async {
      // A signer with a real account but too few lamports cannot pay for a
      // transfer — the system program returns the insufficient-funds error.
      final broke = generateKeyPairSigner();
      final recipient = generateKeyPairSigner();
      await env.surfnet.fundSol(broke.address, 1);

      await expectLater(
        env.sendInstructions(
          [
            getTransferSolInstruction(
              programAddress: systemProgramAddress,
              source: broke.address,
              destination: recipient.address,
              amount: BigInt.from(1_000_000),
            ),
          ],
          extraSigners: [broke],
        ),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.context['cause'],
            'cause',
            isA<SolanaError>().having(
              (cause) => cause.code,
              'code',
              // The system program's InsufficientFunds error (code 1) surfaces
              // as a custom program error.
              SolanaErrorCode.instructionErrorCustom,
            ),
          ),
        ),
      );
    },
  );

  test('compute unit limit set too low fails the transaction', () async {
    const memo = 'this memo needs more than 1 compute unit';
    await expectLater(
      env.sendInstructions([
        getSetComputeUnitLimitInstruction(
          programAddress: computeBudgetProgramAddress,
          units: 1,
        ),
        getAddMemoInstruction(
          programAddress: memoProgramAddress,
          memo: memo,
        ),
      ]),
      throwsA(isA<SolanaError>()),
    );
  });
}
