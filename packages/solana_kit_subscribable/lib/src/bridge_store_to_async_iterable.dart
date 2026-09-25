import 'dart:async';

import 'package:solana_kit_subscribable/src/cancellation_token.dart';
import 'package:solana_kit_subscribable/src/reactive_stream_store.dart';

/// Adapts a [ReactiveStreamStore] into a [Stream], so a push-based reactive
/// store can be driven by pull-based code that consumes a stream by
/// `await for`-ing it.
///
/// The bridge only *observes* the store; it does not open or tear down the
/// connection. Like every other consumer in this ecosystem, a store does
/// nothing until you `connect()` it, so the caller owns the store's lifecycle:
/// `connect()` the store yourself (typically binding the same
/// [cancellationToken] via `ReactiveStreamStore.withSignal`), and `reset()` it
/// when you're done if you intend to reuse it. The bridge subscribes, yields
/// the store's current and subsequent values, and unsubscribes when iteration
/// ends.
///
/// On iteration it seeds from the store's current snapshot, then yields its
/// lifecycle:
/// - `loaded` → yields the value (the one already present when iteration
///   begins, then each subsequent update), unless an optional [shouldYield]
///   predicate rejects it. Latest-wins: if several notifications land between
///   pulls, only the most recent unconsumed value is yielded.
/// - `error` → throws, so the consuming `await for` rejects. The store ignores
///   null error notifications. An error takes precedence
///   over a buffered value: if a `loaded` value is still pending when an
///   `error` arrives, that value is dropped and the error propagates.
/// - [cancellationToken] fires → ends the stream cleanly (no error). A
///   subscription never completes on its own, so cancellation is how the
///   stream terminates: cancelling it unblocks a parked `await for` and ends
///   the loop. Bind the same token to the store's connection
///   (`store.withSignal(token)()`) so the cancellation tears the
///   underlying stream down too.
///
/// Cancelling the [StreamSubscription] also releases the bridge's observer,
/// even while the store is quiet. Exceptions thrown by [shouldYield] are
/// delivered as stream errors and release the observer as well.
///
/// However iteration ends, the bridge unsubscribes from the store. It does
/// not `reset()` the store; that is the caller's decision.
Stream<T> bridgeStoreToAsyncIterable<T>(
  ReactiveStreamStore<T> store, {
  CancellationToken? cancellationToken,
  bool Function(T value)? shouldYield,
}) {
  // Latest-wins single-slot buffer plus a one-shot "something changed"
  // completer the loop parks on. `wake()` completes the current completer and
  // arms a fresh one for the next park.
  ({T value})? latest;
  Object? failure;
  StackTrace? failureStackTrace;
  var deferred = Completer<void>();
  var cancelled = false;
  late StreamController<T> controller;
  late Future<void> pumping;

  void wake() {
    final completer = deferred;
    deferred = Completer<void>();
    completer.complete();
  }

  void onChange() {
    try {
      final state = store.getState();

      if (state.status == ReactiveStreamState.loaded) {
        // Rejected values leave the bridge parked until another update.
        if (shouldYield != null && !shouldYield(state.data as T)) return;
        latest = (value: state.data as T);
        wake();
      } else if (state.status == ReactiveStreamState.error) {
        failure = state.error;
        wake();
      }
    } on Object catch (error, stackTrace) {
      // Predicates run inside store notifications. Their failures belong to
      // the stream consumer and must release this observer.
      failure = error;
      failureStackTrace = stackTrace;
      wake();
    }
  }

  Future<void> pump() async {
    unawaited(cancellationToken?.future.then((_) => wake()));
    final unsubscribe = store.subscribe(onChange);

    try {
      // Seed an already-connected store without taking over its lifecycle.
      onChange();

      while (true) {
        if (cancelled || (cancellationToken?.isCancelled ?? false)) return;

        if (controller.isPaused) {
          await deferred.future;
          continue;
        }

        if (failure != null) {
          final error = failure!;
          controller.addError(
            error is Error || error is Exception ? error : StateError('$error'),
            failureStackTrace,
          );
          return;
        }

        if (latest != null) {
          final value = latest!.value;
          latest = null;
          controller.add(value);
          // Let the consumer pause or cancel before delivering another value.
          await Future<void>.value();
          continue;
        }

        await deferred.future;
      }
    } finally {
      unsubscribe();
      unawaited(controller.close());
    }
  }

  controller = StreamController<T>(
    onListen: () {
      pumping = Future<void>.microtask(pump);
    },
    onResume: wake,
    onCancel: () {
      // An async* subscription cannot interrupt an await on a quiet store.
      // Explicit cancellation wakes the pump and waits for observer cleanup.
      cancelled = true;
      wake();
      return pumping;
    },
  );
  return controller.stream;
}
