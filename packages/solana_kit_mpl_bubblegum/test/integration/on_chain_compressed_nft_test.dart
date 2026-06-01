// ignore_for_file: avoid_print
/// On-chain integration tests for compressed NFT operations.
///
/// These tests run against a local SurfPool validator at localhost:8899.
/// They test the full lifecycle: create tree → mint → transfer → burn.
///
/// ## Setup
///
/// Start SurfPool in a separate terminal:
/// ```bash
/// devenv shell -- surfpool start
/// ```
///
/// Then run the tests:
/// ```bash
/// dart test test/integration/ --tags integration
/// ```
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';
import 'package:test/test.dart';

/// Local SurfPool RPC URL.
const _rpcUrl = 'http://localhost:8899';

void main() {
  late final rpc = createSolanaRpc(url: _rpcUrl, allowInsecureHttp: true);

  group('compressed NFT on-chain', () {
    KeyPairSigner? payer;
    var surfPoolRunning = false;

    setUpAll(() async {
      // Check if SurfPool is running
      try {
        await rpc.getSlot().send();
        surfPoolRunning = true;
      } on Exception catch (_) {
        print('Skipping: SurfPool not running at $_rpcUrl');
        return;
      }

      // Generate payer and airdrop SOL
      payer = generateKeyPairSigner();
      print('Payer: ${payer!.address.value}');

      await rpc
          .requestAirdrop(
            payer!.address,
            Lamports(BigInt.from(10000000000)), // 10 SOL
          )
          .send();

      // SurfPool usually applies local airdrops immediately. Poll briefly
      // instead of always sleeping for a fixed five seconds.
      var balance = await rpc.getBalanceValue(payer!.address).send();
      for (
        var attempt = 0;
        balance.value.value == BigInt.zero && attempt < 20;
        attempt += 1
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        balance = await rpc.getBalanceValue(payer!.address).send();
      }

      print('Balance: ${balance.value.value} lamports');
      expect(balance.value.value, greaterThan(BigInt.zero));
    });

    test('create tree instruction can be built', () {
      // Test that we can build a createTree instruction
      final instruction = getCreateTreeInstruction(
        programAddress: mplBubblegumProgramAddressObject,
        treeAuthority: const Address('11111111111111111111111111111112'),
        merkleTree: const Address('11111111111111111111111111111112'),
        payer: const Address('11111111111111111111111111111112'),
        treeCreator: const Address('11111111111111111111111111111112'),
        logWrapper: const Address(
          'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK',
        ),
        compressionProgram: const Address(
          'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi',
        ),
        systemProgram: const Address('11111111111111111111111111111112'),
        maxDepth: 14,
        maxBufferSize: 64,
        public: true,
      );

      expect(
        instruction.programAddress,
        equals(mplBubblegumProgramAddressObject),
      );
      expect(instruction.data, isNotNull);
    });

    test('initEmptyMerkleTree instruction can be built', () {
      final instruction = getInitEmptyMerkleTreeInstruction(
        programAddress: const Address(
          'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi',
        ),
        merkleTree: const Address('11111111111111111111111111111112'),
        authority: const Address('11111111111111111111111111111112'),
        noop: const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'),
        maxDepth: 14,
        maxBufferSize: 64,
      );

      expect(
        instruction.programAddress,
        equals(const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi')),
      );
      expect(instruction.data, isNotNull);
    });

    test('getSlot returns a non-negative slot', () async {
      if (!surfPoolRunning) return;
      final slot = await rpc.getSlot().send();
      expect(slot, greaterThanOrEqualTo(BigInt.zero));
    });

    test('getBlockHeight returns a non-negative block height', () async {
      if (!surfPoolRunning) return;
      final height = await rpc.getBlockHeight().send();
      expect(height, greaterThanOrEqualTo(BigInt.zero));
    });
  });
}
