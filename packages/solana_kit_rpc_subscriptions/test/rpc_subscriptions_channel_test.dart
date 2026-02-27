import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultRpcSubscriptionsChannelConfig', () {
    test('uses documented default values', () {
      const config = DefaultRpcSubscriptionsChannelConfig(
        url: 'ws://localhost:8900',
      );

      expect(config.url, 'ws://localhost:8900');
      expect(config.allowInsecureWs, isFalse);
      expect(config.intervalMs, 5000);
      expect(config.maxSubscriptionsPerChannel, 100);
      expect(config.minChannels, 1);
      expect(config.sendBufferHighWatermark, 131072);
    });

    test('stores insecure override flag', () {
      const config = DefaultRpcSubscriptionsChannelConfig(
        url: 'ws://localhost:8900',
        allowInsecureWs: true,
      );
      expect(config.allowInsecureWs, isTrue);
    });
  });

  group('channel creator factories', () {
    test('accept ws/wss URLs (case-insensitive) and return creators', () {
      final wsCreator = createDefaultRpcSubscriptionsChannelCreator(
        const DefaultRpcSubscriptionsChannelConfig(url: 'ws://localhost:8900'),
      );
      final wssCreator = createDefaultSolanaRpcSubscriptionsChannelCreator(
        const DefaultRpcSubscriptionsChannelConfig(
          url: 'WSS://api.mainnet-beta.solana.com',
        ),
      );

      expect(wsCreator, isA<Function>());
      expect(wssCreator, isA<Function>());
    });

    test('rejects unsupported URL schemes', () {
      expect(
        () => createDefaultRpcSubscriptionsChannelCreator(
          const DefaultRpcSubscriptionsChannelConfig(
            url: 'https://api.mainnet-beta.solana.com',
          ),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message.toString(),
            'message',
            allOf(contains("'ws'"), contains("'wss'"), contains('https')),
          ),
        ),
      );
    });

    test('rejects malformed URLs with no protocol prefix', () {
      expect(
        () => createDefaultSolanaRpcSubscriptionsChannelCreator(
          const DefaultRpcSubscriptionsChannelConfig(
            url: 'localhost:8900/ws',
          ),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message.toString(),
            'message',
            contains("must be either 'ws' or 'wss'"),
          ),
        ),
      );
    });
  });
}
