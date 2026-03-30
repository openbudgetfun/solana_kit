import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

Future<(HttpServer, StreamController<Object?>, List<Object?>)>
_startServer() async {
  final requests = <Object?>[];
  final commands = StreamController<Object?>();
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

  unawaited(() async {
    await for (final request in server) {
      final socket = await WebSocketTransformer.upgrade(request);
      commands.stream.listen((message) {
        if (message is Map<String, Object?>) {
          socket.add(jsonEncode(message));
        } else {
          socket.add(message);
        }
      });
      socket.listen(requests.add);
    }
  }());

  return (server, commands, requests);
}

void main() {
  group('HeliusWebSocket integration', () {
    test('connects, subscribes, confirms, and emits notifications', () async {
      final (server, commands, requests) = await _startServer();
      addTearDown(() async {
        await commands.close();
        await server.close(force: true);
      });

      final ws = HeliusWebSocket(
        url: 'ws://${server.address.address}:${server.port}',
        allowInsecureWs: true,
      );
      await ws.connect();
      addTearDown(ws.close);
      expect(ws.isConnected, isTrue);

      final stream = ws.subscribe('accountSubscribe', ['acct-1']);
      final nextEvent = stream.first;

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final subscribeJson =
          jsonDecode(requests.single! as String) as Map<String, Object?>;
      expect(subscribeJson['jsonrpc'], '2.0');
      expect(subscribeJson['id'], 1);
      expect(subscribeJson['method'], 'accountSubscribe');
      expect(subscribeJson['params'], ['acct-1']);

      commands
        ..add(heliusSubscriptionAckFixture(id: 1, subscription: 99))
        ..add(
          heliusNotificationFixture(
            method: 'accountNotification',
            subscription: 99,
            result: {'value': 'ok'},
          ),
        );

      expect(await nextEvent, {'value': 'ok'});
    });

    test('unsubscribe uses the matching JSON-RPC unsubscribe method', () async {
      final (server, commands, requests) = await _startServer();
      addTearDown(() async {
        await commands.close();
        await server.close(force: true);
      });

      final ws = HeliusWebSocket(
        url: 'ws://${server.address.address}:${server.port}',
        allowInsecureWs: true,
      );
      await ws.connect();
      addTearDown(ws.close);

      final subscription = ws.subscribe('logsSubscribe').listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      commands.add(heliusSubscriptionAckFixture(id: 1, subscription: 77));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(requests.length, greaterThanOrEqualTo(2));
      final unsubscribeJson =
          jsonDecode(requests.last! as String) as Map<String, Object?>;
      expect(unsubscribeJson['method'], 'logsUnsubscribe');
      expect(unsubscribeJson['params'], [77]);
    });

    test('ignores non-string websocket messages', () async {
      final (server, commands, requests) = await _startServer();
      addTearDown(() async {
        await commands.close();
        await server.close(force: true);
      });

      final ws = HeliusWebSocket(
        url: 'ws://${server.address.address}:${server.port}',
        allowInsecureWs: true,
      );
      await ws.connect();
      addTearDown(ws.close);

      final emitted = <Map<String, Object?>>[];
      final subscription = ws.subscribe('slotSubscribe').listen(emitted.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      commands.add(heliusSubscriptionAckFixture(id: 1, subscription: 55));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      commands.add(Uint8List.fromList([1, 2, 3, 4]));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emitted, isEmpty);
      expect(requests, isNotEmpty);
    });

    test('invalid JSON payloads surface as SolanaError events', () async {
      final (server, commands, requests) = await _startServer();
      addTearDown(() async {
        await commands.close();
        await server.close(force: true);
      });

      final ws = HeliusWebSocket(
        url: 'ws://${server.address.address}:${server.port}',
        allowInsecureWs: true,
      );
      await ws.connect();
      addTearDown(ws.close);

      final errors = <Object>[];
      final subscription = ws
          .subscribe('slotSubscribe')
          .listen((_) {}, onError: errors.add);
      addTearDown(subscription.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      commands.add(heliusSubscriptionAckFixture(id: 1, subscription: 55));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      commands.add('{not valid json');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        errors.single,
        isA<SolanaError>().having(
          (error) => error.code,
          'code',
          SolanaErrorCode.heliusWebSocketError,
        ),
      );
      expect(requests, isNotEmpty);
    });

    test(
      'subscription error responses surface on the matching stream',
      () async {
        final (server, commands, _) = await _startServer();
        addTearDown(() async {
          await commands.close();
          await server.close(force: true);
        });

        final ws = HeliusWebSocket(
          url: 'ws://${server.address.address}:${server.port}',
          allowInsecureWs: true,
        );
        await ws.connect();
        addTearDown(ws.close);

        final errors = <Object>[];
        final subscription = ws
            .subscribe('accountSubscribe', ['acct-1'])
            .listen((_) {}, onError: errors.add);
        addTearDown(subscription.cancel);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        commands.add({
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': -32000, 'message': 'subscription denied'},
        });
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          errors.single,
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.heliusWebSocketError,
          ),
        );
      },
    );

    test('close disconnects and future subscribe calls fail', () async {
      final (server, commands, requests) = await _startServer();
      addTearDown(() async {
        await commands.close();
        await server.close(force: true);
      });

      final ws = HeliusWebSocket(
        url: 'ws://${server.address.address}:${server.port}',
        allowInsecureWs: true,
      );
      await ws.connect();
      final stream = ws.subscribe('signatureSubscribe', ['sig-1']);
      expect(stream, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(requests, isNotEmpty);

      await ws.close();

      expect(ws.isConnected, isFalse);
      expect(
        () => ws.subscribe('signatureSubscribe', ['sig-1']),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.heliusWebSocketError,
          ),
        ),
      );
    });
  });
}
