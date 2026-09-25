import 'dart:async';

import 'package:solana_kit_subscribable/src/cancellation_token.dart';
import 'package:solana_kit_subscribable/src/data_publisher.dart';

/// The data/error streams produced by a [ReactiveStreamStore] factory for a
/// single connection window.
///
/// Added in @solana/kit v7.0.0 alongside the caller-driven `connect()` model.
class ReactiveStreamConnection<T> {
  /// Creates a connection bundling a [dataStream] and an [errorStream].
  const ReactiveStreamConnection({
    required this.dataStream,
    required this.errorStream,
  });

  /// Emits data values for this connection.
  final Stream<T> dataStream;

  /// Emits non-null error values for this connection. `null` emissions are
  /// ignored.
  final Stream<Object?> errorStream;
}

/// A factory that opens a fresh [ReactiveStreamConnection] each time a
/// [ReactiveStreamStore] is (re)connected.
///
/// Receives a [CancellationToken] that fires when this specific connection
/// window should tear down, composed from the per-connection inner
/// controller and (if attached via [ReactiveStreamStore.withSignal]) the
/// caller-provided token. Thread it into the underlying transport's own
/// cancellation so the connection itself stops on per-connection abort, not
/// just the store's listeners. Rejections surface as a store error.
///
/// Added in @solana/kit v7.0.0.
typedef ReactiveStreamDataPublisherFactory<T> =
    Future<ReactiveStreamConnection<T>> Function(CancellationToken signal);

/// A source that creates a fresh reactive stream store on demand.
///
/// Implemented by lazy streaming operations such as pending RPC subscriptions.
typedef ReactiveStreamSource<T> = ReactiveStreamStore<T> Function();

/// The lifecycle state of a [ReactiveStreamStore].
///
/// Added the `idle` status in @solana/kit v7.0.0 and removed the former
/// `retrying` status. A subsequent `connect()` from any non-idle status now
/// transitions through `loading` while preserving the last known `data` and
/// `error` (stale-while-revalidate).
enum ReactiveStreamState {
  /// The store has not yet been connected, or has been reset via
  /// `ReactiveStreamStore.reset()`. Call `ReactiveStreamStore.connect()` to
  /// open the underlying stream.
  idle,

  /// A connection is in progress. `data` and `error` are preserved from the
  /// previous connection (if any), giving stale-while-revalidate UX. A subsequent
  /// `loaded` clears `error`; a subsequent `error` replaces it.
  loading,

  /// A value has been received and no error is active.
  loaded,

  /// The stream failed. `data` holds the last known value (or `null` if none
  /// ever arrived) and `error` holds the failure.
  error,
}

/// A unified snapshot of a [ReactiveStreamStore]'s current state.
class ReactiveStreamStateSnapshot<T> {
  /// Creates a snapshot of [status] with optional [data] and [error].
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

  /// Returns `true` when [status] is [ReactiveStreamState.idle].
  bool get isIdle => status == ReactiveStreamState.idle;

  /// Returns `true` when [status] is [ReactiveStreamState.loading].
  bool get isLoading => status == ReactiveStreamState.loading;

  /// Returns `true` when [status] is [ReactiveStreamState.loaded].
  bool get isLoaded => status == ReactiveStreamState.loaded;

  /// Returns `true` when [status] is [ReactiveStreamState.error].
  bool get isError => status == ReactiveStreamState.error;
}

/// A callback invoked when a [ReactiveStreamStore] changes.
typedef ReactiveStreamSubscriber = void Function();

/// A reactive store backed by a data stream.
///
/// Mirrors the upstream `ReactiveStreamStore<T>` from `@solana/subscribable`
/// v7.0. The store starts in `status: 'idle'`. Call `connect` to open the
/// underlying stream; the store transitions through `loading` → `loaded`
/// (or `error`). Subsequent `connect` calls also pass through `loading` while
/// preserving the last known `data` and `error` (stale-while-revalidate).
///
/// Added the caller-driven `connect()`/`reset()`/`withSignal()` model and
/// removed the former `retry()`, value-only `getState()`, `getError()`, and
/// `getUnifiedState()` members in @solana/kit v7.0.0.
class ReactiveStreamStore<T> {
  ReactiveStreamStore._(this._createDataPublisher) {
    _state = ReactiveStreamStateSnapshot<T>(status: ReactiveStreamState.idle);
  }

  final ReactiveStreamDataPublisherFactory<T> _createDataPublisher;

  final Set<ReactiveStreamSubscriber> _subscribers = {};
  late ReactiveStreamStateSnapshot<T> _state;

  // The per-connection cancellation source. A new `connect()`/`reset()`
  // cancels the previous source so its in-flight factory and subscriptions
  // stop touching the store.
  CancellationTokenSource? _activeSource;
  StreamSubscription<T>? _dataSubscription;
  StreamSubscription<Object?>? _errorSubscription;
  bool _isDisposed = false;

  /// Returns the current unified state snapshot.
  ///
  /// Renamed from `getUnifiedState()` in @solana/kit v7.0.0.
  ReactiveStreamStateSnapshot<T> getState() => _state;

  /// Opens the underlying stream.
  ///
  /// Aborts any currently active connection, invokes the configured factory,
  /// and transitions the store to `loading` (preserving the last known `data`
  /// and `error` for stale-while-revalidate) before settling into `loaded`
  /// (on data) or `error` (on failure).
  void connect() => _connectWithSignal(null);

