import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
      expect(preconfSlotWireVersion, 128);
      expect(preconfHeadLength, 18);
    });

    test('encodes reserved characters in API keys', () {
      const apiKey = 'key&token=injected#fragment';
      final uri = Uri.parse(preconfWebsocketUrl(apiKey));

      expect(uri.queryParameters, {'api-key': apiKey});
      expect(uri.fragment, isEmpty);
    });

    test('decodePreconfFrame maps an out-of-range status to unknown', () {
      final notification = decodePreconfFrame(
        _transactionFrame(status: 99, slot: 9),
      );

      expect(notification.status, PreconfStatus.unknown);
    });

    test('decodePreconfEvent decodes slot frames', () {
      final bytes = Uint8List(10)
        ..[0] = preconfSlotWireVersion
        ..setAll(1, _u64le(77))
        ..[9] = PreconfSlotStatus.bankFrozen;

      final event = decodePreconfEvent(bytes);

      expect(event, isA<PreconfSlotNotification>());
      final slot = event as PreconfSlotNotification;
      expect(slot.version, preconfSlotWireVersion);
      expect(slot.slot, 77);
      expect(slot.status, PreconfSlotStatus.bankFrozen);
    });

    test('decodePreconfEvent rejects unknown slot status', () {
      final bytes = Uint8List(10)
        ..[0] = preconfSlotWireVersion
        ..setAll(1, _u64le(77))
        ..[9] = 9;

      expect(() => decodePreconfEvent(bytes), throwsStateError);
    });

    test(
      'subscribe sends the filter, streams notifications, and unsubscribes',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final sockets = <WebSocket>[];
        final requests = StreamController<String>.broadcast();
        final socketDone = Completer<void>();

        unawaited(() async {
          await for (final request in server) {
            final socket = await WebSocketTransformer.upgrade(request);
            sockets.add(socket);
            socket.listen(
              (data) {
                if (data is String) requests.add(data);
              },
              onDone: () {
                if (!socketDone.isCompleted) socketDone.complete();
              },
            );
          }
        }());

        final client = PreconfWsClient(
          apiKey: 'test-key',
          channelFactory: (_) => WebSocketChannel.connect(
            Uri.parse('ws://127.0.0.1:${server.port}'),
          ),
        );

        final pending = client.preconfSubscribe(
          filter: PreconfFilter(
            failed: false,
            accountInclude: ['account-1'],
            includeSource: [PreconfSource.helius],
          ),
        );
        final request = jsonDecode(
          await requests.stream.first.timeout(const Duration(seconds: 30)),
        ) as Map<String, Object?>;

        expect(request['method'], 'preconfSubscribe');
        expect(request['id'], 1);
        expect(request['params'], [
          {
            'failed': false,
            'accountInclude': ['account-1'],
            'includeSource': ['helius'],
          },
        ]);

        sockets.single.add(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 42}),
        );

        final subscription = await pending;
        expect(subscription.subscriptionId, 42);

        sockets.single.add(_transactionFrame(slot: 123, transactionIndex: 4));

        final notification = await subscription.notifications.first.timeout(
          const Duration(seconds: 30),
        );
        expect(notification.slot, 123);
        expect(notification.transactionIndex, 4);
        expect(notification.status, PreconfStatus.success);
        expect(notification.transaction.signatures, isNotEmpty);

        expect(await subscription.unsubscribe(), isTrue);
        await socketDone.future.timeout(const Duration(seconds: 30));

        client.close();
        await server.close(force: true);
      },
    );

    test('slot subscriptions deliver transaction and slot events', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      late WebSocket socket;
      final accepted = Completer<void>();

      unawaited(() async {
        await for (final request in server) {
          socket = await WebSocketTransformer.upgrade(request);
          accepted.complete();
          socket.listen((_) {});
        }
      }());

      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => WebSocketChannel.connect(
          Uri.parse('ws://127.0.0.1:${server.port}'),
        ),
      );

      final pending = client.preconfSubscribe(
        options: const PreconfSubscribeOptions(slots: true),
      );
      await accepted.future.timeout(const Duration(seconds: 30));
      socket.add(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 7}));
      final subscription = await pending;

      final events = <PreconfEvent>[];
      final done = Completer<void>();
      subscription.events.listen(
        events.add,
        onDone: done.complete,
      );

      socket
        ..add(_transactionFrame())
        ..add(
          Uint8List(10)
            ..[0] = preconfSlotWireVersion
            ..setAll(1, _u64le(2))
            ..[9] = PreconfSlotStatus.bankCreated,
        );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(events, hasLength(2));
      expect(events[0], isA<PreconfNotification>());
      expect(events[1], isA<PreconfSlotNotification>());

      client.close();
      await done.future.timeout(const Duration(seconds: 30));
      await server.close(force: true);
    });

    test('subscribe surfaces JSON-RPC errors with the server code', () async {
      final channel = _FakeChannel();
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
      );

      final pending = client.preconfSubscribe();
      await Future<void>.delayed(Duration.zero);
      channel.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': -32602, 'message': 'invalid filter'},
        }),
      );

      await expectLater(
        pending,
        throwsA(
          isA<PreconfRpcError>()
              .having((error) => error.code, 'code', -32602)
              .having((error) => error.message, 'message', 'invalid filter'),
        ),
      );
      client.close();
    });

    test('failed readiness is credential-free', () async {
      final channel = _FakeChannel(ready: false);
      final client = PreconfWsClient(
        apiKey: 'private-key',
        channelFactory: (_) => channel,
      );

      final pending = client.preconfSubscribe();
      channel.readyCompleter.completeError(
        StateError(preconfWebsocketUrl('private-key')),
      );

      await expectLater(
        pending,
        throwsA(
          isA<PreconfRpcError>().having(
            (error) => error.toString(),
            'credential-free message',
            isNot(contains('private-key')),
          ),
        ),
      );
      client.close();
    });

    test('close ends every live subscription', () async {
      final channel = _FakeChannel();
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
      );

      final pending = client.preconfSubscribe();
      await Future<void>.delayed(Duration.zero);
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 7}),
      );
      final subscription = await pending;
      final done = Completer<void>();
      subscription.events.listen((_) {}, onDone: done.complete);

      client.close();
      await done.future.timeout(const Duration(seconds: 1));
      expect(await subscription.unsubscribe(), isFalse);
    });

    test('preconfUnsubscribe rejects ambiguous subscription ids', () async {
      final first = _FakeChannel();
      final second = _FakeChannel();
      final channels = [first, second];
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channels.removeAt(0),
      );

      final firstPending = client.preconfSubscribe();
      final secondPending = client.preconfSubscribe();
      await Future<void>.delayed(Duration.zero);
      first.incoming.add(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 7}));
      second.incoming.add(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 7}));
      await firstPending;
      await secondPending;

      await expectLater(
        () => client.preconfUnsubscribe(7),
        throwsA(isA<StateError>()),
      );
      client.close();
    });

    test('preconfUnsubscribe returns false for unknown ids', () async {
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => _FakeChannel(),
      );

      expect(await client.preconfUnsubscribe(99), isFalse);
      client.close();
    });

    test('getPreConfCoverage posts HTTPS and parses the result', () async {
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => _FakeChannel(),
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.scheme, 'https');
          expect(request.url.host, 'beta.helius-rpc.com');
          expect(request.url.queryParameters['api-key'], 'test-key');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getPreConfCoverage');
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': {
                'networkSharePercent': 45.84,
                'coverageByRegion': {'fra': 0.27, 'slc': 0.1},
              },
            }),
            200,
          );
        }),
      );

      final coverage = await client.getPreConfCoverage();

      expect(coverage.networkSharePercent, 45.84);
      expect(coverage.coverageByRegion, {'fra': 0.27, 'slc': 0.1});
      client.close();
    });

    test('getPreConfCoverage surfaces JSON-RPC errors', () async {
      final client = PreconfWsClient(
        apiKey: 'test-key',
        channelFactory: (_) => _FakeChannel(),
        httpClient: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'error': {'code': -32602, 'message': 'bad request'},
            }),
            200,
          ),
        ),
      );

      await expectLater(
        client.getPreConfCoverage,
        throwsA(
          isA<PreconfRpcError>().having(
            (error) => error.message,
            'message',
            'bad request',
          ),
        ),
      );
      client.close();
    });

    test('filters cannot combine includeSource and includeBam', () {
      expect(
        () => PreconfFilter(
          includeSource: const [PreconfSource.helius],
          includeBam: false,
        ),
        throwsArgumentError,
      );
    });

    test('instruction filters serialize memcmp and dataSize', () {
      final filter = PreconfFilter(
        instructions: [
          const PreconfInstructionFilter(
            programId: 'program-1',
            memcmp: [
              PreconfMemcmp(offset: 8, bytes: 'deadbeef', encoding: 'hex'),
            ],
            dataSize: 16,
          ),
        ],
      );

      expect(filter.toJson()['instructions'], [
        {
          'programId': 'program-1',
          'memcmp': [
            {'offset': 8, 'bytes': 'deadbeef', 'encoding': 'hex'},
          ],
          'dataSize': 16,
        },
      ]);
    });
  });
}

Uint8List _transactionFrame({
  int slot = 1,
  int transactionIndex = 0,
  int status = PreconfStatus.success,
}) {
  final encoded = _encodedTransaction();
  return Uint8List(preconfHeadLength + encoded.length)
    ..[0] = preconfWireVersion
    ..setAll(1, _u64le(slot))
    ..setAll(9, _u64le(transactionIndex))
    ..[17] = status
    ..setAll(preconfHeadLength, encoded);
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

  @override
  void add(Object? event) => sent.add(event);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
