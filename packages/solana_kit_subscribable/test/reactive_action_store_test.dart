// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveActionStore', () {
    group('initial state', () {
      test('is idle', () {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        expect(store.getState().status, ReactiveActionState.idle);
        expect(store.getState().isIdle, isTrue);
        expect(store.getState().isRunning, isFalse);
        expect(store.getState().isSuccess, isFalse);
        expect(store.getState().isError, isFalse);
        expect(store.getState().result, isNull);
        expect(store.getState().error, isNull);
      });
    });

    group('dispatchAsync', () {
      test(
        'transitions through running to success and returns the result',
        () async {
          final store = createReactiveActionStore<List<Object?>, int>(
            (args) async => 42,
          );

          final result = await store.dispatchAsync([]);

          expect(result, 42);
          expect(store.getState().status, ReactiveActionState.success);
          expect(store.getState().isSuccess, isTrue);
          expect(store.getState().result, 42);
          expect(store.getState().error, isNull);
        },
      );

      test('transitions to running while the action is in flight', () async {
        final completer = Completer<int>();
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) => completer.future,
        );

        final dispatchFuture = store.dispatchAsync([]);
        expect(store.getState().status, ReactiveActionState.running);
        expect(store.getState().isRunning, isTrue);

        completer.complete(7);
        await dispatchFuture;

        expect(store.getState().status, ReactiveActionState.success);
      });

      test(
        'transitions to error and rethrows when the action throws',
        () async {
          final error = Exception('boom');
          final store = createReactiveActionStore<List<Object?>, int>(
            (args) async => throw error,
          );

          await expectLater(store.dispatchAsync([]), throwsA(error));

          expect(store.getState().status, ReactiveActionState.error);
          expect(store.getState().isError, isTrue);
          expect(store.getState().error, error);
        },
      );

      test(
        'preserves the previous result when transitioning to error',
        () async {
          final store = createReactiveActionStore<List<Object?>, int>(
            (args) async => args.isEmpty ? 42 : throw Exception('nope'),
          );

          await store.dispatchAsync([]);
          expect(store.getState().result, 42);

          await expectLater(
            store.dispatchAsync([1]),
            throwsA(isA<Exception>()),
          );

          expect(store.getState().status, ReactiveActionState.error);
          expect(store.getState().result, 42);
          expect(store.getState().error, isA<Exception>());
        },
      );

      test('throws StateError after dispose', () async {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        store.dispose();

        await expectLater(
          store.dispatchAsync([]),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('dispatch', () {
      test(
        'fires-and-forget transitions to running without awaiting',
        () async {
          final completer = Completer<int>();
          final store = createReactiveActionStore<List<Object?>, int>(
            (args) => completer.future,
          );

          store.dispatch([]);

          expect(store.getState().status, ReactiveActionState.running);

          completer.complete(99);
          await Future<void>.delayed(Duration.zero);

          expect(store.getState().status, ReactiveActionState.success);
          expect(store.getState().result, 99);
        },
      );
    });

    group('reset', () {
      test('returns the store to the idle state', () async {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        await store.dispatchAsync([]);
        expect(store.getState().status, ReactiveActionState.success);

        store.reset();

        expect(store.getState().status, ReactiveActionState.idle);
        expect(store.getState().isIdle, isTrue);
        expect(store.getState().result, isNull);
        expect(store.getState().error, isNull);
      });
    });

    group('subscribe', () {
      test('notifies subscribers on state changes', () async {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        var notifications = 0;
        final unsubscribe = store.subscribe(() {
          notifications++;
        });

        await store.dispatchAsync([]);

        // running + success = 2 notifications.
        expect(notifications, 2);

        unsubscribe();
      });

      test('stops notifying after unsubscribe', () async {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        var notifications = 0;
        final unsubscribe = store.subscribe(() {
          notifications++;
        });

        unsubscribe();
        unsubscribe();

        await store.dispatchAsync([]);

        expect(notifications, 0);
      });

      test('returns a no-op unsubscribe after dispose', () {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        store.dispose();

        var notifications = 0;
        final unsubscribe = store.subscribe(() {
          notifications++;
        });

        unsubscribe();
        expect(notifications, 0);
      });
    });

    group('dispose', () {
      test('clears subscribers and is idempotent', () async {
        final store = createReactiveActionStore<List<Object?>, int>(
          (args) async => 42,
        );

        var notifications = 0;
        store.subscribe(() {
          notifications++;
        });

        store.dispose();
        store.dispose();

        // No notifications fire after dispose because subscribers were cleared.
        store.reset();
        expect(notifications, 0);
      });
    });
  });

  group('createReactiveActionStore', () {
    test('creates a working store', () async {
      final store = createReactiveActionStore<List<Object?>, String>(
        (args) async => 'hello',
      );

      expect(store.getState().status, ReactiveActionState.idle);

      final result = await store.dispatchAsync([]);

      expect(result, 'hello');
      expect(store.getState().status, ReactiveActionState.success);
      expect(store.getState().result, 'hello');
    });
  });
}
