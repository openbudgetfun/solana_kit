// ignore_for_file: public_member_api_docs
import 'dart:async';

import 'package:solana_kit_subscribable/src/cancellation_token.dart';

/// A callback that can be invoked to unsubscribe from a store.
typedef UnsubscribeCallback = void Function();

/// An action wrapped by a [ReactiveActionStore].
///
/// The action receives the cancellation token for this dispatch followed by
/// the dispatch arguments.
typedef ReactiveAction<TArgs, TResult> =
    Future<TResult> Function(CancellationToken signal, TArgs args);

/// A source that creates a fresh reactive action store on demand.
///
/// Implemented by lazy one-shot operations such as pending RPC requests.
// ignore: one_member_abstracts
abstract interface class ReactiveActionSource<TResult> {
  /// Creates a reactive store for this source.
  ReactiveActionStore<List<Object?>, TResult> reactiveStore();
}

/// The lifecycle state of a [ReactiveActionStore].
enum ReactiveActionState { idle, running, success, error }

/// A unified snapshot of a [ReactiveActionStore]'s current state.
class ReactiveActionStateSnapshot<T> {
  const ReactiveActionStateSnapshot({
    required this.status,
    this.result,
    this.error,
  });

  final ReactiveActionState status;
  final T? result;
  final Object? error;

  bool get isIdle => status == ReactiveActionState.idle;
  bool get isRunning => status == ReactiveActionState.running;
  bool get isSuccess => status == ReactiveActionState.success;
  bool get isError => status == ReactiveActionState.error;
}

/// Thrown when an action dispatch is cancelled internally by its store.
class ReactiveActionCancellationException implements Exception {
  const ReactiveActionCancellationException(this.message);

  final String message;

  @override
  String toString() => 'ReactiveActionCancellationException: $message';
}

/// A callback invoked when a [ReactiveActionStore] changes.
typedef ReactiveActionSubscriber = void Function();

/// A dispatch-only view bound to a caller-provided cancellation token.
class ReactiveActionDispatchView<TArgs extends List<Object?>, TResult> {
  const ReactiveActionDispatchView._(this._store, this._signal);

  final ReactiveActionStore<TArgs, TResult> _store;
  final CancellationToken _signal;

  /// Fire-and-forget dispatch whose asynchronous errors are consumed.
  void dispatch(TArgs args) => _store._dispatch(args, _signal);

  /// Dispatches and returns the action result or propagated error.
  Future<TResult> dispatchAsync(TArgs args) =>
      _store._dispatchAsync(args, _signal);
}

/// A reactive store that wraps a cancellable asynchronous action.
///
/// Every dispatch cancels the previous dispatch. Superseded, reset, and
/// disposed dispatches cannot update state even if their action completes
/// later. Use [withSignal] to add caller-owned cancellation to one or more
/// dispatches.
class ReactiveActionStore<TArgs extends List<Object?>, TResult> {
  ReactiveActionStore._(this._action);

  static const _disposedMessage = 'ReactiveActionStore has been disposed';
  static const _idleSnapshot = ReactiveActionStateSnapshot<Never>(
    status: ReactiveActionState.idle,
  );

  final ReactiveAction<TArgs, TResult> _action;
  final Set<ReactiveActionSubscriber> _subscribers = {};

  ReactiveActionStateSnapshot<TResult> _snapshot =
      _idleSnapshot as ReactiveActionStateSnapshot<TResult>;
  _ReactiveActionDispatch? _activeDispatch;
  bool _isDisposed = false;

  /// Returns the current state snapshot.
  ReactiveActionStateSnapshot<TResult> getState() => _snapshot;

  /// Registers [callback] for state updates.
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
  Future<TResult> dispatchAsync(TArgs args) => _dispatchAsync(args, null);

  /// Fire-and-forget dispatch whose asynchronous errors are consumed.
  void dispatch(TArgs args) => _dispatch(args, null);

