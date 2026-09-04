import 'dart:async';
import 'dart:io';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late CancellationTokenSource source;
  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    source = CancellationTokenSource();
  });
  tearDown(() async {
    source.cancel();
    await server.close(force: true);
  });
  WebSocketChannelConfig config() => WebSocketChannelConfig(
    url: Uri.parse('ws://127.0.0.1:${server.port}'),
    allowPrivateHosts: true,
    allowInsecureWs: true,
    signal: source.token,
  );

  for (final reason in [StateError('cancelled'), 'cancelled']) {
    test('cancels a pending handshake promptly: $reason', () async {
      final request = server.first;
      final future = createWebSocketChannel(config());
      final incoming = await request;
      final check = expectLater(
        future.timeout(const Duration(seconds: 1)),
        throwsA(reason is Error ? same(reason) : isA<SolanaError>()),
      );
      source.cancel(reason);
      await check;
      final socket = await WebSocketTransformer.upgrade(incoming);
      await socket.drain<void>().timeout(const Duration(seconds: 1));
    });
  }

  for (final abort in [true, false]) {
    test(
      'closes both public streams when channel ends: abort=$abort',
      () async {
        final remote = Completer<WebSocket>();
        server.listen((request) async {
          remote.complete(await WebSocketTransformer.upgrade(request));
        });
        final channel = await createWebSocketChannel(config());
        final notificationDone = Completer<void>();
        final errorsDone = Completer<void>();
        channel.streams.notifications.listen(
          (_) {},
          onDone: notificationDone.complete,
        );
        channel.streams.errors.listen((_) {}, onDone: errorsDone.complete);
        if (abort) {
          source.cancel();
        } else {
          await (await remote.future).close(normalClosureCode);
        }
        await Future.wait([
          notificationDone.future,
          errorsDone.future,
        ]).timeout(const Duration(seconds: 1));
      },
    );
  }

  test('rejects sends immediately after cancellation', () async {
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((_) {});
    });
    final channel = await createWebSocketChannel(config());
    source.cancel();
    await expectLater(channel.send('late'), throwsA(isA<SolanaError>()));
  });
}
