import 'dart:async';

import 'package:solana_kit_subscribable/src/data_publisher.dart';

/// A callback invoked when a [ReactiveStore] changes.
typedef ReactiveStoreSubscriber = void Function();

/// A small external-store facade over data and error streams.
///
/// The store keeps the latest data value, preserves the first error, and
/// notifies subscribers for both data and error events. Call [dispose] to cancel
/// the underlying stream subscriptions.
class ReactiveStore<T> {
  ReactiveStore._({
    required Stream<T> dataStream,
    required Stream<Object?> errorStream,
  }) {
    _dataSubscription = dataStream.listen((data) {
      _state = data;
      _notifySubscribers();
    });
    _errorSubscription = errorStream.listen((error) {
      if (_error != null) return;
      _error = error;
      _notifySubscribers();
    });
  }

  final Set<ReactiveStoreSubscriber> _subscribers = {};
  T? _state;
  Object? _error;
  StreamSubscription<T>? _dataSubscription;
  StreamSubscription<Object?>? _errorSubscription;
  bool _isDisposed = false;

  /// The first error received from the error stream, or `null`.
  Object? getError() => _error;

  /// The most recent value received from the data stream, or `null`.
  T? getState() => _state;

  /// Registers [callback] for state and error updates.
  ///
  /// Returns an idempotent unsubscribe callback.
  UnsubscribeFn subscribe(ReactiveStoreSubscriber callback) {
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
    for (final subscriber in List<ReactiveStoreSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

/// Creates a [ReactiveStore] backed by streams.
ReactiveStore<T> createReactiveStoreFromStreams<T>({
  required Stream<T> dataStream,
  required Stream<Object?> errorStream,
}) {
  return ReactiveStore<T>._(dataStream: dataStream, errorStream: errorStream);
}
