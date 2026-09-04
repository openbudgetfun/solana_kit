import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('stream error boundaries', () {
    for (final sourceIsData in [true, false]) {
      test('contains native errors from the ${sourceIsData ? 'data' : 'error'} '
          'source inside the merged stream', () async {
        final data = StreamController<int>.broadcast(sync: true);
        final errors = StreamController<Object?>.broadcast(sync: true);
        final received = <Object>[];
        final uncaught = <Object>[];
        late StreamSubscription<int> subscription;
        runZonedGuarded(
          () {
            subscription = createStreamFromDataAndErrorStreams<int>(
              dataStream: data.stream,
              errorStream: errors.stream,
            ).listen((_) {}, onError: received.add);
          },
          (error, _) => uncaught.add(error),
        );
        const failure = FormatException('malformed remote notification');
        if (sourceIsData) {
          data.addError(failure);
        } else {
          errors.addError(failure);
        }
        await pumpEventQueue();
        final hasDataListener = data.hasListener;
        final hasErrorListener = errors.hasListener;
        await subscription.cancel();
        await data.close();
        await errors.close();

        expect(uncaught, isEmpty);
        expect(received, [failure]);
        expect(hasDataListener, isFalse);
        expect(hasErrorListener, isFalse);
      });
    }

    test(
      'contains invalid typed notification payloads in the merged stream',
      () async {
        final data = StreamController<Object?>.broadcast(sync: true);
        final errors = StreamController<Object?>.broadcast(sync: true);
        final received = <Object>[];
        final uncaught = <Object>[];
        late StreamSubscription<int> subscription;
        runZonedGuarded(
          () {
            subscription = createStreamFromDataAndErrorStreams<int>(
              dataStream: data.stream.cast<int>(),
              errorStream: errors.stream,
            ).listen((_) {}, onError: received.add);
          },
          (error, _) => uncaught.add(error),
        );
        data.add('attacker-controlled wrong type');
        await pumpEventQueue();
        await subscription.cancel();
        await data.close();
        await errors.close();

        expect(uncaught, isEmpty);
        expect(received, [isA<TypeError>()]);
      },
    );

    test(
      'contains malformed demultiplexed messages in the destination stream',
      () async {
        final source = StreamController<Map<String, Object?>>.broadcast(
          sync: true,
        );
        final received = <Object>[];
        final values = <String>[];
        final uncaught = <Object>[];
        late StreamSubscription<String> subscription;
        runZonedGuarded(
          () {
            subscription = demultiplexStream<Map<String, Object?>, String>(
              source: source.stream,
              channelName: 'notification',
              messageTransformer: (message) =>
                  (message['channel']! as String, message['payload']),
            ).listen(values.add, onError: received.add);
          },
          (error, _) => uncaught.add(error),
        );
        source
          ..add({'channel': 123, 'payload': 'wrong channel type'})
          ..add({'channel': 'notification', 'payload': 123})
          ..add({'channel': 'notification', 'payload': 'valid'});
        await pumpEventQueue();
        await subscription.cancel();
        await source.close();

        expect(uncaught, isEmpty);
        expect(received, [isA<TypeError>(), isA<TypeError>()]);
        expect(values, ['valid']);
      },
    );

    test(
      'contains native errors from a reactive connection error stream',
      () async {
        final data = StreamController<int>.broadcast(sync: true);
        final errors = StreamController<Object?>.broadcast(sync: true);
        final uncaught = <Object>[];
        late ReactiveStreamStore<int> store;
        runZonedGuarded(
          () {
            store = createReactiveStreamStore<int>(
              createDataPublisher: (_) async => ReactiveStreamConnection<int>(
                dataStream: data.stream,
                errorStream: errors.stream,
              ),
            )..connect();
          },
          (error, _) => uncaught.add(error),
        );
        await pumpEventQueue();
        const failure = FormatException('invalid remote error frame');
        errors.addError(failure);
        await pumpEventQueue();
        final state = store.getState();
        store.dispose();
        await data.close();
        await errors.close();

        expect(uncaught, isEmpty);
        expect(state.isError, isTrue);
        expect(state.error, same(failure));
      },
    );
  });

  test('caller cancellation releases both reactive stream listeners', () async {
    final data = StreamController<int>.broadcast(sync: true);
    final errors = StreamController<Object?>.broadcast(sync: true);
    final caller = CancellationTokenSource();
    final store = createReactiveStreamStore<int>(
      createDataPublisher: (_) async => ReactiveStreamConnection<int>(
        dataStream: data.stream,
        errorStream: errors.stream,
      ),
    );
    store.withSignal(caller.token)();
    await pumpEventQueue();
    expect(data.hasListener, isTrue);
    expect(errors.hasListener, isTrue);

    caller.cancel('cancelled');
    await pumpEventQueue();
    final dataHasListener = data.hasListener;
    final errorsHaveListener = errors.hasListener;
    final state = store.getState();
    store.dispose();
    await data.close();
    await errors.close();

    expect(dataHasListener, isFalse);
    expect(errorsHaveListener, isFalse);
    expect(state.error, 'cancelled');
  });

  for (final disposeOnLoad in [true, false]) {
    test('does not open a connection after a loading subscriber '
        '${disposeOnLoad ? 'disposes' : 'resets'} the store', () async {
      var factoryCalls = 0;
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async {
          factoryCalls++;
          return const ReactiveStreamConnection<int>(
            dataStream: Stream<int>.empty(),
            errorStream: Stream<Object?>.empty(),
          );
        },
      );
      store
        ..subscribe(() {
          if (!store.getState().isLoading) return;
          if (disposeOnLoad) {
            store.dispose();
          } else {
            store.reset();
          }
        })
        ..connect();
      await pumpEventQueue();
      store.dispose();

      expect(factoryCalls, 0);
    });
  }
}
