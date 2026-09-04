import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('preconf websocket', () {
    test('preconfWebsocketUrl embeds the API key', () {
      expect(
        preconfWebsocketUrl('key-123'),
        'wss://beta.helius-rpc.com/?api-key=key-123',
      );
    });

    test('preconfWireVersion and preconfHeadLength match the frame layout', () {
      expect(preconfWireVersion, 1);
      // version(1) + slot(8) + transaction_index(8) + status(1).
      expect(preconfHeadLength, 18);
    });

    test('decodePreconfFrame maps an out-of-range status to unknown', () {
      final encoded = _encodedTransaction();
      final frame = Uint8List(preconfHeadLength + encoded.length)
        ..[0] = preconfWireVersion
        ..setAll(1, _u64le(9))
        ..setAll(9, _u64le(1))
        ..[17] =
            99 // not 0 or 1
        ..setAll(preconfHeadLength, encoded);

      final notification = decodePreconfFrame(frame);
      expect(notification.status, PreconfStatus.unknown);
    });

    test('subscribe, receive a notification, unsubscribe, and close', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<Object?>.broadcast();
      final sockets = <WebSocket>[];
      final serverClosed = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          socket.listen(received.add);
          await serverClosed.future;
          await socket.close();
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channel: WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final subFuture = client.preconfSubscribe();
      // Wait for the subscribe request to arrive.
      final request = await received.stream.first.timeout(
        const Duration(seconds: 5),
      );
      final subscribeCall =
          jsonDecode(request! as String) as Map<String, Object?>;
      expect(subscribeCall['method'], 'preconfSubscribe');
      final subscribeId = subscribeCall['id']! as int;
      expect(subscribeId, 1);
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': subscribeId,
          'result': 42,
        }),
      );

      final subscription = await subFuture;
      expect(subscription.subscriptionId, 42);

      // Push a binary notification frame.
      final encoded = _encodedTransaction();
      final frame = Uint8List(preconfHeadLength + encoded.length)
        ..[0] = preconfWireVersion
        ..setAll(1, _u64le(123))
        ..setAll(9, _u64le(4))
        ..[17] =
            1 // success
        ..setAll(preconfHeadLength, encoded);
      sockets.first.add(frame);

      final notification = await subscription.notifications.first.timeout(
        const Duration(seconds: 5),
      );
      expect(notification.slot, 123);
      expect(notification.transactionIndex, 4);
      expect(notification.status, PreconfStatus.success);
      expect(notification.transactionBytes, encoded);

      // Unsubscribe.
      final unsubReceived = received.stream.first;
      final unsubFuture = subscription.unsubscribe();
      final unsubRequest =
          (await unsubReceived.timeout(const Duration(seconds: 5)))! as String;
      final unsubCall = jsonDecode(unsubRequest) as Map<String, Object?>;
      expect(unsubCall['method'], 'preconfUnsubscribe');
      expect(unsubCall['params'], [42]);
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': unsubCall['id'],
          'result': true,
        }),
      );
      expect(await unsubFuture, isTrue);

      client.close();
      serverClosed.complete();
      await server.close(force: true);
    });

    test('close cancels an active subscription stream', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<Object?>.broadcast();
      final sockets = <WebSocket>[];
      final serverClosed = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          socket.listen(received.add);
          await serverClosed.future;
          await socket.close();
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channel: WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final subFuture = client.preconfSubscribe();
      final request =
          (await received.stream.first.timeout(const Duration(seconds: 5)))!
              as String;
      final call = jsonDecode(request) as Map<String, Object?>;
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': call['id'],
          'result': 7,
        }),
      );
      await subFuture;

      // Closing while subscribed must close the per-subscription stream.
      client.close();
      serverClosed.complete();
      await server.close(force: true);
    });

    test('encodes reserved characters in API keys', () {
      const apiKey = 'key&token=injected#fragment';
      final uri = Uri.parse(preconfWebsocketUrl(apiKey));

      expect(uri.queryParameters, {'api-key': apiKey});
      expect(uri.fragment, isEmpty);
    });

    test('uses the default endpoint through an injected connector', () {
      Uri? connectedUri;
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (uri) {
          connectedUri = uri;
          return _FakeChannel();
        },
      );

      expect(connectedUri, Uri.parse(preconfWebsocketUrl('test-key')));
      client
        ..close()
        ..close();
    });

    test('waits for readiness before sending subscribe requests', () async {
      final channel = _FakeChannel(ready: false);
      final client = PreconfWsClient(apiKey: 'test-key', channel: channel);
      final pending = client.preconfSubscribe();
      await Future<void>.delayed(Duration.zero);
      expect(channel.sink.sent, isEmpty);

      channel.readyCompleter.complete();
      await Future<void>.delayed(Duration.zero);
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 7}),
      );

      expect((await pending).subscriptionId, 7);
      client.close();
    });

    test(
      'failed readiness rejects calls and suppresses duplicate errors',
      () async {
        final channel = _FakeChannel(ready: false);
        final client = PreconfWsClient(apiKey: 'private-key', channel: channel);
        final pending = client.preconfSubscribe();
        final failure = StateError(preconfWebsocketUrl('private-key'));
        channel.readyCompleter.completeError(failure);
        channel.incoming.addError(failure);

        await expectLater(
          pending,
          throwsA(
            isA<StateError>().having(
              (error) => error.toString(),
              'credential-free message',
              isNot(contains('private-key')),
            ),
          ),
        );
        await expectLater(
          client.preconfSubscribe(),
          throwsA(isA<StateError>()),
        );
        client.close();
      },
    );

    test(
      'close observes later readiness errors without leaking keys',
      () async {
        final unhandled = <Object>[];
        await runZonedGuarded(() async {
          final channel = _FakeChannel(ready: false);
          PreconfWsClient(
            apiKey: 'private-key',
            channel: channel,
          ).close();
          channel.readyCompleter.completeError(
            StateError(
              'Connection failed: ${preconfWebsocketUrl('private-key')}',
            ),
          );
          await Future<void>.delayed(Duration.zero);
        }, (error, _) => unhandled.add(error));

        expect(unhandled, isEmpty);
      },
    );

    test('close rejects pending subscribe requests', () async {
      final channel = _FakeChannel();
      final client = PreconfWsClient(apiKey: 'private-key', channel: channel);
      final pending = client.preconfSubscribe();
      await Future<void>.delayed(Duration.zero);
      client.close();

      await expectLater(
        pending.timeout(const Duration(seconds: 1)),
        throwsA(isA<StateError>()),
      );
    });

    test('close settles requests even before readiness completes', () async {
      final channel = _FakeChannel(ready: false);
      final client = PreconfWsClient(apiKey: 'test-key', channel: channel);
      final pending = client.preconfSubscribe();
      client.close();

      await expectLater(pending, throwsA(isA<StateError>()));
      channel.readyCompleter.complete();
    });

    test('peer closure rejects pending unsubscribe requests', () async {
      final channel = _FakeChannel();
      final client = PreconfWsClient(apiKey: 'test-key', channel: channel);
      final pending = client.preconfUnsubscribe(7);
      await Future<void>.delayed(Duration.zero);
      unawaited(channel.incoming.close());

      await expectLater(pending, throwsA(isA<StateError>()));
      client.close();
    });

    test(
      'transport failures notify and close active subscription streams',
      () async {
        final channel = _FakeChannel();
        final client = PreconfWsClient(apiKey: 'private-key', channel: channel);
        final pending = client.preconfSubscribe();
        await Future<void>.delayed(Duration.zero);
        channel.incoming.add(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 7}),
        );
        final subscription = await pending;
        final errors = <Object>[];
        final done = Completer<void>();
        subscription.notifications.listen(
          (_) {},
          onError: errors.add,
          onDone: done.complete,
        );
        channel.incoming.addError(
          StateError(preconfWebsocketUrl('private-key')),
        );

        await done.future;
        expect(errors.single, isA<StateError>());
        expect(errors.single.toString(), isNot(contains('private-key')));
        client.close();
      },
    );

    for (final frame in <Object>[
      'not json',
      <int>[1],
    ]) {
      test('malformed frame $frame fails pending requests safely', () async {
        final channel = _FakeChannel();
        final client = PreconfWsClient(apiKey: 'test-key', channel: channel);
        final pending = client.preconfSubscribe();
        await Future<void>.delayed(Duration.zero);
        channel.incoming.add(frame);

        await expectLater(pending, throwsA(isA<StateError>()));
        client.close();
      });
    }

    test(
      'send and asynchronous close failures do not leak endpoint keys',
      () async {
        final unhandled = <Object>[];
        Object? operationError;
        await runZonedGuarded(() async {
          final channel = _FakeChannel();
          final failure = StateError(preconfWebsocketUrl('private-key'));
          channel.sink.sendFailure = failure;
          channel.sink.closeFailure = failure;
          final client = PreconfWsClient(
            apiKey: 'private-key',
            channel: channel,
          );
          try {
            await client.preconfSubscribe();
          } on Object catch (error) {
            operationError = error;
          }
          client.close();
          await Future<void>.delayed(Duration.zero);
        }, (error, _) => unhandled.add(error));

        expect(operationError, isA<StateError>());
        expect(operationError.toString(), isNot(contains('private-key')));
        expect(unhandled, isEmpty);
      },
    );

    test('stream failures reject pending calls without leaking keys', () async {
      final unhandled = <Object>[];
      Object? operationError;
      await runZonedGuarded(() async {
        final channel = _FakeChannel();
        final client = PreconfWsClient(apiKey: 'private-key', channel: channel);
        final pending = client.preconfSubscribe();
        await Future<void>.delayed(Duration.zero);
        channel.incoming.addError(
          StateError(
            'Connection failed: ${preconfWebsocketUrl('private-key')}',
          ),
        );

        try {
          await pending.timeout(const Duration(seconds: 1));
        } on Object catch (error) {
          operationError = error;
        }
        client.close();
      }, (error, _) => unhandled.add(error));

      expect(unhandled, isEmpty);
      expect(
        operationError,
        isA<StateError>().having(
          (error) => error.toString(),
          'credential-free message',
          isNot(contains('private-key')),
        ),
      );
    });

    test('subscribe surfaces JSON-RPC errors', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = StreamController<Object?>.broadcast();
      final sockets = <WebSocket>[];
      final serverClosed = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          socket.listen(received.add);
          await serverClosed.future;
          await socket.close();
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channel: WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final subFuture = client.preconfSubscribe();
      final request =
          (await received.stream.first.timeout(const Duration(seconds: 5)))!
              as String;
      final call = jsonDecode(request) as Map<String, Object?>;
      sockets.first.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': call['id'],
          'error': {'code': -32601, 'message': 'method not found'},
        }),
      );

      await expectLater(
        subFuture,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('method not found'),
          ),
        ),
      );

      client.close();
      serverClosed.complete();
      await server.close(force: true);
    });
  });
}

Uint8List _encodedTransaction() {
  final message = const TransactionMessage(version: TransactionVersion.v0)
      .copyWith(
        feePayer: const Address(
          '22222222222222222222222222222222222222222222',
        ),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      );
  return getTransactionEncoder().encode(compileTransaction(message));
}

List<int> _u64le(int value) {
  final bytes = Uint8List(8);
  for (var i = 0; i < 8; i++) {
    bytes[i] = (value >> (8 * i)) & 0xff;
  }
  return bytes;
}

class _FakeChannel implements WebSocketChannel {
  _FakeChannel({bool ready = true}) {
    if (ready) readyCompleter.complete();
  }

  final incoming = StreamController<Object?>();
  final readyCompleter = Completer<void>();

  @override
  final _FakeSink sink = _FakeSink();

  @override
  Stream<Object?> get stream => incoming.stream;

  @override
  Future<void> get ready => readyCompleter.future;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSink implements WebSocketSink {
  final sent = <Object?>[];
  final _done = Completer<void>();
  StateError? sendFailure;
  StateError? closeFailure;

  @override
  void add(Object? event) {
    final failure = sendFailure;
    if (failure != null) throw failure;
    sent.add(event);
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    final failure = closeFailure;
    if (failure != null) throw failure;
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
