/// Basic RPC integration tests against a local Surfpool instance.
///
/// Each run starts its own Surfpool via the Surfpool SDK (auto-allocated
/// ports), so no external validator is needed and parallel runs are isolated.
///
/// Run with: dart test packages/solana_kit/test/integration/rpc_basic_test.dart
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit/solana_kit.dart';
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

  group('basic RPC methods', () {
    test('getSlot returns a non-negative slot', () async {
      final slot = await rpc.getSlot().send();
      expect(slot, greaterThanOrEqualTo(BigInt.zero));
    });

    test('getBlockHeight returns a non-negative block height', () async {
      final height = await rpc.getBlockHeight().send();
      expect(height, greaterThanOrEqualTo(BigInt.zero));
    });

    test('getLatestBlockhash returns a valid blockhash', () async {
      final result = await rpc.getLatestBlockhashValue().send();
      expect(result.value.blockhash.value, isNotEmpty);
      expect(result.value.lastValidBlockHeight, greaterThan(BigInt.zero));
    });

    test('getBalance for system program returns non-null', () async {
      const systemProgram = Address('11111111111111111111111111111111');
      final result = await rpc.getBalanceValue(systemProgram).send();

      expect(result.value, isNotNull);
    });
  });

  group('airdrop and balance', () {
    test('fundSol increases balance', () async {
      final signer = generateKeyPairSigner();

      final before = await rpc.getBalanceValue(signer.address).send();
      expect(before.value.value, equals(BigInt.zero));

      await surfnet.fundSol(signer.address, 1000000000);

      final after = await rpc.getBalanceValue(signer.address).send();
      expect(after.value.value, greaterThan(BigInt.zero));
    });
  });
}
