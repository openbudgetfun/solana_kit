// ignore_for_file: public_member_api_docs, prefer_initializing_formals
import 'dart:async';

import 'package:solana_kit_subscribable/src/data_publisher.dart';

/// The lifecycle state of a [ReactiveStreamStore].
enum ReactiveStreamState {
  /// The store is loading its initial value (or retrying after an error).
  loading,

  /// The store has loaded its value successfully.
  loaded,

  /// The store encountered an error.
  error,

  /// The store is retrying after an error.
  retrying,
}

/// A unified snapshot of a [ReactiveStreamStore]'s current state.
class ReactiveStreamStateSnapshot<T> {
  const ReactiveStreamStateSnapshot({
    required this.status,
    this.data,
    this.error,
  });

  /// The current lifecycle state.
  final ReactiveStreamState status;

  /// The most recent data value, or `null`.
  final T? data;

  /// The first error received, or `null`.
  final Object? error;

  /// Returns `true` when [status] is [ReactiveStreamState.loading].
  bool get isLoading => status == ReactiveStreamState.loading;

  /// Returns `true` when [status] is [ReactiveStreamState.loaded].
  bool get isLoaded => status == ReactiveStreamState.loaded;

  /// Returns `true` when [status] is [ReactiveStreamState.error].
  bool get isError => status == ReactiveStreamState.error;

  /// Returns `true` when [status] is [ReactiveStreamState.retrying].
  bool get isRetrying => status == ReactiveStreamState.retrying;
}

/// A callback invoked when a [ReactiveStreamStore] changes.
typedef ReactiveStreamSubscriber = void Function();

/// A reactive store backed by a data stream with retry support.
///
/// Mirrors the upstream `ReactiveStreamStore<T>` from `@solana/subscribable`
/// v6.10. The store transitions through [ReactiveStreamState] values as data
/// arrives, errors occur, and retries are requested.
class ReactiveStreamStore<T> {
  ReactiveStreamStore._({
    required Stream<T> dataStream,
    required Stream<Object?> errorStream,
    required Future<void> Function()? retryFn,
  }) : _retryFn = retryFn {
    _state = ReactiveStreamStateSnapshot<T>(
      status: ReactiveStreamState.loading,
    );
    _dataSubscription = dataStream.listen(
      (data) {
        _state = ReactiveStreamStateSnapshot<T>(
          status: ReactiveStreamState.loaded,
          data: data,
        );
        _notifySubscribers();
      },
      onError: (Object? error) {
        if (_state.status == ReactiveStreamState.retrying) return;
        _state = ReactiveStreamStateSnapshot<T>(
          status: ReactiveStreamState.error,
          error: error,
          data: _state.data,
        );
        _notifySubscribers();
      },
    );
    _errorSubscription = errorStream.listen((error) {
      if (error == null) return;
      _state = ReactiveStreamStateSnapshot<T>(
        status: ReactiveStreamState.error,
        error: error,
        data: _state.data,
      );
      _notifySubscribers();
    });
  }

  final Future<void> Function()? _retryFn;
  final Set<ReactiveStreamSubscriber> _subscribers = {};
  late ReactiveStreamStateSnapshot<T> _state;
  StreamSubscription<T>? _dataSubscription;
  StreamSubscription<Object?>? _errorSubscription;
  bool _isDisposed = false;

  /// Returns the most recent data value, or `null`.
  T? getState() => _state.data;

  /// Returns the current unified state snapshot.
  ReactiveStreamStateSnapshot<T> getUnifiedState() => _state;

  /// Returns the first error received, or `null`.
  Object? getError() => _state.error;

  /// Triggers a retry of the data publisher.
  ///
  /// If the store does not support retry, throws a [StateError].
  Future<void> retry() async {
    if (_isDisposed) {
      throw StateError('ReactiveStreamStore has been disposed');
    }
    if (_retryFn == null) {
      throw StateError('This ReactiveStreamStore does not support retry');
    }
    _state = ReactiveStreamStateSnapshot<T>(
      status: ReactiveStreamState.retrying,
      data: _state.data,
      error: _state.error,
    );
    _notifySubscribers();
    await _retryFn();
  }

  /// Registers [callback] for state and error updates.
  ///
  /// Returns an idempotent unsubscribe callback.
  UnsubscribeFn subscribe(ReactiveStreamSubscriber callback) {
    if (_isDisposed) return () {};
    _subscribers.add(callback);

    var isSubscribed = true;
    return () {
      if (!isSubscribed) return;
      isSubscribed = false;
      _subscribers.remove(callback);
    };
  }

  /// Disconnects the store from its streams and clears subscribers.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    unawaited(_dataSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    _subscribers.clear();
  }

  void _notifySubscribers() {
    for (final subscriber in List<ReactiveStreamSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

/// Creates a [ReactiveStreamStore] backed by streams.
ReactiveStreamStore<T> createReactiveStreamStore<T>({
  required Stream<T> dataStream,
  required Stream<Object?> errorStream,
  Future<void> Function()? retry,
}) {
  return ReactiveStreamStore<T>._(
    dataStream: dataStream,
    errorStream: errorStream,
    retryFn: retry,
  );
}
