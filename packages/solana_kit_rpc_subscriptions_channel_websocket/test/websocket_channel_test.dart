import 'dart:async';
import 'dart:io';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:test/test.dart';

void main() {
  group('CancellationTokenSource', () {
    test('creates a token that is not cancelled', () {
      final source = CancellationTokenSource();
      expect(source.token.isCancelled, isFalse);
      expect(source.token.reason, isNull);
    });

    test('cancel sets isCancelled to true', () {
      final source = CancellationTokenSource()..cancel();
      expect(source.token.isCancelled, isTrue);
    });

    test('cancel with reason sets the reason', () {
      final source = CancellationTokenSource();
      final reason = StateError('test');
      source.cancel(reason);
      expect(source.token.isCancelled, isTrue);
      expect(source.token.reason, same(reason));
    });

    test('cancel without reason leaves reason as null', () {
      final source = CancellationTokenSource()..cancel();
      expect(source.token.reason, isNull);
    });

    test('cancel completes the token future', () async {
      final source = CancellationTokenSource();
      var futureCompleted = false;
      unawaited(
        source.token.future.then((_) {
          futureCompleted = true;
        }),
      );
      source.cancel();
      // Allow microtask to run.
      await Future<void>.delayed(Duration.zero);
      expect(futureCompleted, isTrue);
    });

    test('calling cancel multiple times is idempotent', () {
      final source = CancellationTokenSource();
      final reason1 = StateError('first');
      final reason2 = StateError('second');
      source
        ..cancel(reason1)
        ..cancel(reason2);
      expect(source.token.isCancelled, isTrue);
      expect(source.token.reason, same(reason1));
    });
  });

  group('abortable futures', () {
    test('isAbortError recognizes AbortError only', () {
      expect(isAbortError(const AbortError()), isTrue);
      expect(isAbortError(StateError('not abort')), isFalse);
      expect(
        const AbortError().toString(),
        'AbortError: The operation was aborted.',
      );
    });

    test(
      'getAbortableFuture returns original future without a token',
      () async {
        await expectLater(getAbortableFuture(Future.value(42)), completion(42));
      },
    );

    test('getAbortableFuture resolves when the input future wins', () async {
      final source = CancellationTokenSource();

      await expectLater(
        getAbortableFuture(Future.value('done'), source.token),
        completion('done'),
      );
    });

    test(
      'getAbortableFuture rejects when already cancelled without reason',
      () async {
        final source = CancellationTokenSource()..cancel();

        await expectLater(
          getAbortableFuture(
            Future<void>.delayed(const Duration(days: 1)),
            source.token,
          ),
          throwsA(isA<AbortError>()),
        );
      },
    );

    test('getAbortableFuture rejects with a custom cancel reason', () async {
      final source = CancellationTokenSource();
      final reason = StateError('cancelled');
      final future = getAbortableFuture(
        Future<void>.delayed(const Duration(days: 1)),
        source.token,
      );

      source.cancel(reason);

      await expectLater(future, throwsA(same(reason)));
    });

    test('getAbortableFuture forwards input errors', () async {
      final source = CancellationTokenSource();
      final error = StateError('boom');

      await expectLater(
        getAbortableFuture(Future<void>.error(error), source.token),
        throwsA(same(error)),
      );
    });
  });

  group('WebSocketChannelConfig', () {
    test('disallows insecure ws:// URLs by default', () {
      final config = WebSocketChannelConfig(url: Uri.parse('ws://example.com'));
      expect(config.allowInsecureWs, isFalse);
    });

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
      final token = CancellationTokenSource().token;
      final url = Uri.parse('wss://example.com');
      final config = WebSocketChannelConfig(
        url: url,
        allowInsecureWs: true,
        allowPrivateHosts: true,
        sendBufferHighWatermark: 42069,
        signal: token,
      );
      expect(config.url, url);
      expect(config.allowInsecureWs, isTrue);
      expect(config.sendBufferHighWatermark, 42069);
      expect(config.signal, same(token));
    });
  });

  group('createWebSocketChannel', () {
    test('throws when the token is already cancelled', () async {
      final source = CancellationTokenSource()..cancel();
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(
            url: Uri.parse('ws://localhost:0'),
            allowInsecureWs: true,
            allowPrivateHosts: true,
            signal: source.token,
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

    test('throws cancel reason when token is already cancelled with '
        'an Exception reason', () async {
      final source = CancellationTokenSource();
      final reason = StateError('user cancelled');
      source.cancel(reason);
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(
            url: Uri.parse('ws://localhost:0'),
            allowInsecureWs: true,
            allowPrivateHosts: true,
            signal: source.token,
          ),
        ),
        throwsA(same(reason)),
      );
    });

    test(
      'uses a SolanaError when already cancelled with a non-error reason',
      () async {
        final source = CancellationTokenSource()..cancel('cancelled');
        await expectLater(
          createWebSocketChannel(
            WebSocketChannelConfig(
              url: Uri.parse('ws://localhost:0'),
              allowInsecureWs: true,
              allowPrivateHosts: true,
              signal: source.token,
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
      },
    );

    test('rejects insecure ws:// URLs by default', () async {
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('ws://localhost:1')),
        ),
        throwsArgumentError,
      );
    });

    test('rejects non-websocket schemes', () async {
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(
            url: Uri.parse('https://example.com/socket'),
            allowInsecureWs: true,
            allowPrivateHosts: true,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects relative websocket URLs', () async {
      await expectLater(
        createWebSocketChannel(
          WebSocketChannelConfig(
            url: Uri.parse('/socket'),
            allowInsecureWs: true,
            allowPrivateHosts: true,
          ),
        ),
        throwsArgumentError,
      );
    });

    test(
      'throws when the connection fails with insecure ws:// enabled',
      () async {
        // Use a URL that will fail to connect.
        await expectLater(
          createWebSocketChannel(
            WebSocketChannelConfig(
              url: Uri.parse('ws://localhost:1'),
              allowInsecureWs: true,
              allowPrivateHosts: true,
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.rpcSubscriptionsChannelFailedToConnect,
            ),
          ),
        );
      },
    );
  });

  group('a websocket channel', () {
    late HttpServer server;
    late Uri serverUrl;
    late List<WebSocket> serverSockets;

    setUp(() async {
      serverSockets = [];
      server = await HttpServer.bind('localhost', 0);
      serverUrl = Uri.parse('ws://localhost:${server.port}');
      server.transform(WebSocketTransformer()).listen((ws) {
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
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
        ),
      );
      expect(channel, isNotNull);
    });

    test('publishes messages to message listeners', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      final messages = <Object?>[];
      final subscription = channel.streams.notifications.listen(messages.add);

      // Wait for server socket to be ready.
      await _waitFor(() => serverSockets.isNotEmpty);
      serverSockets.first.add('hello');

      // Allow message to propagate.
      await _waitFor(() => messages.isNotEmpty);
      expect(messages, ['hello']);

      await subscription.cancel();
      source.cancel();
    });

    test('publishes to multiple message listeners', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      final messagesA = <Object?>[];
      final messagesB = <Object?>[];
      final subA = channel.streams.notifications.listen(messagesA.add);
      final subB = channel.streams.notifications.listen(messagesB.add);

      await _waitFor(() => serverSockets.isNotEmpty);
      serverSockets.first.add('hello');

      await _waitFor(() => messagesA.isNotEmpty);
      expect(messagesA, ['hello']);
      expect(messagesB, ['hello']);

      await subA.cancel();
      await subB.cancel();
      source.cancel();
    });

    test('does not publish messages after cancel', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      final messages = <Object?>[];
      final subscription = channel.streams.notifications.listen(messages.add);

      source.cancel();

      await _waitFor(() => serverSockets.isNotEmpty);
      serverSockets.first.add('should not arrive');

      // Give some time for the message to potentially arrive.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messages, isEmpty);
      await subscription.cancel();
    });

    test('sends a message to the websocket', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      await _waitFor(() => serverSockets.isNotEmpty);

      final serverMessages = <Object?>[];
      serverSockets.first.listen(serverMessages.add);

      await channel.send('outgoing message');

      await _waitFor(() => serverMessages.isNotEmpty);
      expect(serverMessages, ['outgoing message']);

      source.cancel();
    });

    test(
      'publishes errors when connection closes with non-1000 code',
      () async {
        final source = CancellationTokenSource();
        final channel = await createWebSocketChannel(
          WebSocketChannelConfig(
            url: serverUrl,
            allowInsecureWs: true,
            allowPrivateHosts: true,
            signal: source.token,
          ),
        );

        final errors = <Object?>[];
        final subscription = channel.streams.errors.listen(errors.add);

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
        await subscription.cancel();
      },
    );

    test(
      'does not publish errors when connection closes with code 1000',
      () async {
        final source = CancellationTokenSource();
        final channel = await createWebSocketChannel(
          WebSocketChannelConfig(
            url: serverUrl,
            allowInsecureWs: true,
            allowPrivateHosts: true,
            signal: source.token,
          ),
        );

        final errors = <Object?>[];
        final subscription = channel.streams.errors.listen(errors.add);

        await _waitFor(() => serverSockets.isNotEmpty);

        // Close server-side with normal closure.
        await serverSockets.first.close(normalClosureCode, 'goodbye');

        // Give time for events to propagate.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(errors, isEmpty);
        await subscription.cancel();
      },
    );

    test('does not publish errors after cancel', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      final errors = <Object?>[];
      final subscription = channel.streams.errors.listen(errors.add);

      source.cancel();

      await _waitFor(() => serverSockets.isNotEmpty);
      // Note: 1006 is reserved and cannot be sent via close(), use 1011.
      await serverSockets.first.close(1011, 'internal error');

      // Give time for events to propagate.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(errors, isEmpty);
      await subscription.cancel();
    });

    test('throws when sending on a closed channel', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
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

    test('cancel closes the websocket connection', () async {
      final source = CancellationTokenSource();
      await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      await _waitFor(() => serverSockets.isNotEmpty);

      final serverWs = serverSockets.first;
      final closeCompleter = Completer<void>();

      // Listen for close on server side. The `listen` callback's `onDone`
      // fires when the underlying connection closes.
      serverWs.listen(null, onDone: closeCompleter.complete);

      source.cancel();

      // The server socket should detect the closure.
      await closeCompleter.future.timeout(const Duration(seconds: 5));
      expect(serverWs.closeCode, normalClosureCode);
    });

    test('unsubscribing stops message delivery', () async {
      final source = CancellationTokenSource();
      final channel = await createWebSocketChannel(
        WebSocketChannelConfig(
          url: serverUrl,
          allowInsecureWs: true,
          allowPrivateHosts: true,
          signal: source.token,
        ),
      );

      final messages = <Object?>[];
      final subscription = channel.streams.notifications.listen(messages.add);

      await _waitFor(() => serverSockets.isNotEmpty);

      serverSockets.first.add('first');
      await _waitFor(() => messages.isNotEmpty);
      expect(messages, ['first']);

      await subscription.cancel();

      serverSockets.first.add('second');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messages, ['first']);

      source.cancel();
    });
  });

  group('SSRF protection', () {
    test('blocks localhost by default', () async {
      await expectLater(
        () => createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('wss://localhost:8080')),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('blocks 10.x.x.x by default', () async {
      await expectLater(
        () => createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('wss://10.0.0.1:8080')),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('blocks 192.168.x.x by default', () async {
      await expectLater(
        () => createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('wss://192.168.1.1:8080')),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('blocks 172.16-31.x.x by default', () async {
      await expectLater(
        () => createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('wss://172.16.0.1:8080')),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('blocks 169.254.x.x by default', () async {
      await expectLater(
        () => createWebSocketChannel(
          WebSocketChannelConfig(url: Uri.parse('wss://169.254.1.1:8080')),
        ),
        throwsA(isA<ArgumentError>()),
      );
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
