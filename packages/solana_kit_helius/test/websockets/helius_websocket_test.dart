import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('HeliusWebSocket', () {
    test('creates with URL', () {
      final ws = HeliusWebSocket(url: 'wss://example.com');
      expect(ws, isNotNull);
      expect(ws.url, 'wss://example.com');
    });

    test('throws when subscribing without connection', () {
      final ws = HeliusWebSocket(url: 'wss://example.com');
      expect(
        () => ws.subscribe('accountSubscribe', ['addr1']),
        throwsA(isA<Exception>()),
      );
    });

    test('close completes without error when not connected', () async {
      final ws = HeliusWebSocket(url: 'wss://example.com');
      // Should not throw even when not connected.
      await ws.close();
    });

    test('url is stored correctly', () {
      const wsUrl = 'wss://mainnet-beta.helius-rpc.com/?api-key=test';
      final ws = HeliusWebSocket(url: wsUrl);
      expect(ws.url, wsUrl);
    });
  });
}
