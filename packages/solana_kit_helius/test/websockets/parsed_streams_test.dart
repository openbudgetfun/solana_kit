import 'dart:async';
import 'dart:convert';

import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('ParsedStreamsClient', () {
    test('URLs encode the API key', () {
      final uri = Uri.parse(parsedStreamsUrl('key&token=1'));
      expect(uri.queryParameters['api-key'], 'key&token=1');
      expect(parsedStreamsDiscoveryUrl('key-1'), contains('fs-beta'));
    });

    test('subscribes, streams a full notification, and unsubscribes', () async {
      final channel = _FakeChannel();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(
          programs: ['program-1'],
          instructionNames: ['route'],
          accounts: ParsedTransactionFilterAccounts(
            include: ['account-1'],
            roles: {'user': 'account-1'},
          ),
        ),
        options: const ParsedTransactionSubscribeOptions(),
      );
      await _flush();

      final request = jsonDecode(
        channel.sink.sent.single! as String,
      ) as Map<String, Object?>;
      expect(request['method'], 'parsedTransactionSubscribe');
      expect(request['params'], [
        {
          'programs': ['program-1'],
          'instructionNames': ['route'],
          'accounts': {
            'include': ['account-1'],
            'roles': {'user': 'account-1'},
          },
        },
        {'details': 'full'},
      ]);

      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 42}),
      );
      final subscription = await pending;
      expect(subscription.subscriptionId, 42);

      channel.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'method': 'parsedTransactionNotification',
          'params': {
            'subscription': 42,
            'result': {
              'context': {'slot': 55},
              'value': {
                'transaction': {
                  'signature': 'sig-1',
                  'slot': 55,
                  'feePayer': 'payer',
                  'fee': 5000,
                  'accountKeys': ['payer'],
                  'status': 'ok',
                },
                'instructions': [
                  {
                    'instructionIndex': 0,
                    'innerInstructionIndex': null,
                    'stackHeight': 1,
                    'programId': 'program-1',
                    'instructionName': 'route',
                    'decoded': {
                      'args': {'amount': '1'},
                      'accounts': <Object?>[],
                    },
                  },
                ],
                'matchedIndexes': [0],
              },
            },
          },
        }),
      );

      final notification = await subscription.notifications.first.timeout(
        const Duration(seconds: 1),
      );
      expect(notification.contextSlot, 55);
      final value = notification.value as ParsedTransactionValue;
      expect(value.transaction.signature, 'sig-1');
      expect(value.matchedIndexes, [0]);
      expect(value.instructions.single.instructionName, 'route');

      final unsubscribe = subscription.unsubscribe();
      final sent = await _waitForSent(channel.sink, 2);
      final unsubscribeRequest =
          jsonDecode(sent.last! as String) as Map<String, Object?>;
      expect(unsubscribeRequest['method'], 'parsedTransactionUnsubscribe');
      expect(unsubscribeRequest['params'], [42]);
      channel.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': unsubscribeRequest['id'],
          'result': true,
        }),
      );
      expect(await unsubscribe, isTrue);
      client.close();
    });

    test('raw details parse raw notifications', () async {
      final channel = _FakeChannel();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
        options: const ParsedTransactionSubscribeOptions(
          details: ParsedStreamDetails.raw,
        ),
      );
      await _flush();
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}),
      );
      final subscription = await pending;

      channel.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'method': 'parsedTransactionNotification',
          'params': {
            'subscription': 1,
            'result': {
              'context': {'slot': 9},
              'value': {
                'transaction': {
                  'signature': 'sig-raw',
                  'slot': 9,
                  'feePayer': 'payer',
                  'fee': 1,
                  'status': 'ok',
                },
                'instructions': [
                  {
                    'instructionIndex': 0,
                    'programId': 'program-1',
                    'data': 'base58',
                  },
                ],
              },
            },
          },
        }),
      );

      final notification = await subscription.notifications.first.timeout(
        const Duration(seconds: 1),
      );
      final value = notification.value as RawTransactionValue;
      expect(value.transaction.signature, 'sig-raw');
      expect(value.instructions.single.data, 'base58');
      client.close();
    });

    test('reconnects, resubscribes, and reports the last slot', () async {
      final channels = <_FakeChannel>[];
      final reconnect = Completer<ParsedStreamsReconnectInfo>();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (uri) {
          final channel = _FakeChannel();
          channels.add(channel);
          return channel;
        },
        onReconnect: reconnect.complete,
        maxReconnectAttempts: 2,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      final first = await _waitForChannel(channels, 0);
      await _flush();
      first.incoming.add(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}));
      final subscription = await pending;

      first.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'method': 'parsedTransactionNotification',
          'params': {
            'subscription': 1,
            'result': {
              'context': {'slot': 12},
              'value': _fullValue('sig-1', 12),
            },
          },
        }),
      );

      await first.incoming.close();
      final second = await _waitForChannel(channels, 1);
      final sent = await _waitForSent(second.sink, 1);
      final resubscribe =
          jsonDecode(sent.single! as String) as Map<String, Object?>;
      expect(resubscribe['method'], 'parsedTransactionSubscribe');
      second.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': resubscribe['id'],
          'result': 2,
        }),
      );

      final info = await reconnect.future.timeout(const Duration(seconds: 5));
      expect(info.closeCode, 1006);
      expect(info.lastSlot, 12);

      final deadline = DateTime.now().add(const Duration(seconds: 1));
      while (subscription.subscriptionId != 2 &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(subscription.subscriptionId, 2);
      client.close();
    });

    test('describeProgram opens the discovery endpoint', () async {
      Uri? requested;
      final channel = _FakeChannel();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (uri) {
          requested = uri;
          return channel;
        },
      );

      final pending = client.describeProgram('program-1');
      await _flush();
      expect(requested!.host, 'fs-beta.helius-rpc.com');
      final request = jsonDecode(
        channel.sink.sent.single! as String,
      ) as Map<String, Object?>;
      expect(request['method'], 'describeProgram');
      expect(request['params'], [
        {'program': 'program-1'},
      ]);

      channel.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'result': {
            'id': 'program-1',
            'name': 'program',
            'instructions': ['route'],
            'events': ['swap'],
            'roles': ['user'],
          },
        }),
      );

      final description = await pending.timeout(const Duration(seconds: 1));
      expect(description.id, 'program-1');
      expect(description.instructions, ['route']);
      client.close();
    });

    test('surfaces JSON-RPC errors from subscribe', () async {
      final channel = _FakeChannel();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      await _flush();
      channel.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': -32602, 'message': 'bad filter'},
        }),
      );

      await expectLater(
        pending,
        throwsA(
          isA<ParsedStreamsError>()
              .having((error) => error.code, 'code', -32602)
              .having((error) => error.message, 'message', 'bad filter'),
        ),
      );
      client.close();
    });

    test('close ends live subscriptions', () async {
      final channel = _FakeChannel();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      await _flush();
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}),
      );
      final subscription = await pending;
      final done = Completer<void>();
      subscription.notifications.listen((_) {}, onDone: done.complete);

      client.close();
      await done.future.timeout(const Duration(seconds: 1));
    });

    test('reports the first drop of an outage through onDisconnect', () async {
      final channels = <_FakeChannel>[];
      final disconnect = Completer<ParsedStreamsReconnectInfo>();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (uri) {
          final channel = _FakeChannel();
          channels.add(channel);
          return channel;
        },
        onDisconnect: disconnect.complete,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      final first = await _waitForChannel(channels, 0);
      await _flush();
      first.incoming.add(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}));
      await pending;

      first.incoming.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'method': 'parsedTransactionNotification',
          'params': {
            'subscription': 1,
            'result': {
              'context': {'slot': 12},
              'value': _fullValue('sig-1', 12),
            },
          },
        }),
      );

      // Let the notification settle so the delivered slot is recorded.
      await _flush();

      await first.incoming.close();
      final info = await disconnect.future.timeout(const Duration(seconds: 5));
      expect(info.closeCode, 1006);
      expect(info.lastSlot, 12);
      client.close();
    });

    test('does not re-fire onDisconnect within one outage', () async {
      final channels = <_FakeChannel>[];
      final disconnects = <ParsedStreamsReconnectInfo>[];
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (uri) {
          final channel = _FakeChannel();
          channels.add(channel);
          return channel;
        },
        onDisconnect: disconnects.add,
        maxReconnectAttempts: 3,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      final first = await _waitForChannel(channels, 0);
      await _flush();
      first.incoming.add(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}));
      await pending;

      // First drop opens the outage and fires the callback.
      await first.incoming.close();
      final second = await _waitForChannel(channels, 1);
      await _flush();
      // A drop before the resubscription completes stays inside the same
      // outage and must not fire again.
      await second.incoming.close();

      await _flush();
      expect(disconnects, hasLength(1));
      client.close();
    });

    test('close() does not fire onDisconnect', () async {
      final channel = _FakeChannel();
      var disconnects = 0;
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
        onDisconnect: (_) => disconnects++,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      await _flush();
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}),
      );
      await pending;

      client.close();
      await _flush();
      expect(disconnects, 0);
    });

    test('onDisconnect fires even when reconnect is disabled', () async {
      final channel = _FakeChannel();
      final disconnect = Completer<ParsedStreamsReconnectInfo>();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
        reconnect: false,
        onDisconnect: disconnect.complete,
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      await _flush();
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}),
      );
      await pending;

      await channel.incoming.close();
      final info = await disconnect.future.timeout(const Duration(seconds: 5));
      expect(info.closeCode, 1006);
      client.close();
    });

    test('a throwing onDisconnect does not break the stream', () async {
      final channel = _FakeChannel();
      final client = ParsedStreamsClient(
        apiKey: 'test-key',
        channelFactory: (_) => channel,
        reconnect: false,
        onDisconnect: (_) => throw StateError('callback blew up'),
      );

      final pending = client.parsedTransactionSubscribe(
        const ParsedTransactionFilter(programs: ['program-1']),
      );
      await _flush();
      channel.incoming.add(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 1}),
      );
      final subscription = await pending;

      await channel.incoming.close();
      final done = Completer<void>();
      subscription.notifications.listen((_) {}, onDone: done.complete);
      await done.future.timeout(const Duration(seconds: 1));
      client.close();
    });
  });
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

Future<_FakeChannel> _waitForChannel(
  List<_FakeChannel> channels,
  int index,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));

  while (channels.length <= index) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Expected channel $index');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  return channels[index];
}

Future<List<Object?>> _waitForSent(_FakeSink sink, int count) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));

  while (sink.sent.length < count) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Expected $count sends, got ${sink.sent.length}');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  return sink.sent;
}

Map<String, Object?> _fullValue(String signature, int slot) => {
  'transaction': {
    'signature': signature,
    'slot': slot,
    'feePayer': 'payer',
    'fee': 1,
    'accountKeys': ['payer'],
    'status': 'ok',
  },
  'instructions': <Object?>[],
};

class _FakeChannel implements WebSocketChannel {
  final incoming = StreamController<Object?>();
  final readyCompleter = Completer<void>()..complete();

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
