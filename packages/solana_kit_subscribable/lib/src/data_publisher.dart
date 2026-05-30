import 'dart:async';

/// A function that unsubscribes a listener from a channel.
typedef UnsubscribeFn = void Function();

/// A function that receives published data of type [T].
typedef Subscriber<T> = void Function(T data);

/// A typed, stream-native publisher for string-keyed compatibility channels.
///
/// Prefer passing [Stream]s directly when designing new APIs. This utility is
/// intended for adapters that still need to bridge older named-channel APIs to
/// Dart streams.
class ChannelStreamController {
  /// Creates a controller whose per-channel streams are broadcast streams.
  ChannelStreamController({this.sync = true});

  /// Whether per-channel controllers dispatch synchronously.
  final bool sync;

  final Map<String, StreamController<Object?>> _controllers = {};

  /// Returns a broadcast stream for [channelName].
  Stream<T> stream<T>(String channelName) {
    return _controllerFor(channelName).stream.cast<T>();
  }

  /// Adds [data] to [channelName] if the controller is still open.
  void add(String channelName, Object? data) {
    final controller = _controllerFor(channelName);
    if (!controller.isClosed) controller.add(data);
  }

  /// Adds [error] to [channelName] if the controller is still open.
  void addError(String channelName, Object error, [StackTrace? stackTrace]) {
    final controller = _controllerFor(channelName);
    if (!controller.isClosed) controller.addError(error, stackTrace);
  }

  /// Closes all open channel streams.
  Future<void> close() async {
    final controllers = List<StreamController<Object?>>.of(_controllers.values);
    _controllers.clear();
    await Future.wait(controllers.map((controller) => controller.close()));
  }

  StreamController<Object?> _controllerFor(String channelName) {
    return _controllers.putIfAbsent(
      channelName,
      () => StreamController<Object?>.broadcast(sync: sync),
    );
  }
}

/// An object that publishes data to named channels.
///
/// This is a compatibility abstraction carried over from the upstream
/// TypeScript implementation. Prefer exposing Dart `Stream`s at public API
/// boundaries when designing new Dart-first APIs.
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
@Deprecated(
  'Use Stream<T>, StreamController<T>, or ChannelStreamController instead. '
  'This compatibility API will be removed in the next major version.',
)
// ignore: one_member_abstracts
abstract interface class DataPublisher {
  /// Subscribe to data on the given [channelName].
  ///
  /// Returns an [UnsubscribeFn] that can be called to unsubscribe. The
  /// unsubscribe function is idempotent and safe to call multiple times.
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber);
}

/// A [DataPublisher] that also supports publishing data to channels.
///
/// Prefer converting instances to `Stream`s before crossing higher-level API
/// boundaries.
@Deprecated(
  'Use StreamController<T> or ChannelStreamController instead. '
  'This compatibility API will be removed in the next major version.',
)
abstract interface class WritableDataPublisher implements DataPublisher {
  /// Publish [data] to all subscribers listening on [channelName].
  void publish(String channelName, Object? data);
}

/// Stream utilities for compatibility [DataPublisher] instances.
extension DataPublisherStreams on DataPublisher {
  /// Returns a broadcast stream of values published to [channelName].
  ///
  /// Listening to the returned stream registers one compatibility subscription
  /// against [channelName]. Cancelling the final stream subscription calls the
  /// underlying [UnsubscribeFn].
  Stream<T> stream<T>(String channelName) {
    UnsubscribeFn? unsubscribe;

    late final StreamController<T> controller;
    controller = StreamController<T>.broadcast(
      sync: true,
      onListen: () {
        unsubscribe ??= on(channelName, (data) {
          if (!controller.isClosed) controller.add(data as T);
        });
      },
      onCancel: () {
        unsubscribe?.call();
        unsubscribe = null;
      },
    );

    return controller.stream;
  }
}

/// Creates a new [WritableDataPublisher].
///
/// The returned publisher supports both subscribing to and publishing data on
/// named channels. Prefer `Stream`-based APIs for new Dart-facing surfaces;
/// this factory is primarily useful for compatibility layers and low-level
/// adapters.
@Deprecated(
  'Use StreamController<T> or ChannelStreamController instead. '
  'This compatibility API will be removed in the next major version.',
)
WritableDataPublisher createDataPublisher() => _DataPublisherImpl();

class _DataPublisherImpl implements WritableDataPublisher {
  final ChannelStreamController _channels = ChannelStreamController();

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    final subscription = _channels
        .stream<Object?>(channelName)
        .listen(subscriber);
    var isActive = true;

    return () {
      if (!isActive) return;
      isActive = false;
      unawaited(subscription.cancel());
    };
  }

  @override
  void publish(String channelName, Object? data) {
    _channels.add(channelName, data);
  }
}