  void _connectWithSignal(CancellationToken? callerSignal) {
    if (_isDisposed) {
      throw StateError('ReactiveStreamStore has been disposed');
    }
    // Abort any currently active connection without resetting to idle.
    _abortActiveConnection();

    if (callerSignal?.isCancelled ?? false) {
      _state = ReactiveStreamStateSnapshot<T>(
        status: ReactiveStreamState.error,
        data: _state.data,
        error:
            callerSignal!.reason ?? StateError('ReactiveStreamStore aborted'),
      );
      _notifySubscribers();
      return;
    }

    final source = CancellationTokenSource();
    _activeSource = source;

    // Transition to loading, preserving the last known data and error for
    // stale-while-revalidate. (v7.0.0 collapsed the former `retrying` status
    // into `loading`.)
    _state = ReactiveStreamStateSnapshot<T>(
      status: ReactiveStreamState.loading,
      data: _state.data,
      error: _state.error,
    );
    _notifySubscribers();
    // A subscriber can synchronously reset, dispose, or reconnect the store.
    if (_activeSource?.token != source.token) return;

    // If the caller attached a per-connection signal, propagate its abort to
    // the inner per-connection controller and surface the abort reason on
    // state as an error (when this connection is still the active one).
    if (callerSignal != null) {
      // ignore: discarded_futures
      callerSignal.future.then((_) {
        if (_activeSource?.token == source.token) {
          _handleError(
            callerSignal.reason ?? StateError('ReactiveStreamStore aborted'),
            source.token,
          );
        }
        source.cancel(callerSignal.reason);
        if (_activeSource?.token == source.token) {
          _abortActiveConnection();
        }
      });
    }
    _openConnection(source.token);
  }

  Future<void> _openConnection(CancellationToken signal) async {
    try {
      final connection = await _createDataPublisher(signal);
      // Supersession: a newer connect()/reset()/dispose() replaced the active
      // source. Drop this connection silently.
      if (_isDisposed || signal.isCancelled || _activeSource?.token != signal) {
        return;
      }
      _dataSubscription = connection.dataStream.listen(
        (data) {
          if (_isDisposed ||
              signal.isCancelled ||
              _activeSource?.token != signal) {
            return;
          }
          _state = ReactiveStreamStateSnapshot<T>(
            status: ReactiveStreamState.loaded,
            data: data,
          );
          _notifySubscribers();
        },
        onError: (Object error, StackTrace _) {
          _handleError(error, signal);
        },
        cancelOnError: false,
      );
      _errorSubscription = connection.errorStream.listen(
        (error) {
          if (error == null) {
            return;
          }
          _handleError(error, signal);
        },
        onError: (Object error, StackTrace _) {
          _handleError(error, signal);
        },
      );
    } on Object catch (error) {
      if (_isDisposed || signal.isCancelled || _activeSource?.token != signal) {
        return;
      }
      _handleError(error, signal);
    }
  }

  void _handleError(Object error, CancellationToken signal) {
    if (_isDisposed ||
        signal.isCancelled ||
        _activeSource?.token != signal ||
        _state.status == ReactiveStreamState.error) {
      return;
    }
    _state = ReactiveStreamStateSnapshot<T>(
      status: ReactiveStreamState.error,
      data: _state.data,
      error: error,
    );
    _notifySubscribers();
  }

  /// Aborts the current connection and returns the store to `idle` without
  /// permanently killing it, which is natural for effect cleanup.
  ///
  /// Added in @solana/kit v7.0.0.
  void reset() {
    if (_isDisposed) {
      return;
    }
    _abortActiveConnection();
    _state = ReactiveStreamStateSnapshot<T>(status: ReactiveStreamState.idle);
    _notifySubscribers();
  }

  /// Attaches a caller-provided [CancellationToken] to subsequent connections.
  ///
  /// Returns a `connect` callback that composes [signal] with the store's
  /// internal per-connection controller: aborting [signal] surfaces the abort
  /// reason on state as `error`; supersession via the internal controller (a
  /// newer `connect()` or `reset()`) stays silent so the newer call owns
  /// state.
  ///
  /// The bind-once "kill switch" pattern is expressible by binding once:
  /// ```dart
  /// final killableConnect = store.withSignal(killSource.token);
  /// killableConnect(); // opens the stream with the composed signal
  /// ```
  /// After `killSource.cancel()`, every `killableConnect()` short-circuits to
  /// `error`.
  ///
  /// Added in @solana/kit v7.0.0.
  void Function() withSignal(CancellationToken signal) {
    return () => _connectWithSignal(signal);
  }

  /// Registers [callback] for state and error updates.
  ///
  /// Returns an idempotent unsubscribe callback.
  UnsubscribeFn subscribe(ReactiveStreamSubscriber callback) {
    if (_isDisposed) {
      return () {};
    }
    _subscribers.add(callback);

    var isSubscribed = true;
    return () {
      if (!isSubscribed) {
        return;
      }
      isSubscribed = false;
      _subscribers.remove(callback);
    };
  }

  /// Disconnects the store from its streams and clears subscribers.
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _abortActiveConnection();
    _subscribers.clear();
  }

  void _abortActiveConnection() {
    _activeSource?.cancel();
    _activeSource = null;
    unawaited(_dataSubscription?.cancel());
    _dataSubscription = null;
    unawaited(_errorSubscription?.cancel());
    _errorSubscription = null;
  }

  void _notifySubscribers() {
    for (final subscriber in List<ReactiveStreamSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

/// Creates a [ReactiveStreamStore] backed by the [createDataPublisher]
/// factory.
///
/// The store starts in `idle`. Call `ReactiveStreamStore.connect` to open the
/// underlying stream.
///
/// Added in @solana/kit v7.0.0 (replacing the former stream-pair constructor).
ReactiveStreamStore<T> createReactiveStreamStore<T>({
  required ReactiveStreamDataPublisherFactory<T> createDataPublisher,
}) {
  return ReactiveStreamStore<T>._(createDataPublisher);
}