  void _dispatch(TArgs args, CancellationToken? callerSignal) {
    unawaited(
      _dispatchAsync(args, callerSignal).then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {},
      ),
    );
  }

  Future<TResult> _dispatchAsync(
    TArgs args,
    CancellationToken? callerSignal,
  ) async {
    if (_isDisposed) throw StateError(_disposedMessage);

    _cancelActive('superseded by a newer dispatch');

    if (callerSignal?.isCancelled ?? false) {
      final error = _cancellationReason(callerSignal!);
      _setState(
        ReactiveActionStateSnapshot<TResult>(
          status: ReactiveActionState.error,
          result: _snapshot.result,
          error: error,
        ),
      );
      Error.throwWithStackTrace(error, StackTrace.current);
    }

    final dispatch = _ReactiveActionDispatch(callerSignal);
    _activeDispatch = dispatch;
    final previousResult = _snapshot.result;
    final previousError = _snapshot.error;

    if (callerSignal != null) {
      unawaited(
        callerSignal.future.then((_) {
          dispatch.cancelFromCaller(_cancellationReason(callerSignal));
        }),
      );
    }

    _setState(
      ReactiveActionStateSnapshot<TResult>(
        status: ReactiveActionState.running,
        result: previousResult,
        error: previousError,
      ),
    );

    try {
      final actionFuture = Future<TResult>.sync(
        () => _action(dispatch.signal, args),
      );
      final result = await _raceWithCancellation(actionFuture, dispatch);

      if (dispatch.isInternallyCancelled) {
        Error.throwWithStackTrace(dispatch.internalReason!, StackTrace.current);
      }
      if (dispatch.signal.isCancelled) {
        final error =
            dispatch.signal.reason ??
            const ReactiveActionCancellationException(
              'cancelled by the caller',
            );
        Error.throwWithStackTrace(error, StackTrace.current);
      }
      if (!_isCurrent(dispatch)) {
        throw const ReactiveActionCancellationException(
          'superseded before completion',
        );
      }

      _setState(
        ReactiveActionStateSnapshot<TResult>(
          status: ReactiveActionState.success,
          result: result,
        ),
      );
      return result;
    } on Object catch (error, stackTrace) {
      if (dispatch.isInternallyCancelled || !_isCurrent(dispatch)) {
        final cancellation =
            dispatch.internalReason ??
            const ReactiveActionCancellationException(
              'superseded before completion',
            );
        Error.throwWithStackTrace(cancellation, stackTrace);
      }

      final surfacedError = dispatch.signal.isCancelled
          ? dispatch.signal.reason ?? error
          : error;
      _setState(
        ReactiveActionStateSnapshot<TResult>(
          status: ReactiveActionState.error,
          result: previousResult,
          error: surfacedError,
        ),
      );
      Error.throwWithStackTrace(surfacedError, stackTrace);
    }
  }

  Future<TResult> _raceWithCancellation(
    Future<TResult> action,
    _ReactiveActionDispatch dispatch,
  ) {
    final completer = Completer<TResult>();
    unawaited(
      action
          .then<void>(
            (result) {
              if (!completer.isCompleted) completer.complete(result);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!completer.isCompleted) {
                completer.completeError(error, stackTrace);
              }
            },
          )
          .then<void>(
            (_) {},
            onError: (Object _, StackTrace _) {},
          ),
    );
    dispatch.signal.future.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(
          dispatch.signal.reason ??
              const ReactiveActionCancellationException('dispatch cancelled'),
          StackTrace.current,
        );
      }
    });
    return completer.future;
  }

  /// Aborts any in-flight dispatch and resets the store to idle.
  void reset() {
    if (_isDisposed) return;
    _cancelActive('cancelled by reset');
    _activeDispatch = null;
    _setState(_idleSnapshot as ReactiveActionStateSnapshot<TResult>);
  }

  /// Returns a dispatch-only view bound to [signal].
  ReactiveActionDispatchView<TArgs, TResult> withSignal(
    CancellationToken signal,
  ) => ReactiveActionDispatchView<TArgs, TResult>._(this, signal);

  /// Cancels the active dispatch, clears subscribers, and disposes the store.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _cancelActive('cancelled by dispose');
    _activeDispatch = null;
    _subscribers.clear();
  }

  void _cancelActive(String message) {
    _activeDispatch?.cancelInternally(
      ReactiveActionCancellationException(message),
    );
  }

  bool _isCurrent(_ReactiveActionDispatch dispatch) =>
      !_isDisposed && identical(_activeDispatch, dispatch);

  Object _cancellationReason(CancellationToken signal) =>
      signal.reason ??
      const ReactiveActionCancellationException('cancelled by the caller');

  void _setState(ReactiveActionStateSnapshot<TResult> next) {
    final current = _snapshot;
    if (current.status == next.status &&
        identical(current.result, next.result) &&
        identical(current.error, next.error)) {
      return;
    }
    _snapshot = next;
    for (final subscriber in List<ReactiveActionSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

class _ReactiveActionDispatch {
  _ReactiveActionDispatch(this.callerSignal)
    : _combinedSource = CancellationTokenSource(),
      _internalSource = CancellationTokenSource();

  final CancellationToken? callerSignal;
  final CancellationTokenSource _combinedSource;
  final CancellationTokenSource _internalSource;

  CancellationToken get signal => _combinedSource.token;
  bool get isInternallyCancelled => _internalSource.token.isCancelled;
  Object? get internalReason => _internalSource.token.reason;

  void cancelInternally(Object reason) {
    _internalSource.cancel(reason);
    _combinedSource.cancel(reason);
  }

  void cancelFromCaller(Object reason) => _combinedSource.cancel(reason);
}

/// Creates a [ReactiveActionStore] backed by [action].
ReactiveActionStore<TArgs, TResult>
createReactiveActionStore<TArgs extends List<Object?>, TResult>(
  ReactiveAction<TArgs, TResult> action,
) => ReactiveActionStore<TArgs, TResult>._(action);
