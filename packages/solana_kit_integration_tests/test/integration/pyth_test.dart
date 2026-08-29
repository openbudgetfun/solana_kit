/// Pyth transaction integration tests against Surfpool.
///
/// These verify that security-sensitive account roles survive the full
/// instruction-to-transaction path. The receiver program itself is not
/// deployed: a missing required signature must be rejected before submission.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
  });

  tearDownAll(() => env.dispose());

  test('post-update requires the price-update account signature', () async {
    final priceUpdateAccount = generateKeyPairSigner();
    final instruction = await getPostUpdateAtomicInstruction(
      payer: env.payer.address,
      vaa: Uint8List(0),
      update: MerklePriceUpdate(message: Uint8List(0), proof: const []),
      priceUpdateAccount: priceUpdateAccount.address,
      guardianSet: env.payer.address,
      config: env.payer.address,
      treasury: env.payer.address,
    );

    await expectLater(
      env.sendInstructions([instruction]),
      throwsA(
        isA<SolanaError>()
            .having(
              (error) => error.code,
              'code',
              SolanaErrorCode.transactionSignaturesMissing,
            )
            .having(
              (error) => error.context['addresses'],
              'missing addresses',
              contains(priceUpdateAccount.address.value),
            ),
      ),
    );
  });
}
