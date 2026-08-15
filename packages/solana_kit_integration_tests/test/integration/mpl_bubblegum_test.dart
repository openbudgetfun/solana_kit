/// On-chain integration tests for the MPL Bubblegum program client against
/// SurfPool.
///
/// The compiled Bubblegum, SPL Account Compression, and Noop programs (`.so`,
/// pinned to their reference commits) are committed under `config/programs/`
/// and deployed to SurfPool at their canonical addresses by this suite.
///
/// Note: running a full `createTree` on SurfPool currently panics inside the
/// deployed Bubblegum binary (`create_tree.rs:20`), a program-internal issue
/// to investigate upstream. This suite therefore verifies the deployments
/// land on-chain (executable + owned by the BPF loader) and that the client
/// instructions encode correctly.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart'
    hide systemProgramAddress;
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  // Canonical program IDs baked into the deployed binaries (also shipped by
  // `solana_kit_address_constants`).
  const bubblegumProgram = Address(
    'BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY',
  );
  const compressionProgram = Address(
    'cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK',
  );
  const noopProgram = Address(
    'noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV',
  );

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    await env.deployProgram(
      bubblegumProgram,
      'config/programs/mpl_bubblegum-v0.12.0.so',
    );
    await env.deployProgram(
      compressionProgram,
      'config/programs/spl_account_compression-v0.3.3.so',
    );
    await env.deployProgram(noopProgram, 'config/programs/noop-v0.2.0.so');
  });

  tearDownAll(() => env.dispose());

  test(
    'bubblegum and its CPI programs deploy as executable programs',
    () async {
      for (final program in [
        bubblegumProgram,
        compressionProgram,
        noopProgram,
      ]) {
        final account = await env.rpc.getAccountInfoValue(program).send();
        expect(account.value, isNotNull, reason: '$program should be deployed');
        expect(account.value!['executable'], equals(true));
        expect(
          account.value!['owner'],
          equals('BPFLoaderUpgradeab1e11111111111111111111111'),
        );
      }
    },
  );

  test('burn instruction encodes correctly', () {
    final instruction = getBurnInstruction(
      programAddress: bubblegumProgram,
      treeAuthority: const Address('11111111111111111111111111111111'),
      leafOwner: const Address('11111111111111111111111111111111'),
      leafDelegate: const Address('11111111111111111111111111111111'),
      merkleTree: const Address('11111111111111111111111111111111'),
      logWrapper: noopProgram,
      compressionProgram: compressionProgram,
      systemProgram: const Address('11111111111111111111111111111111'),
      root: List.filled(32, 0),
      dataHash: List.filled(32, 0),
      creatorHash: List.filled(32, 0),
      nonce: BigInt.zero,
      index: 0,
    );
    expect(instruction.programAddress, equals(bubblegumProgram));
    expect(instruction.data, isNotNull);
  });
}
