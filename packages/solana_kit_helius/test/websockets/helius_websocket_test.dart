import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('HeliusWebSocket', () {
    test('creates with URL', () {
      final ws = HeliusWebSocket(url: 'wss://example.com');
      expect(ws, isNotNull);
      expect(ws.url, 'wss://example.com');
      expect(ws.isConnected, isFalse);
    });

    test('throws SolanaError when subscribing without connection', () {
      final ws = HeliusWebSocket(url: 'wss://example.com');
      expect(
        () => ws.subscribe('accountSubscribe', ['addr1']),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.heliusWebSocketError,
          ),
        ),
      );
    });

    test('close completes without error when not connected', () async {
      final ws = HeliusWebSocket(url: 'wss://example.com');
      await ws.close();
      expect(ws.isConnected, isFalse);
    });

    test('url is stored correctly', () {
      const wsUrl = 'wss://mainnet-beta.helius-rpc.com/?api-key=test';
      final ws = HeliusWebSocket(url: wsUrl);
      expect(ws.url, wsUrl);
    });

    test('connect rejects insecure ws URLs by default', () async {
      final ws = HeliusWebSocket(url: 'ws://localhost:1234');

      await expectLater(
        ws.connect(),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('Insecure WebSocket endpoints are disabled by default'),
          ),
        ),
      );
    });

    test('connect rejects non-websocket schemes', () async {
      final ws = HeliusWebSocket(url: 'https://example.com');

      await expectLater(
        ws.connect(),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains("must use either 'wss' or 'ws'"),
          ),
        ),
      );
    });
  });
}
