/// On-chain integration tests for compressed NFT operations.
///
/// Each run starts its own Surfpool via the Surfpool SDK (auto-allocated
/// ports), so no external validator is needed and parallel runs are isolated.
/// The full create-tree → mint → transfer → burn lifecycle is covered by the
/// `solana_kit_integration_tests` package; this file keeps the encoding-level
/// builder coverage plus basic RPC sanity checks against a live validator.
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  late final Surfnet surfnet;
  late final rpc = createSolanaRpc(
    url: surfnet.rpcUrl,
    allowInsecureHttp: true,
  );

  setUpAll(() async {
    surfnet = await Surfnet.start();
  });

  tearDownAll(() => surfnet.stop());

  group('compressed NFT on-chain', () {
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
      final slot = await rpc.getSlot().send();
      expect(slot, greaterThanOrEqualTo(BigInt.zero));
    });

    test('getBlockHeight returns a non-negative block height', () async {
      final height = await rpc.getBlockHeight().send();
      expect(height, greaterThanOrEqualTo(BigInt.zero));
    });
  });
}
