import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('ReactiveActionStore cancellation', () {
    test('passes a fresh cancellation token and the dispatch args', () async {
      final signals = <CancellationToken>[];
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) async {
          signals.add(signal);
          return args.single! as String;
        },
      );

      expect(await store.dispatchAsync(['first']), 'first');
      expect(signals.single.isCancelled, isFalse);

      expect(await store.dispatchAsync(['second']), 'second');
      expect(signals.first.isCancelled, isTrue);
      expect(signals.last.isCancelled, isFalse);
    });

    test('supersession cancels and rejects the previous dispatch', () async {
      final signals = <CancellationToken>[];
      final results = <Completer<String>>[];
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) {
          signals.add(signal);
          final result = Completer<String>();
          results.add(result);
          return result.future;
        },
      );

      final first = store.dispatchAsync(['first']);
      final second = store.dispatchAsync(['second']);

      expect(signals.first.isCancelled, isTrue);
      await expectLater(
        first,
        throwsA(isA<ReactiveActionCancellationException>()),
      );

      results.last.complete('winner');
      expect(await second, 'winner');
      expect(store.getState().result, 'winner');
    });

    test('suppresses a superseded action result that arrives late', () async {
      final results = [Completer<String>(), Completer<String>()];
      var index = 0;
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) => results[index++].future,
      );

      final second = (store..dispatch(['first'])).dispatchAsync(['second']);
      results[1].complete('new');
      await second;
      results[0].complete('stale');
      await pumpEventQueue();

      expect(store.getState().result, 'new');
      expect(store.getState().status, ReactiveActionState.success);
    });

    test('suppresses and consumes a superseded late action error', () async {
      final firstFailure = Completer<void>();
      var invocation = 0;
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) async {
          if (invocation++ == 0) {
            await firstFailure.future;
            throw StateError('late loser');
          }
          return 'new';
        },
      );

      expect(
        await (store..dispatch(['first'])).dispatchAsync(['second']),
        'new',
      );
      firstFailure.complete();
      await pumpEventQueue();

      expect(store.getState().result, 'new');
      expect(store.getState().error, isNull);
    });

    test(
      'reset cancels in-flight work and permanently suppresses it',
      () async {
        final result = Completer<String>();
        late CancellationToken signal;
        final store = createReactiveActionStore<List<Object?>, String>(
          (actionSignal, args) {
            signal = actionSignal;
            return result.future;
          },
        );

        final dispatched = store.dispatchAsync([]);
        store.reset();

        expect(signal.isCancelled, isTrue);
        expect(store.getState().status, ReactiveActionState.idle);
        await expectLater(
          dispatched,
          throwsA(isA<ReactiveActionCancellationException>()),
        );

        result.complete('late');
        await pumpEventQueue();
        expect(store.getState().status, ReactiveActionState.idle);
        expect(store.getState().result, isNull);
      },
    );

    test(
      'dispose cancels in-flight work and suppresses late completion',
      () async {
        final result = Completer<String>();
        late CancellationToken signal;
        var notifications = 0;
        final store = createReactiveActionStore<List<Object?>, String>(
          (actionSignal, args) {
            signal = actionSignal;
            return result.future;
          },
        );
        store.subscribe(() => notifications++); // ignore: cascade_invocations

        final dispatched = store.dispatchAsync([]);
        expect(notifications, 1);
        store.dispose();

        expect(signal.isCancelled, isTrue);
        await expectLater(
          dispatched,
          throwsA(isA<ReactiveActionCancellationException>()),
        );
        result.complete('late');
        await pumpEventQueue();

        expect(notifications, 1);
        await expectLater(store.dispatchAsync([]), throwsStateError);
      },
    );

    test('withSignal surfaces caller cancellation reason as error', () async {
      final source = CancellationTokenSource();
      final reason = StateError('caller stopped');
      late CancellationToken actionSignal;
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) {
          actionSignal = signal;
          return Completer<String>().future;
        },
      );

      final dispatched = store.withSignal(source.token).dispatchAsync([
        'request',
      ]);
      source.cancel(reason);

      await expectLater(dispatched, throwsA(same(reason)));
      expect(actionSignal.isCancelled, isTrue);
      expect(actionSignal.reason, same(reason));
      expect(store.getState().status, ReactiveActionState.error);
      expect(store.getState().error, same(reason));
    });

    test('withSignal preserves stale result on caller cancellation', () async {
      final pending = Completer<String>();
      var invocation = 0;
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) =>
            invocation++ == 0 ? Future.value('cached') : pending.future,
      );
      await store.dispatchAsync([]);
      final source = CancellationTokenSource();
      final reason = ArgumentError('timeout');

      final dispatched = store.withSignal(source.token).dispatchAsync([]);
      source.cancel(reason);
      await expectLater(dispatched, throwsA(same(reason)));

      expect(store.getState().result, 'cached');
      expect(store.getState().error, same(reason));
    });

    test(
      'an already-cancelled caller token does not invoke the action',
      () async {
        final reason = StateError('already cancelled');
        final source = CancellationTokenSource()..cancel(reason);
        var invocations = 0;
        final store = createReactiveActionStore<List<Object?>, String>(
          (signal, args) async {
            invocations++;
            return 'unexpected';
          },
        );

        await expectLater(
          store.withSignal(source.token).dispatchAsync([]),
          throwsA(same(reason)),
        );
        expect(invocations, 0);
        expect(store.getState().error, same(reason));
      },
    );

    test(
      'an already-cancelled wrapper does not prevent later bare dispatches',
      () async {
        final source = CancellationTokenSource()..cancel();
        final store = createReactiveActionStore<List<Object?>, String>(
          (signal, args) async => 'recovered',
        );

        await expectLater(
          store.withSignal(source.token).dispatchAsync([]),
          throwsA(isA<ReactiveActionCancellationException>()),
        );
        expect(await store.dispatchAsync([]), 'recovered');
        expect(store.getState().status, ReactiveActionState.success);
      },
    );

    test(
      'a newer bare dispatch silently supersedes a caller-bound dispatch',
      () async {
        final caller = CancellationTokenSource();
        final pending = Completer<String>();
        var invocation = 0;
        final store = createReactiveActionStore<List<Object?>, String>(
          (signal, args) =>
              invocation++ == 0 ? pending.future : Future.value('bare winner'),
        );

        final first = store.withSignal(caller.token).dispatchAsync([]);
        final firstExpectation = expectLater(
          first,
          throwsA(isA<ReactiveActionCancellationException>()),
        );
        expect(await store.dispatchAsync([]), 'bare winner');
        await firstExpectation;
        caller.cancel(StateError('too late'));
        await pumpEventQueue();

        expect(store.getState().result, 'bare winner');
        expect(store.getState().error, isNull);
      },
    );

    test('fire-and-forget dispatch consumes action failures', () async {
      final uncaught = <Object>[];
      late ReactiveActionStore<List<Object?>, String> store;

      await runZonedGuarded(() async {
        store = createReactiveActionStore<List<Object?>, String>(
          (signal, args) async => throw StateError('boom'),
        )..dispatch([]);
        await pumpEventQueue();
      }, (error, _) => uncaught.add(error));

      expect(uncaught, isEmpty);
      expect(store.getState().status, ReactiveActionState.error);
      expect(store.getState().error, isA<StateError>());
    });

    test('does not notify for equivalent running or idle snapshots', () {
      final store = createReactiveActionStore<List<Object?>, String>(
        (signal, args) => Completer<String>().future,
      );
      var notifications = 0;
      store
        ..subscribe(() => notifications++)
        ..reset();
      expect(notifications, 0);
      store
        ..dispatch([])
        ..dispatch([]);
      expect(notifications, 1);
    });
  });
}
