import 'dart:async';
import 'dart:io';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late Future<WebSocket> peer;
  late StreamSubscription<WebSocket> connections;
  late CancellationTokenSource cancellation;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final connected = Completer<WebSocket>();
    peer = connected.future;
    connections = server
        .transform(WebSocketTransformer())
        .listen(connected.complete);
    cancellation = CancellationTokenSource();
  });

  tearDown(() async {
    cancellation.cancel();
    await connections.cancel();
    await server.close(force: true);
  });

  Future<RpcSubscriptionsChannel> connect({
    InboundPayloadLimits limits = const InboundPayloadLimits(maxBytes: 8),
    int maxPendingMessages = 128,
    int maxPendingBytes = 16 * 1024 * 1024,
  }) => createWebSocketChannel(
    WebSocketChannelConfig(
      url: Uri.parse('ws://127.0.0.1:${server.port}'),
      allowInsecureWs: true,
      allowPrivateHosts: true,
      signal: cancellation.token,
      inboundLimits: limits,
      maxPendingMessages: maxPendingMessages,
      maxPendingBytes: maxPendingBytes,
    ),
  );

  for (final frame in <Object>['é' * 5, List<int>.filled(9, 0), '[[[0]]]']) {
    test(
      'closes on oversized or too deeply nested ${frame.runtimeType}',
      () async {
        final channel = await connect(
          limits: const InboundPayloadLimits(maxBytes: 8, maxJsonDepth: 2),
        );
        final socket = await peer;
        final done = Completer<void>();
        socket.listen(null, onDone: done.complete);
        final failure = channel.streams.errors.first;
        final received = <Object?>[];
        final subscription = channel.streams.notifications.listen(received.add);
        socket.add(frame);

        expect(
          await failure.timeout(const Duration(seconds: 5)),
          isA<InboundPayloadLimitException>(),
        );
        await done.future.timeout(const Duration(seconds: 5));
        expect(socket.closeCode, 4009);
        expect(received, isEmpty);
        await expectLater(channel.send('later'), throwsA(isA<Exception>()));
        await subscription.cancel();
      },
    );
  }

  test('accepts a multibyte message exactly at the byte limit', () async {
    final channel = await connect();
    final socket = await peer;
    socket.listen(null);
    final received = channel.streams.notifications.first;
    socket.add('é' * 4);
    expect(await received, 'é' * 4);
  });

  for (final byteBudget in [false, true]) {
    test(
      'closes on paused listener ${byteBudget ? 'byte' : 'count'} overflow',
      () async {
        final channel = await connect(
          maxPendingMessages: byteBudget ? 100 : 2,
          maxPendingBytes: byteBudget ? 5 : 100,
        );
        final socket = await peer;
        final done = Completer<void>();
        socket.listen(null, onDone: done.complete);
        final received = <Object?>[];
        final paused = channel.streams.notifications.listen(received.add)
          ..pause();
        final active = channel.streams.notifications.listen((_) {});
        final failure = channel.streams.errors.first;
        socket
          ..add('aa')
          ..add('bb')
          ..add('cc');

        expect(
          await failure.timeout(const Duration(seconds: 5)),
          isA<InboundPayloadLimitException>().having(
            (error) => error.resource,
            'resource',
            byteBudget ? 'queued bytes' : 'queued messages',
          ),
        );
        await done.future.timeout(const Duration(seconds: 5));
        expect(socket.closeCode, 4009);
        paused.resume();
        await paused.cancel();
        await active.cancel();
        expect(received, isEmpty);
      },
    );
  }

  test(
    'drains paused messages in order and releases the queue budget',
    () async {
      final channel = await connect(maxPendingMessages: 2, maxPendingBytes: 4);
      final socket = await peer;
      socket.listen(null);
      final received = <Object?>[];
      final allDelivered = Completer<void>();
      final subscription = channel.streams.notifications.listen((message) {
        received.add(message);
        if (received.length == 4) allDelivered.complete();
      })..pause();
      final observed = Completer<void>();
      final active = channel.streams.notifications.listen((message) {
        if (message == 'bb') observed.complete();
      });
      socket
        ..add('aa')
        ..add('bb');
      await observed.future;
      subscription.resume();
      await pumpEventQueue();
      subscription.pause();
      socket
        ..add('cc')
        ..add('dd');
      subscription.resume();
      await allDelivered.future.timeout(const Duration(seconds: 5));
      expect(received, ['aa', 'bb', 'cc', 'dd']);
      await subscription.cancel();
      await active.cancel();
    },
  );
}
