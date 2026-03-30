import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

Future<(HttpServer, StreamController<Object?>, List<Object?>)> _startServer() async {
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
  group('HeliusWebSocket session boundaries', () {
    test('routes notifications to matching subscriptions without crosstalk', () async {
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

      final accountStream = ws.subscribe('accountSubscribe', ['acct-1']);
      final logsStream = ws.subscribe('logsSubscribe', ['all']);

      final accountEvent = accountStream.first;
      final logsEvent = logsStream.first;

      await Future<void>.delayed(const Duration(milliseconds: 50));
      commands
        ..add(heliusSubscriptionAckFixture(id: 1, subscription: 41))
        ..add(heliusSubscriptionAckFixture(id: 2, subscription: 42))
        ..add(
          heliusNotificationFixture(
            method: 'accountNotification',
            subscription: 41,
            result: {'kind': 'account', 'slot': 1},
          ),
        )
        ..add(
          heliusNotificationFixture(
            method: 'logsNotification',
            subscription: 42,
            result: {'kind': 'logs', 'slot': 2},
          ),
        );

      expect(await accountEvent, {'kind': 'account', 'slot': 1});
      expect(await logsEvent, {'kind': 'logs', 'slot': 2});
    });

    test('cancelling one subscription keeps the other session alive', () async {
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

      final accountSubscription = ws.subscribe('accountSubscribe', ['acct-1']).listen((_) {});
      final logsStream = ws.subscribe('logsSubscribe', ['all']);
      final logsEvent = logsStream.first;

      await Future<void>.delayed(const Duration(milliseconds: 50));
      commands
        ..add(heliusSubscriptionAckFixture(id: 1, subscription: 51))
        ..add(heliusSubscriptionAckFixture(id: 2, subscription: 52));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await accountSubscription.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      commands.add(
        heliusNotificationFixture(
          method: 'logsNotification',
          subscription: 52,
          result: {'kind': 'logs-after-cancel'},
        ),
      );

      expect(await logsEvent, {'kind': 'logs-after-cancel'});

      final unsubscribeJson =
          jsonDecode(requests.last! as String) as Map<String, Object?>;
      expect(unsubscribeJson['method'], 'accountUnsubscribe');
      expect(unsubscribeJson['params'], [51]);
    });
  });
}
