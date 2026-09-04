import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  late _Channel channel;
  late RpcSubscriptions rpc;
  late CancellationTokenSource source;
  setUp(() {
    channel = _Channel();
    source = CancellationTokenSource();
    rpc = createSolanaRpcSubscriptionsFromTransport(
      createRpcSubscriptionsTransportFromChannelCreator(
        ({required abortSignal}) async => channel,
      ),
    );
  });
  tearDown(() async {
    source.cancel();
    await Future<void>.delayed(Duration.zero);
    await channel.messages.close();
    await channel.errors.close();
  });
  Future<Stream<Object?>> subscribe() => rpc.slotNotifications().subscribe(
    RpcSubscribeOptions(abortSignal: source.token),
  );

  test(
    'sends subscribe and awaits the matching server acknowledgement',
    () async {
      channel.autoReply = false;
      var completed = false;
      final future = subscribe()..then((_) => completed = true).ignore();
      await Future<void>.delayed(Duration.zero);
      expect(channel.sent, hasLength(1));
      expect(channel.sent.single, {
        'jsonrpc': '2.0',
        'id': isA<String>(),
        'method': 'slotSubscribe',
        'params': <Object?>[],
      });
      channel.reply({'id': 'another-request'}, 15);
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);
      channel.reply(channel.sent.single, 42);
      await future;
    },
  );

  test(
    'isolates notifications on a shared channel by method and server ID',
    () async {
      final secondSource = CancellationTokenSource();
      addTearDown(secondSource.cancel);
      final firstStream = await subscribe();
      final secondStream = await rpc.rootNotifications().subscribe(
        RpcSubscribeOptions(abortSignal: secondSource.token),
      );
      final first = <Object?>[];
      final second = <Object?>[];
      final firstListener = firstStream.listen(first.add);
      final secondListener = secondStream.listen(second.add);
      addTearDown(firstListener.cancel);
      addTearDown(secondListener.cancel);
      channel
        ..notify(1, 'slotNotification', {'slot': 123})
        ..notify(2, 'rootNotification', 456)
        ..notify(999, 'slotNotification', 'unrelated')
        ..notify(1, 'rootNotification', 'wrong method');
      channel.messages
        ..add('invalid')
        ..add({'jsonrpc': '1.0', 'method': 'slotNotification'})
        ..add({'jsonrpc': '2.0', 'method': 'slotNotification'});
      await Future<void>.delayed(Duration.zero);
      expect(first, [
        {'slot': 123},
      ]);
      expect(second, [456]);
    },
  );

  test(
    'unsubscribes with the server ID and detaches on cancellation',
    () async {
      final stream = await subscribe();
      final listener = stream.listen((_) {});
      source.cancel();
      await Future<void>.delayed(Duration.zero);
      expect(channel.sent.last['method'], 'slotUnsubscribe');
      expect(channel.sent.last['params'], [1]);
      expect(channel.messages.hasListener, isFalse);
      expect(channel.errors.hasListener, isFalse);
      await listener.cancel();
    },
  );

  test('accepts BigInt server subscription IDs', () async {
    channel.response = BigInt.from(100);
    final stream = await subscribe();
    final received = stream.first;
    channel.notify(BigInt.from(100), 'slotNotification', 'value');
    expect(await received, 'value');
    source.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(channel.sent.last['params'], [BigInt.from(100)]);
  });

  for (final result in <Object?>[null, '1', -1, BigInt.from(-1), 1.5, true]) {
    test('rejects malformed subscription ID $result', () async {
      channel.response = result;
      await expectLater(
        subscribe(),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.rpcSubscriptionsExpectedServerSubscriptionId,
          ),
        ),
      );
      expect(channel.messages.hasListener, isFalse);
    });
  }

  test('surfaces JSON-RPC errors', () async {
    channel.responseError = {'code': -32602, 'message': 'Invalid params'};
    await expectLater(subscribe(), throwsA(isA<SolanaError>()));
    expect(channel.messages.hasListener, isFalse);
  });

  test('aborted requests do not send a subscription', () async {
    source.cancel();
    await expectLater(subscribe(), throwsA(isA<AbortError>()));
    expect(channel.sent, isEmpty);
  });

  test(
    'cancellation before acknowledgement unsubscribes the late ID',
    () async {
      channel.autoReply = false;
      final reason = StateError('cancelled');
      final failure = expectLater(subscribe(), throwsA(same(reason)));
      await Future<void>.delayed(Duration.zero);
      expect(channel.sent, hasLength(1));
      source.cancel(reason);
      await failure;
      channel.reply(channel.sent.single, 25);
      await Future<void>.delayed(Duration.zero);
      expect(channel.sent.last['method'], 'slotUnsubscribe');
      expect(channel.sent.last['params'], [25]);
      expect(channel.messages.hasListener, isFalse);
    },
  );

  test('send failure rejects acquisition and detaches listeners', () async {
    final failure = StateError('send failed');
    channel.sendError = failure;
    await expectLater(subscribe(), throwsA(same(failure)));
    expect(channel.messages.hasListener, isFalse);
    expect(channel.errors.hasListener, isFalse);
  });

  for (final stream in [
    'errors-data',
    'errors-error',
    'messages-error',
    'done',
  ]) {
    test('channel failure rejects pending acquisition: $stream', () async {
      channel.autoReply = false;
      final failure = StateError('channel failed');
      final check = expectLater(
        subscribe(),
        throwsA(
          stream == 'done' ? isA<SolanaError>() : same(failure),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      switch (stream) {
        case 'errors-data':
          channel.errors.add(failure);
        case 'errors-error':
          channel.errors.addError(failure);
        case 'messages-error':
          channel.messages.addError(failure);
        case 'done':
          await channel.messages.close();
      }
      await check;
      expect(channel.messages.hasListener, isFalse);
    });
  }

  test('forwards channel errors after acknowledgement', () async {
    final stream = await subscribe();
    final failure = StateError('disconnected');
    final check = expectLater(stream, emitsError(same(failure)));
    channel.errors.add(failure);
    await check;
    expect(channel.messages.hasListener, isFalse);
  });

  test(
    'preserves notifications sent immediately after acknowledgement',
    () async {
      channel.autoReply = false;
      final future = subscribe();
      await Future<void>.delayed(Duration.zero);
      channel
        ..reply(channel.sent.single, 1)
        ..notify(1, 'slotNotification', 'immediate');
      final stream = await future;
      expect(await stream.first, 'immediate');
    },
  );

  test('bounds notifications queued before the first listener', () async {
    channel.autoReply = false;
    final future = subscribe();
    await Future<void>.delayed(Duration.zero);
    channel.reply(channel.sent.single, 1);
    for (var index = 0; index < 1025; index++) {
      channel.notify(1, 'slotNotification', index);
    }
    final stream = await future;
    final failure = Completer<Object>();
    final listener = stream.listen((_) {}, onError: failure.complete);
    expect(await failure.future, isA<StateError>());
    expect(channel.messages.hasListener, isFalse);
    await listener.cancel();
  });

  test('rejects a matching notification missing its result', () async {
    final stream = await subscribe();
    final check = expectLater(stream, emitsError(isA<FormatException>()));
    channel.messages.add({
      'jsonrpc': '2.0',
      'method': 'slotNotification',
      'params': {'subscription': 1},
    });
    await check;
  });

  test(
    'malformed server error data remains a handled acquisition failure',
    () async {
      channel.responseError = {
        'code': -32002,
        'message': 'failed',
        'data': <Object?>[],
      };
      await expectLater(subscribe(), throwsA(isA<Object>()));
      expect(channel.messages.hasListener, isFalse);
    },
  );

  for (final close in [false, true]) {
    test(
      'cleans up a cancelled pending request on channel failure: $close',
      () async {
        channel.autoReply = false;
        final check = expectLater(subscribe(), throwsA(isA<AbortError>()));
        await Future<void>.delayed(Duration.zero);
        source.cancel();
        await check;
        if (close) {
          await channel.messages.close();
        } else {
          channel.errors.add(StateError('disconnected'));
        }
        expect(channel.messages.hasListener, isFalse);
        expect(channel.errors.hasListener, isFalse);
      },
    );
  }

  test('failed unsubscribe has no unhandled error', () async {
    await subscribe();
    channel.sendError = StateError('already disconnected');
    source.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(channel.messages.hasListener, isFalse);
  });
}

class _Channel implements RpcSubscriptionsChannel {
  final messages = StreamController<Object?>.broadcast(sync: true);
  final errors = StreamController<Object?>.broadcast(sync: true);
  final sent = <Map<String, Object?>>[];
  bool autoReply = true;
  Object? response = _autoId;
  Object? responseError;
  Object? sendError;
  static const _autoId = Object();
  @override
  NotificationStreams get streams => NotificationStreams(
    notifications: messages.stream,
    errors: errors.stream,
  );
  @override
  Future<void> send(Object message) async {
    if (sendError case final Object error) return Future<void>.error(error);
    final request = message as Map<String, Object?>;
    sent.add(request);
    if (autoReply && (request['method']! as String).endsWith('Subscribe')) {
      scheduleMicrotask(
        () => reply(
          request,
          identical(response, _autoId) ? sent.length : response,
        ),
      );
    }
  }

  void reply(Map<String, Object?> request, Object? result) => messages.add({
    'jsonrpc': '2.0',
    'id': request['id'],
    if (responseError != null) 'error': responseError else 'result': result,
  });
  void notify(Object id, String method, Object? result) => messages.add({
    'jsonrpc': '2.0',
    'method': method,
    'params': {'subscription': id, 'result': result},
  });
}
