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
