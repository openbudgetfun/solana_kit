/// Basic RPC integration tests against a local validator (SurfPool).
///
/// These tests require a running SurfPool instance at localhost:8899.
/// They are run in CI by the `test:integration` workspace script.
///
/// Run with: dart test packages/solana_kit/test/integration/rpc_basic_test.dart
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

/// Default RPC URL for a local SurfPool validator.
const _localRpcUrl = 'http://localhost:8899';

void main() {
  late final rpc = createSolanaRpc(url: _localRpcUrl, allowInsecureHttp: true);

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
      final surfnet = Surfnet.connect(rpcUrl: Uri.parse(_localRpcUrl));

      try {
        final before = await rpc.getBalanceValue(signer.address).send();
        expect(before.value.value, equals(BigInt.zero));

        await surfnet.fundSol(signer.address, 1000000000);

        final after = await rpc.getBalanceValue(signer.address).send();
        expect(after.value.value, greaterThan(BigInt.zero));
      } finally {
        await surfnet.stop();
      }
    });
  });
}
