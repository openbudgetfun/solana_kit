// ignore_for_file: cancel_subscriptions

import 'dart:async';

/// A function that transforms a source message into a destination channel name
/// and message pair, or returns `null` to drop the message.
typedef MessageTransformer<TSourceData> =
    (String channelName, Object? message)? Function(TSourceData message);

/// Splits a stream into per-channel broadcast streams.
///
/// The source stream is listened to lazily when the first destination listener
/// subscribes and cancelled when the last destination listener cancels.
Stream<TDestination> demultiplexStream<TSourceData, TDestination>({
  required Stream<TSourceData> source,
  required String channelName,
  required MessageTransformer<TSourceData> messageTransformer,
}) {
  StreamSubscription<TSourceData>? sourceSubscription;

  late final StreamController<TDestination> controller;
  controller = StreamController<TDestination>.broadcast(
    sync: true,
    onListen: () {
      sourceSubscription ??= source.listen((sourceMessage) {
        final transformResult = messageTransformer(sourceMessage);
        if (transformResult == null) return;

        final (destinationChannelName, message) = transformResult;
        if (destinationChannelName == channelName && !controller.isClosed) {
          controller.add(message as TDestination);
        }
      }, onError: controller.addError);
    },
    onCancel: () {
      final subscription = sourceSubscription;
      sourceSubscription = null;
      if (subscription != null) unawaited(subscription.cancel());
    },
  );

  return controller.stream;
}
