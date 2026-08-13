// ignore_for_file: cascade_invocations
import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

/// Pumps the microtask/timer queue so the store's async `connect()` factory
/// resolves and the store subscribes to its streams before we emit events.
Future<void> pump([int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('ReactiveStreamStore (v7)', () {
    test('starts in the idle state', () {
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => const ReactiveStreamConnection<int>(
          dataStream: Stream<int>.empty(),
          errorStream: Stream<Object?>.empty(),
        ),
      );
      expect(store.getState().status, ReactiveStreamState.idle);
      expect(store.getState().isIdle, isTrue);
      expect(store.getState().data, isNull);
      expect(store.getState().error, isNull);
    });

    test('transitions through loading to loaded on connect', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => ReactiveStreamConnection<int>(
          dataStream: dataController.stream,
          errorStream: const Stream<Object?>.empty(),
        ),
      );
      store.connect();
      expect(store.getState().status, ReactiveStreamState.loading);
      await pump(); // let the factory resolve and the store subscribe
      dataController.add(42);
      await pump();
      expect(store.getState().status, ReactiveStreamState.loaded);
      expect(store.getState().isLoaded, isTrue);
      expect(store.getState().data, 42);
      expect(store.getState().error, isNull);
      await dataController.close();
      store.dispose();
    });

    test('transitions to error and preserves the last known data', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => ReactiveStreamConnection<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        ),
      );
      store.connect();
      await pump();
      dataController.add(7);
      await pump();
      errorController.add(StateError('boom'));
      await pump();
      expect(store.getState().status, ReactiveStreamState.error);
      expect(store.getState().isError, isTrue);
      expect(store.getState().data, 7);
      expect(store.getState().error, isA<StateError>());
      await dataController.close();
      await errorController.close();
      store.dispose();
    });

    test('a subsequent connect preserves data through loading (SWR)', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => ReactiveStreamConnection<int>(
          dataStream: dataController.stream,
          errorStream: const Stream<Object?>.empty(),
        ),
      );
      store.connect();
      await pump();
      dataController.add(5);
      await pump();
      expect(store.getState().data, 5);
      // Reconnect: the new connection is loading but the prior data survives.
      store.connect();
      expect(store.getState().status, ReactiveStreamState.loading);
      expect(store.getState().data, 5);
      await pump();
      dataController.add(9);
      await pump();
      expect(store.getState().status, ReactiveStreamState.loaded);
      expect(store.getState().data, 9);
      expect(store.getState().error, isNull);
      await dataController.close();
      store.dispose();
    });

    test(
      'reset returns the store to idle and aborts the active connection',
      () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          createDataPublisher: (_) async => ReactiveStreamConnection<int>(
            dataStream: dataController.stream,
            errorStream: const Stream<Object?>.empty(),
          ),
        );
        store.connect();
        await pump();
        dataController.add(1);
        await pump();
        expect(store.getState().status, ReactiveStreamState.loaded);
        store.reset();
        expect(store.getState().status, ReactiveStreamState.idle);
        // A late emission from the aborted connection must not update state.
        dataController.add(99);
        await pump();
        expect(store.getState().status, ReactiveStreamState.idle);
        expect(store.getState().data, isNull);
        await dataController.close();
        store.dispose();
      },
    );

    test('withSignal composes a caller-owned cancellation token', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => ReactiveStreamConnection<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        ),
      );
      final killSource = CancellationTokenSource();
      final killableConnect = store.withSignal(killSource.token);
      killableConnect();
      expect(store.getState().status, ReactiveStreamState.loading);
      // Aborting the caller's signal surfaces the abort reason as error.
      killSource.cancel('killed');
      await pump();
      expect(store.getState().status, ReactiveStreamState.error);
      expect(store.getState().error, 'killed');
      await dataController.close();
      await errorController.close();
      store.dispose();
    });

    test('withSignal supersession stays silent on a newer connect', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => ReactiveStreamConnection<int>(
          dataStream: dataController.stream,
          errorStream: const Stream<Object?>.empty(),
        ),
      );
      final killSource = CancellationTokenSource();
      final killableConnect = store.withSignal(killSource.token);
      killableConnect();
      await pump();
      // A bare connect() supersedes the signalled connection; the caller
      // signal firing afterwards must NOT overwrite the newer connection's
      // state.
      store.connect();
      await pump();
      dataController.add(3);
      await pump();
      killSource.cancel('killed');
      await pump();
      expect(store.getState().status, ReactiveStreamState.loaded);
      expect(store.getState().data, 3);
      await dataController.close();
      store.dispose();
    });

    test('subscribe notifies on state changes and is idempotent', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => ReactiveStreamConnection<int>(
          dataStream: dataController.stream,
          errorStream: const Stream<Object?>.empty(),
        ),
      );
      var calls = 0;
      final unsubscribe = store.subscribe(() {
        calls++;
      });
      store.connect(); // loading notification
      await pump(); // subscribe
      final callsAfterConnect = calls;
      dataController.add(1); // loaded notification
      await pump();
      expect(calls, greaterThan(callsAfterConnect));
      unsubscribe();
      unsubscribe(); // idempotent
      final callsAfterUnsubscribe = calls;
      dataController.add(3);
      await pump();
      expect(calls, callsAfterUnsubscribe);
      await dataController.close();
      store.dispose();
    });

    test('connect after dispose throws', () {
      final store = createReactiveStreamStore<int>(
        createDataPublisher: (_) async => const ReactiveStreamConnection<int>(
          dataStream: Stream<int>.empty(),
          errorStream: Stream<Object?>.empty(),
        ),
      );
      store.dispose();
      expect(store.connect, throwsStateError);
    });
  });
}
