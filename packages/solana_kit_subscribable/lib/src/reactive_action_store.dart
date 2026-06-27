// ignore_for_file: public_member_api_docs
import 'dart:async';

/// A callback that can be invoked to unsubscribe from a store.
typedef UnsubscribeCallback = void Function();

/// The lifecycle state of a [ReactiveActionStore].
enum ReactiveActionState {
  /// No action has been dispatched yet.
  idle,

  /// An action is currently being dispatched.
  running,

  /// The last dispatch completed successfully.
  success,

  /// The last dispatch failed with an error.
  error,
}

/// A unified snapshot of a [ReactiveActionStore]'s current state.
class ReactiveActionStateSnapshot<T> {
  const ReactiveActionStateSnapshot({
    required this.status,
    this.result,
    this.error,
  });

  /// The current lifecycle state.
  final ReactiveActionState status;

  /// The result of the last successful dispatch, or `null`.
  final T? result;

  /// The error from the last failed dispatch, or `null`.
  final Object? error;

  /// Returns `true` when [status] is [ReactiveActionState.idle].
  bool get isIdle => status == ReactiveActionState.idle;

  /// Returns `true` when [status] is [ReactiveActionState.running].
  bool get isRunning => status == ReactiveActionState.running;

  /// Returns `true` when [status] is [ReactiveActionState.success].
  bool get isSuccess => status == ReactiveActionState.success;

  /// Returns `true` when [status] is [ReactiveActionState.error].
  bool get isError => status == ReactiveActionState.error;
}

/// A callback invoked when a [ReactiveActionStore] changes.
typedef ReactiveActionSubscriber = void Function();

/// A reactive store that wraps a dispatchable action (e.g. an RPC request).
///
/// Mirrors the upstream `ReactiveActionStore<TArgs, TResult>` from
/// `@solana/subscribable` v6.10. The store transitions through
/// [ReactiveActionState] values as [dispatch] / [dispatchAsync] are called.
class ReactiveActionStore<TArgs extends List<Object?>, TResult> {
  ReactiveActionStore._(this._action) {
    _snapshot = ReactiveActionStateSnapshot<TResult>(
      status: ReactiveActionState.idle,
    );
  }

  final Future<TResult> Function(TArgs args) _action;

  final Set<ReactiveActionSubscriber> _subscribers = {};
  late ReactiveActionStateSnapshot<TResult> _snapshot;
  bool _isDisposed = false;

  /// Returns the current state snapshot.
  ReactiveActionStateSnapshot<TResult> getState() => _snapshot;

  /// Registers [callback] for state updates.
  ///
  /// Returns an idempotent unsubscribe callback.
  UnsubscribeCallback subscribe(ReactiveActionSubscriber callback) {
    if (_isDisposed) return () {};
    _subscribers.add(callback);

    var isSubscribed = true;
    return () {
      if (!isSubscribed) return;
      isSubscribed = false;
      _subscribers.remove(callback);
    };
  }

  /// Asynchronously dispatches the action with [args].
  ///
  /// While the action is running the state transitions to
  /// [ReactiveActionState.running]. On completion it transitions to either
  /// [ReactiveActionState.success] or [ReactiveActionState.error].
  Future<TResult> dispatchAsync(TArgs args) async {
    if (_isDisposed) {
      throw StateError('ReactiveActionStore has been disposed');
    }
    _snapshot = ReactiveActionStateSnapshot<TResult>(
      status: ReactiveActionState.running,
      result: _snapshot.result,
    );
    _notifySubscribers();
    try {
      final result = await _action(args);
      _snapshot = ReactiveActionStateSnapshot<TResult>(
        status: ReactiveActionState.success,
        result: result,
      );
      _notifySubscribers();
      return result;
    } catch (e) {
      _snapshot = ReactiveActionStateSnapshot<TResult>(
        status: ReactiveActionState.error,
        error: e,
        result: _snapshot.result,
      );
      _notifySubscribers();
      rethrow;
    }
  }

  /// Synchronously triggers [dispatchAsync] without awaiting the result.
  void dispatch(TArgs args) {
    // ignore: discarded_futures
    dispatchAsync(args);
  }

  /// Resets the store to the [ReactiveActionState.idle] state.
  void reset() {
    _snapshot = ReactiveActionStateSnapshot<TResult>(
      status: ReactiveActionState.idle,
    );
    _notifySubscribers();
  }

  /// Disposes the store and clears all subscribers.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _subscribers.clear();
  }

  void _notifySubscribers() {
    for (final subscriber in List<ReactiveActionSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

/// Creates a [ReactiveActionStore] backed by [action].
ReactiveActionStore<TArgs, TResult>
createReactiveActionStore<TArgs extends List<Object?>, TResult>(
  Future<TResult> Function(TArgs args) action,
) {
  return ReactiveActionStore<TArgs, TResult>._(action);
}
