// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:solana_kit_subscribable/src/data_publisher.dart';

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

/// Splits a single source channel of a [DataPublisher] into multiple derived
/// channels using a [messageTransformer].
///
/// The returned [DataPublisher] lazily subscribes to the source publisher:
/// - The source is only subscribed when the first subscriber appears on the
///   demultiplexed publisher.
/// - The source is unsubscribed when the last subscriber unsubscribes.
/// - Reference counting ensures multiple subscribers share a single source
///   subscription.
/// - Unsubscribe functions are idempotent.
///
/// Prefer [demultiplexStream] for stream-native code.
DataPublisher demultiplexDataPublisher<TSourceData>({
  required DataPublisher sourcePublisher,
  required String sourceChannelName,
  required MessageTransformer<TSourceData> messageTransformer,
}) {
  StreamSubscription<Object?>? sourceSubscription;
  final channels = ChannelStreamController();
  var numSubscribers = 0;

  void startSourceSubscription() {
    sourceSubscription ??= sourcePublisher
        .stream<Object?>(sourceChannelName)
        .listen((sourceMessage) {
          final transformResult = messageTransformer(
            sourceMessage as TSourceData,
          );
          if (transformResult == null) return;

          final (destinationChannelName, message) = transformResult;
          channels.add(destinationChannelName, message);
        });
  }

  void stopSourceSubscription() {
    final subscription = sourceSubscription;
    sourceSubscription = null;
    if (subscription != null) unawaited(subscription.cancel());
  }

  return _DemultiplexedDataPublisher(
    onSubscribe: (channelName, subscriber) {
      numSubscribers++;
      startSourceSubscription();

      final subscription = channels
          .stream<Object?>(channelName)
          .listen(subscriber);
      var isActive = true;

      return () {
        if (!isActive) return;
        isActive = false;
        numSubscribers--;
        unawaited(subscription.cancel());
        if (numSubscribers == 0) stopSourceSubscription();
      };
    },
  );
}

class _DemultiplexedDataPublisher implements DataPublisher {
  const _DemultiplexedDataPublisher({required this.onSubscribe});

  final UnsubscribeFn Function(
    String channelName,
    Subscriber<Object?> subscriber,
  )
  onSubscribe;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return onSubscribe(channelName, subscriber);
  }
}
