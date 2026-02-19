import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('createHelius', () {
    test('creates a HeliusClient with default config', () {
      final helius = createHelius(const HeliusConfig(apiKey: 'test-key'));
      expect(helius, isNotNull);
      expect(helius.config.apiKey, 'test-key');
      expect(helius.config.cluster, HeliusCluster.mainnet);
    });

    test('creates a HeliusClient with devnet config', () {
      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key', cluster: HeliusCluster.devnet),
      );
      expect(helius.config.cluster, HeliusCluster.devnet);
    });

    test('exposes all sub-clients', () {
      final helius = createHelius(const HeliusConfig(apiKey: 'test-key'));
      expect(helius.das, isNotNull);
      expect(helius.priorityFee, isNotNull);
      expect(helius.rpcV2, isNotNull);
      expect(helius.enhanced, isNotNull);
      expect(helius.webhooks, isNotNull);
      expect(helius.zk, isNotNull);
      expect(helius.transactions, isNotNull);
      expect(helius.staking, isNotNull);
      expect(helius.wallet, isNotNull);
      expect(helius.websocket, isNotNull);
      expect(helius.auth, isNotNull);
    });

    test('HeliusConfig computes correct URLs for mainnet', () {
      const config = HeliusConfig(apiKey: 'abc');
      expect(config.rpcUrl, 'https://mainnet-beta.helius-rpc.com/?api-key=abc');
      expect(config.restBaseUrl, 'https://api.helius.xyz');
      expect(config.wsUrl, 'wss://mainnet-beta.helius-rpc.com/?api-key=abc');
    });

    test('HeliusConfig computes correct URLs for devnet', () {
      const config = HeliusConfig(apiKey: 'abc', cluster: HeliusCluster.devnet);
      expect(config.rpcUrl, 'https://devnet.helius-rpc.com/?api-key=abc');
      expect(config.restBaseUrl, 'https://api-devnet.helius.xyz');
    });
  });
}
