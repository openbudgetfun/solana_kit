import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_subscribable/src/cancellation_token.dart';
import 'package:solana_kit_subscribable/src/reactive_stream_store.dart';

/// Adapts a [ReactiveStreamStore] into a [Stream], so a push-based reactive
/// store can be driven by pull-based code that consumes a stream by
/// `await for`-ing it.
///
/// The bridge only *observes* the store; it does not open or tear down the
/// connection. Just like every other consumer in this ecosystem — a store does
/// nothing until you `connect()` it — the caller owns the store's lifecycle:
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
/// - `error` → throws, so the consuming `await for` rejects. Substitutes a
///   [SolanaErrorCode.subscribableStreamClosedWithoutError] sentinel when the
///   store reports an error with a nullish payload. An error takes precedence
///   over a buffered value: if a `loaded` value is still pending when an
///   `error` arrives, that value is dropped and the error propagates.
/// - [cancellationToken] fires → ends the stream cleanly (no error). A
///   subscription never completes on its own, so cancellation is how the
///   stream terminates: cancelling it unblocks a parked `await for` and ends
///   the loop. Bind the same token to the store's connection
///   (`store.withSignal(token).connect()`) so the cancellation tears the
///   underlying stream down too.
///
/// However iteration ends — value exhaustion, error, or cancellation — the
/// bridge unsubscribes from the store. It does not `reset()` the store; that
/// is the caller's decision.
Stream<T> bridgeStoreToAsyncIterable<T>(
  ReactiveStreamStore<T> store, {
  CancellationToken? cancellationToken,
  bool Function(T value)? shouldYield,
}) async* {
  // Latest-wins single-slot buffer plus a one-shot "something changed"
  // completer the loop parks on. `wake()` completes the current completer and
  // arms a fresh one for the next park.
  ({T value})? latest;
  Object? failure;
  var deferred = Completer<void>();
  void wake() {
    final completer = deferred;
    deferred = Completer<void>();
    completer.complete();
  }

  void onChange() {
    final state = store.getState();
    if (state.status == ReactiveStreamState.loaded) {
      // Drop a value the gate rejects. The stream parks again rather than
      // yielding it.
      if (shouldYield != null && !shouldYield(state.data as T)) return;
      latest = (value: state.data as T);
      wake();
    } else if (state.status == ReactiveStreamState.error) {
      // A nullish error would otherwise surface as a value-less success;
      // substitute a sentinel so the failure propagates.
      failure =
          state.error ??
          SolanaError(
            SolanaErrorCode.subscribableStreamClosedWithoutError,
          );
      wake();
    }
    // `idle` / `loading` carry no value and no error — nothing to yield.
  }

  void onCancel() => wake();
  unawaited(cancellationToken?.future.then((_) => onCancel()));
  final unsubscribe = store.subscribe(onChange);
  // Seed from the store's current snapshot: the caller may already have
  // connected (and a value or error may already be present) before iteration
  // began. The bridge never connects the store itself.
  onChange();
  try {
    while (true) {
      // Cancellation wins over everything: it is teardown, so end cleanly
      // without surfacing the store's incidental cancellation-driven error
      // state.
      if (cancellationToken?.isCancelled ?? false) return;
      if (failure != null) {
        final error = failure!;
        if (error is Error) throw error;
        if (error is Exception) throw error;
        throw StateError('$error');
      }
      if (latest != null) {
        final value = latest!.value;
        latest = null;
        yield value;
        continue;
      }
      await deferred.future;
    }
  } finally {
    unsubscribe();
  }
}
