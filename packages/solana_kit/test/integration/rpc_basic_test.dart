// ignore_for_file: public_member_api_docs
/// Basic RPC integration tests against a local validator (SurfPool).
///
/// These tests require a running SurfPool instance at localhost:8899.
/// They are NOT run in CI automatically.
///
/// Run with: dart test integration_test/rpc_basic_test.dart
@TestOn('vm')
@Tags(['integration'])
library;

import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

/// Default RPC URL for a local SurfPool validator.
const _localRpcUrl = 'http://localhost:8899';

void main() {
  late final rpc = createSolanaRpc(
    url: _localRpcUrl,
    allowInsecureHttp: true,
  );

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
      expect(
        result.value.lastValidBlockHeight,
        greaterThan(BigInt.zero),
      );
    });

    test('getBalance for system program returns non-null', () async {
      const systemProgram = Address('11111111111111111111111111111111');
      final result = await rpc.getBalanceValue(systemProgram).send();
      expect(result.value, isNotNull);
    });
  });

  group('airdrop and balance', () {
    test('requestAirdrop increases balance', () async {
      final signer = generateKeyPairSigner();

      // Check initial balance
      final before = await rpc.getBalanceValue(signer.address).send();
      expect(before.value.value, equals(BigInt.zero));

      // Request airdrop
      final airdropAmount = Lamports(BigInt.from(1000000000)); // 1 SOL
      await rpc.requestAirdrop(signer.address, airdropAmount).send();

      // Wait a moment for confirmation
      await Future<void>.delayed(const Duration(seconds: 2));

      // Check new balance
      final after = await rpc.getBalanceValue(signer.address).send();
      expect(after.value.value, greaterThan(BigInt.zero));
    });
  });
}
