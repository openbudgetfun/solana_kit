import 'dart:async';
import 'dart:io';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:test/test.dart';

void main() {
  group('AbortController', () {
    test('creates a signal that is not aborted', () {
      final controller = AbortController();
      expect(controller.signal.isAborted, isFalse);
      expect(controller.signal.reason, isNull);
    });

    test('abort sets isAborted to true', () {
      final controller = AbortController()..abort();
      expect(controller.signal.isAborted, isTrue);
    });

    test('abort with reason sets the reason', () {
      final controller = AbortController();
      final reason = StateError('test');
      controller.abort(reason);
      expect(controller.signal.isAborted, isTrue);
      expect(controller.signal.reason, same(reason));
    });

    test('abort without reason leaves reason as null', () {
      final controller = AbortController()..abort();
      expect(controller.signal.reason, isNull);
    });

    test('abort completes the signal future', () async {
      final controller = AbortController();
      var futureCompleted = false;
      unawaited(
        controller.signal.future.then((_) {
          futureCompleted = true;
        }),
      );
      controller.abort();
      // Allow microtask to run.
      await Future<void>.delayed(Duration.zero);
      expect(futureCompleted, isTrue);
    });

    test('calling abort multiple times is idempotent', () {
      final controller = AbortController();
      final reason1 = StateError('first');
      final reason2 = StateError('second');
      controller
        ..abort(reason1)
        ..abort(reason2);
      expect(controller.signal.isAborted, isTrue);
      expect(controller.signal.reason, same(reason1));
    });
  });

  group('WebSocketChannelConfig', () {
    test('has default sendBufferHighWatermark of 128KB', () {
      final config = WebSocketChannelConfig(
        url: Uri.parse('wss://example.com'),
      );
      expect(config.sendBufferHighWatermark, 128 * 1024);
    });

    test('signal defaults to null', () {
      final config = WebSocketChannelConfig(
        url: Uri.parse('wss://example.com'),
      );
      expect(config.signal, isNull);
    });

    test('stores provided values', () {
      final signal = AbortController().signal;
      final url = Uri.parse('wss://example.com');
      final config = WebSocketChannelConfig(
        url: url,
        sendBufferHighWatermark: 42069,
        signal: signal,
      );
      expect(config.url, url);
      expect(config.sendBufferHighWatermark, 42069);
      expect(config.signal, same(signal));
    });
  });

  group('createWebSocketChannel', () {
    test('throws when the signal is already aborted', () async {
      final controller = AbortController()..abort();
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(
            url: Uri.parse('ws://localhost:0'),
            signal: controller.signal,
          ),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
          ),
        ),
      );
    });

    test('throws abort reason when signal is already aborted with '
        'an Exception reason', () async {
      final controller = AbortController();
      final reason = StateError('user cancelled');
      controller.abort(reason);
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(
            url: Uri.parse('ws://localhost:0'),
            signal: controller.signal,
          ),
        ),
        throwsA(same(reason)),
      );
    });

    test('throws when the connection fails', () async {
      // Use a URL that will fail to connect (port 0 is not valid).
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('ws://localhost:1')),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.rpcSubscriptionsChannelFailedToConnect,
          ),
        ),
      );
    });
  });

  group('a websocket channel', () {
    late HttpServer server;
    late Uri serverUrl;
    late List<WebSocket> serverSockets;

    setUp(() async {
      serverSockets = [];
      server = await HttpServer.bind('localhost', 0);
      serverUrl = Uri.parse('ws://localhost:${server.port}');
      server.transform(WebSocketTransformer()).listen((WebSocket ws) {
        serverSockets.add(ws);
      });
    });

    tearDown(() async {
      for (final ws in serverSockets) {
        await ws.close();
      }
      await server.close(force: true);
    });

    test('resolves to a channel when the connection is established', () async {
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl),
      );
      expect(channel, isNotNull);
    });

    test('publishes messages to message listeners', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      final messages = <Object?>[];
      channel.on('message', messages.add);

      // Wait for server socket to be ready.
      await _waitFor(() => serverSockets.isNotEmpty);
      serverSockets.first.add('hello');

      // Allow message to propagate.
      await _waitFor(() => messages.isNotEmpty);
      expect(messages, ['hello']);

      controller.abort();
    });

    test('publishes to multiple message listeners', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      final messagesA = <Object?>[];
      final messagesB = <Object?>[];
      channel
        ..on('message', messagesA.add)
        ..on('message', messagesB.add);

      await _waitFor(() => serverSockets.isNotEmpty);
      serverSockets.first.add('hello');

      await _waitFor(() => messagesA.isNotEmpty);
      expect(messagesA, ['hello']);
      expect(messagesB, ['hello']);

      controller.abort();
    });

    test('does not publish messages after abort', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      final messages = <Object?>[];
      channel.on('message', messages.add);

      controller.abort();

      await _waitFor(() => serverSockets.isNotEmpty);
      serverSockets.first.add('should not arrive');

      // Give some time for the message to potentially arrive.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messages, isEmpty);
    });

    test('sends a message to the websocket', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      await _waitFor(() => serverSockets.isNotEmpty);

      final serverMessages = <Object?>[];
      serverSockets.first.listen(serverMessages.add);

      await channel.send('outgoing message');

      await _waitFor(() => serverMessages.isNotEmpty);
      expect(serverMessages, ['outgoing message']);

      controller.abort();
    });

    test(
      'publishes errors when connection closes with non-1000 code',
      () async {
        final controller = AbortController();
        final channel = await createWebSocketChannel(
          WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
        );

        final errors = <Object?>[];
        channel.on('error', errors.add);

        await _waitFor(() => serverSockets.isNotEmpty);

        // Close server-side with an abnormal code.
        // Note: 1006 is reserved and cannot be sent via close(), use 1011.
        await serverSockets.first.close(1011, 'internal error');

        await _waitFor(() => errors.isNotEmpty);
        expect(errors, hasLength(1));
        expect(
          errors.first,
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
          ),
        );
      },
    );

    test(
      'does not publish errors when connection closes with code 1000',
      () async {
        final controller = AbortController();
        final channel = await createWebSocketChannel(
          WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
        );

        final errors = <Object?>[];
        channel.on('error', errors.add);

        await _waitFor(() => serverSockets.isNotEmpty);

        // Close server-side with normal closure.
        await serverSockets.first.close(normalClosureCode, 'goodbye');

        // Give time for events to propagate.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(errors, isEmpty);
      },
    );

    test('does not publish errors after abort', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      final errors = <Object?>[];
      channel.on('error', errors.add);

      controller.abort();

      await _waitFor(() => serverSockets.isNotEmpty);
      // Note: 1006 is reserved and cannot be sent via close(), use 1011.
      await serverSockets.first.close(1011, 'internal error');

      // Give time for events to propagate.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(errors, isEmpty);
    });

    test('throws when sending on a closed channel', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      await _waitFor(() => serverSockets.isNotEmpty);

      // Close the server side and wait for the client to detect it.
      await serverSockets.first.close(normalClosureCode);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await expectLater(
        channel.send('message'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
          ),
        ),
      );
    });

    test('abort closes the websocket connection', () async {
      final controller = AbortController();
      await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      await _waitFor(() => serverSockets.isNotEmpty);

      final serverWs = serverSockets.first;
      final closeCompleter = Completer<void>();

      // Listen for close on server side. The `listen` callback's `onDone`
      // fires when the underlying connection closes.
      serverWs.listen(null, onDone: closeCompleter.complete);

      controller.abort();

      // The server socket should detect the closure.
      await closeCompleter.future.timeout(const Duration(seconds: 5));
      expect(serverWs.closeCode, normalClosureCode);
    });

    test('unsubscribing stops message delivery', () async {
      final controller = AbortController();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(url: serverUrl, signal: controller.signal),
      );

      final messages = <Object?>[];
      final unsubscribe = channel.on('message', messages.add);

      await _waitFor(() => serverSockets.isNotEmpty);

      serverSockets.first.add('first');
      await _waitFor(() => messages.isNotEmpty);
      expect(messages, ['first']);

      unsubscribe();

      serverSockets.first.add('second');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messages, ['first']);

      controller.abort();
    });
  });
}

/// Waits for [condition] to become true, polling every 10ms.
///
/// Times out after 2 seconds.
Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
