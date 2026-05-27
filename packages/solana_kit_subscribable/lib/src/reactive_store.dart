import 'package:solana_kit_subscribable/src/data_publisher.dart';

/// A callback invoked when a [ReactiveStore] changes.
typedef ReactiveStoreSubscriber = void Function();

/// A small external-store facade over a [DataPublisher].
///
/// The store keeps the latest value published to `dataChannelName`, preserves the
/// first error published to `errorChannelName`, and notifies subscribers for both
/// data and error events. Call [dispose] to disconnect the store from the
/// underlying publisher.
class ReactiveStore<T> {
  ReactiveStore._({
    required DataPublisher dataPublisher,
    required String dataChannelName,
    required String errorChannelName,
  }) {
    _unsubscribeData = dataPublisher.on(dataChannelName, (data) {
      _state = data as T;
      _notifySubscribers();
    });
    _unsubscribeError = dataPublisher.on(errorChannelName, (error) {
      if (_error != null) return;
      _error = error;
      _notifySubscribers();
    });
  }

  final Set<ReactiveStoreSubscriber> _subscribers = {};
  T? _state;
  Object? _error;
  UnsubscribeFn? _unsubscribeData;
  UnsubscribeFn? _unsubscribeError;
  bool _isDisposed = false;

  /// The first error received from the error channel, or `null`.
  Object? getError() => _error;

  /// The most recent value received from the data channel, or `null`.
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

  /// Disconnects the store from its data publisher and clears subscribers.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _unsubscribeData?.call();
    _unsubscribeError?.call();
    _subscribers.clear();
  }

  void _notifySubscribers() {
    for (final subscriber in List<ReactiveStoreSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

/// Creates a [ReactiveStore] backed by a [DataPublisher].
ReactiveStore<T> createReactiveStoreFromDataPublisher<T>({
  required DataPublisher dataPublisher,
  required String dataChannelName,
  required String errorChannelName,
}) {
  return ReactiveStore<T>._(
    dataPublisher: dataPublisher,
    dataChannelName: dataChannelName,
    errorChannelName: errorChannelName,
  );
}
