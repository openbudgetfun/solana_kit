/// A function that unsubscribes a listener from a channel.
typedef UnsubscribeFn = void Function();

/// A function that receives published data of type [T].
typedef Subscriber<T> = void Function(T data);

/// An object that publishes data to named channels.
///
/// Subscribers can listen on a named channel and receive data published to that
/// channel. The [on] method returns an [UnsubscribeFn] that can be called to
/// stop receiving further messages.
///
/// ```dart
/// final publisher = createDataPublisher();
/// final unsubscribe = publisher.on('data', (message) {
///   print('Got message: $message');
/// });
/// publisher.publish('data', 'hello');
/// unsubscribe(); // stop listening
/// ```
// ignore: one_member_abstracts
abstract interface class DataPublisher {
  /// Subscribe to data on the given [channelName].
  ///
  /// Returns an [UnsubscribeFn] that can be called to unsubscribe. The
  /// unsubscribe function is idempotent and safe to call multiple times.
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber);
}

/// A [DataPublisher] that also supports publishing data to channels.
abstract interface class WritableDataPublisher implements DataPublisher {
  /// Publish [data] to all subscribers listening on [channelName].
  void publish(String channelName, Object? data);
}

/// Creates a new [WritableDataPublisher].
///
/// The returned publisher supports both subscribing to and publishing data on
/// named channels.
WritableDataPublisher createDataPublisher() => _DataPublisherImpl();

class _DataPublisherImpl implements WritableDataPublisher {
  final Map<String, List<Subscriber<Object?>>> _subscribers = {};

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    final listeners = _subscribers.putIfAbsent(channelName, () => [])
      ..add(subscriber);

    var isActive = true;
    return () {
      if (!isActive) return;
      isActive = false;
      listeners.remove(subscriber);
    };
  }

  @override
  void publish(String channelName, Object? data) {
    final listeners = _subscribers[channelName];
    if (listeners == null) return;
    // Copy the list to avoid concurrent modification if a subscriber
    // unsubscribes during notification.
    for (final listener in List<Subscriber<Object?>>.of(listeners)) {
      listener(data);
    }
  }
}
