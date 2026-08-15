/// On-chain integration tests for the BPF Loader (upgradeable) program client
/// against SurfPool.
///
/// Creates and initializes a program buffer account, then verifies it exists
/// on-chain and is owned by the upgradeable BPF Loader. (Full program deploy
/// requires compiled BPF bytes, which is out of scope for this suite.)
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';
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

  test(
    'initializeBuffer creates a buffer account owned by the BPF loader',
    () async {
      final buffer = generateKeyPairSigner();
      // A 37-byte buffer account (authority header) is rent-exempt around
      // 1_148_400 lamports; fund a little extra to be safe.
      const bufferRent = 1_500_000;

      await env.sendInstructions(
        [
          getCreateAccountInstruction(
            instructionProgramAddress: systemProgramAddress,
            payer: env.payer.address,
            newAccount: buffer.address,
            lamports: BigInt.from(bufferRent),
            space: BigInt.from(37),
            programAddress: bpfLoaderUpgradeableProgramAddress,
          ),
          getInitializeBufferInstruction(
            programAddress: bpfLoaderUpgradeableProgramAddress,
            sourceAccount: buffer.address,
            bufferAuthority: env.payer.address,
          ),
        ],
        extraSigners: [buffer],
      );

      final account = await env.rpc.getAccountInfoValue(buffer.address).send();
      expect(account.value, isNotNull);
      expect(
        account.value!['owner'],
        equals(bpfLoaderUpgradeableProgramAddress.value),
      );
    },
  );
}
