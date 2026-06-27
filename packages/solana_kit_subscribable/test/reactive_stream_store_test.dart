// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveStreamStore', () {
    group('initial state', () {
      test('is loading', () {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        final state = store.getUnifiedState();

        expect(state.status, ReactiveStreamState.loading);
        expect(state.isLoading, isTrue);
        expect(state.isLoaded, isFalse);
        expect(state.isError, isFalse);
        expect(state.isRetrying, isFalse);
        expect(state.data, isNull);
        expect(state.error, isNull);
        expect(store.getState(), isNull);
        expect(store.getError(), isNull);

        store.dispose();
        dataController.close().ignore();
        errorController.close().ignore();
      });
    });

    group('data received', () {
      test('transitions to loaded and exposes the data', () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        dataController.add(42);
        await Future<void>.delayed(Duration.zero);

        expect(store.getUnifiedState().status, ReactiveStreamState.loaded);
        expect(store.getUnifiedState().isLoaded, isTrue);
        expect(store.getUnifiedState().data, 42);
        expect(store.getState(), 42);

        store.dispose();
        await dataController.close();
        await errorController.close();
      });
    });

    group('error received', () {
      test('transitions to error when the error stream emits', () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        errorController.add(StateError('boom'));
        await Future<void>.delayed(Duration.zero);

        expect(store.getUnifiedState().status, ReactiveStreamState.error);
        expect(store.getUnifiedState().isError, isTrue);
        expect(store.getError(), isA<StateError>());

        store.dispose();
        await dataController.close();
        await errorController.close();
      });

      test('preserves the last data when transitioning to error', () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        dataController.add(7);
        errorController.add(StateError('boom'));
        await Future<void>.delayed(Duration.zero);

        expect(store.getUnifiedState().status, ReactiveStreamState.error);
        expect(store.getUnifiedState().data, 7);
        expect(store.getState(), 7);
        expect(store.getError(), isA<StateError>());

        store.dispose();
        await dataController.close();
        await errorController.close();
      });

      test('ignores null values emitted on the error stream', () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        errorController.add(null);
        await Future<void>.delayed(Duration.zero);

        expect(store.getUnifiedState().status, ReactiveStreamState.loading);
        expect(store.getError(), isNull);

        store.dispose();
        await dataController.close();
        await errorController.close();
      });

      test(
        'transitions to error when the data stream emits an error',
        () async {
          final dataController = StreamController<int>.broadcast(sync: true);
          final errorController = StreamController<Object?>.broadcast(
            sync: true,
          );
          final store = createReactiveStreamStore<int>(
            dataStream: dataController.stream,
            errorStream: errorController.stream,
          );

          dataController.addError(StateError('data boom'));
          await Future<void>.delayed(Duration.zero);

          expect(store.getUnifiedState().status, ReactiveStreamState.error);
          expect(store.getError(), isA<StateError>());

          store.dispose();
          await dataController.close();
          await errorController.close();
        },
      );

      test('ignores data-stream errors while retrying', () async {
        var retryCalled = false;
        final retryCompleter = Completer<void>();
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
          retry: () async {
            retryCalled = true;
            await retryCompleter.future;
          },
        );

        final retryFuture = store.retry();
        expect(store.getUnifiedState().status, ReactiveStreamState.retrying);

        // An error on the data stream while retrying should be ignored.
        dataController.addError(StateError('ignored'));
        await Future<void>.delayed(Duration.zero);

        expect(store.getUnifiedState().status, ReactiveStreamState.retrying);
        expect(store.getError(), isNull);

        retryCompleter.complete();
        await retryFuture;
        expect(retryCalled, isTrue);

        store.dispose();
        await dataController.close();
        await errorController.close();
      });
    });

    group('retry', () {
      test('transitions to retrying and awaits the retry function', () async {
        final retryCompleter = Completer<void>();
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
          retry: () async {
            await retryCompleter.future;
          },
        );

        final retryFuture = store.retry();
        expect(store.getUnifiedState().status, ReactiveStreamState.retrying);
        expect(store.getUnifiedState().isRetrying, isTrue);

        retryCompleter.complete();
        await retryFuture;

        // The retry function does not itself change state; data must arrive.
        expect(store.getUnifiedState().status, ReactiveStreamState.retrying);

        store.dispose();
        await dataController.close();
        await errorController.close();
      });

      test('throws StateError when no retry function is provided', () {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        expect(store.retry(), throwsA(isA<StateError>()));

        store.dispose();
        dataController.close().ignore();
        errorController.close().ignore();
      });

      test('throws StateError after dispose', () {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
          retry: () async {},
        );

        store.dispose();

        expect(store.retry(), throwsA(isA<StateError>()));

        dataController.close().ignore();
        errorController.close().ignore();
      });
    });

    group('subscribe', () {
      test('notifies subscribers when data arrives', () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        var notifications = 0;
        final unsubscribe = store.subscribe(() {
          notifications++;
        });

        dataController.add(1);
        await Future<void>.delayed(Duration.zero);

        expect(notifications, 1);

        unsubscribe();
        dataController.add(2);
        await Future<void>.delayed(Duration.zero);

        expect(notifications, 1);

        store.dispose();
        await dataController.close();
        await errorController.close();
      });

      test('returns a no-op unsubscribe after dispose', () {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        store.dispose();

        var notifications = 0;
        final unsubscribe = store.subscribe(() {
          notifications++;
        });

        dataController.add(1);
        unsubscribe();
        expect(notifications, 0);

        dataController.close().ignore();
        errorController.close().ignore();
      });

      test('unsubscribe is idempotent', () {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        final unsubscribe = store.subscribe(() {});
        unsubscribe();
        unsubscribe();

        store.dispose();
        dataController.close().ignore();
        errorController.close().ignore();
      });
    });

    group('dispose', () {
      test('cancels stream subscriptions and clears subscribers', () async {
        var dataCancelCount = 0;
        var errorCancelCount = 0;
        final dataController = StreamController<int>.broadcast(
          onCancel: () => dataCancelCount++,
          sync: true,
        );
        final errorController = StreamController<Object?>.broadcast(
          onCancel: () => errorCancelCount++,
          sync: true,
        );
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        var notifications = 0;
        store.subscribe(() {
          notifications++;
        });

        store.dispose();
        store.dispose();
        await Future<void>.delayed(Duration.zero);

        expect(dataCancelCount, 1);
        expect(errorCancelCount, 1);

        // After dispose, emitting data should not notify subscribers.
        dataController.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(notifications, 0);

        await dataController.close();
        await errorController.close();
      });
    });

    group('getUnifiedState', () {
      test('returns a snapshot with correct status, data, and error', () async {
        final dataController = StreamController<int>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final store = createReactiveStreamStore<int>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        dataController.add(99);
        await Future<void>.delayed(Duration.zero);

        final state = store.getUnifiedState();
        expect(state.status, ReactiveStreamState.loaded);
        expect(state.data, 99);
        expect(state.error, isNull);

        store.dispose();
        await dataController.close();
        await errorController.close();
      });
    });
  });

  group('createReactiveStreamStore', () {
    test('creates a working store backed by streams', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = createReactiveStreamStore<int>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );

      expect(store.getUnifiedState().status, ReactiveStreamState.loading);

      dataController.add(42);
      await Future<void>.delayed(Duration.zero);

      expect(store.getUnifiedState().status, ReactiveStreamState.loaded);
      expect(store.getState(), 42);

      store.dispose();
      await dataController.close();
      await errorController.close();
    });
  });

  group('createReactiveStreamStoreFromDataPublisher', () {
    test('creates a working store backed by a DataPublisher', () async {
      final publisher = createDataPublisher();
      final store = createReactiveStreamStoreFromDataPublisher<int>(
        dataPublisher: publisher,
        dataChannelName: 'data',
        errorChannelName: 'error',
      );

      expect(store.getUnifiedState().status, ReactiveStreamState.loading);

      publisher.publish('data', 42);
      await Future<void>.delayed(Duration.zero);

      expect(store.getUnifiedState().status, ReactiveStreamState.loaded);
      expect(store.getState(), 42);

      store.dispose();
    });
  });
}
