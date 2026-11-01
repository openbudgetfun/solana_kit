import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:test/test.dart';

void main() {
  group('HeliusConfig', () {
    test('rejects a blank API key', () {
      for (final key in <String>['', '   ']) {
        expect(
          () => HeliusConfig(apiKey: key),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.heliusApiKeyRequired,
            ),
          ),
          reason: 'a blank key of ${key.length} chars must be rejected',
        );
      }
    });

    test('accepts a non-blank API key and redacts it in toString', () {
      final config = HeliusConfig(apiKey: 'secret-key');
      expect(config.apiKey, equals('secret-key'));
      expect(config.toString(), isNot(contains('secret-key')));
    });
  });

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
      expect(helius.kitRpc, isNotNull);
    });

    test('kitRpc sends standard Solana RPC requests', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getSlot');
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': 123}),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(await helius.kitRpc.getSlot().send(), BigInt.from(123));
    });

    test('mevProtect appends the flag to RPC and sender URLs', () {
      final config = HeliusConfig(apiKey: 'abc', mevProtect: true);

      expect(
        config.rpcUrl,
        'https://mainnet-beta.helius-rpc.com/?api-key=abc&mev-protect=true',
      );
      expect(
        config.senderBaseUrl,
        'https://mainnet.helius-rpc.com/?api-key=abc&mev-protect=true',
      );
      expect(config.mevProtect, isTrue);
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
