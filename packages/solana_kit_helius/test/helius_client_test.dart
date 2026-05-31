import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('createHelius', () {
    test('creates a HeliusClient with default config', () {
      final helius = createHelius(HeliusConfig(apiKey: 'test-key'));
      expect(helius, isNotNull);
      expect(helius.config.apiKey, 'test-key');
      expect(helius.config.cluster, HeliusCluster.mainnet);
    });

    test('creates a HeliusClient with devnet config', () {
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key', cluster: HeliusCluster.devnet),
      );
      expect(helius.config.cluster, HeliusCluster.devnet);
    });

    test('exposes all sub-clients', () {
      final helius = createHelius(HeliusConfig(apiKey: 'test-key'));
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
      final config = HeliusConfig(apiKey: 'abc');
      expect(config.rpcUrl, 'https://mainnet-beta.helius-rpc.com/?api-key=abc');
      expect(config.restBaseUrl, 'https://api-mainnet.helius-rpc.com');
      expect(config.wsUrl, 'wss://mainnet-beta.helius-rpc.com/?api-key=abc');
    });

    test('HeliusConfig computes correct URLs for devnet', () {
      final config = HeliusConfig(apiKey: 'abc', cluster: HeliusCluster.devnet);
      expect(config.rpcUrl, 'https://devnet.helius-rpc.com/?api-key=abc');
      expect(config.restBaseUrl, 'https://api-devnet.helius.xyz');
    });

    test('HeliusConfig.toString() redacts the API key', () {
      final config = HeliusConfig(apiKey: 'sk_live_abc123');
      final output = config.toString();

      expect(output, contains('****123'));
      expect(output, isNot(contains('sk_live_abc123')));
      expect(output, contains('HeliusConfig'));
      expect(output, contains('mainnet'));
    });

    test('HeliusConfig.toString() redacts API key for devnet', () {
      final config = HeliusConfig(
        apiKey: 'secret_key_xyz',
        cluster: HeliusCluster.devnet,
      );
      final output = config.toString();

      expect(output, contains('****xyz'));
      expect(output, isNot(contains('secret_key_xyz')));
      expect(output, contains('devnet'));
    });

    test('HeliusConfig.apiKey returns the raw key', () {
      final config = HeliusConfig(apiKey: 'sk_live_abc123');
      expect(config.apiKey, 'sk_live_abc123');
    });

    test('HeliusConfig.restUrl includes api key', () {
      final config = HeliusConfig(apiKey: 'test_key');
      expect(
        config.restUrl,
        'https://api-mainnet.helius-rpc.com/v0?api-key=test_key',
      );
    });

    test('HeliusConfig.restUrl includes devnet api key', () {
      final config = HeliusConfig(
        apiKey: 'dev_key',
        cluster: HeliusCluster.devnet,
      );
      expect(
        config.restUrl,
        'https://api-devnet.helius.xyz/v0?api-key=dev_key',
      );
    });
  });
}
