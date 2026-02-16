import 'package:solana_kit_subscribable/src/data_publisher.dart';

/// A function that transforms a source message into a destination channel name
/// and message pair, or returns `null` to drop the message.
typedef MessageTransformer<TSourceData> =
    (String channelName, Object? message)? Function(TSourceData message);

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
/// ```dart
/// final demuxed = demultiplexDataPublisher(
///   sourcePublisher: publisher,
///   sourceChannelName: 'message',
///   messageTransformer: (message) {
///     final id = (message as Map)['subscriberId'];
///     return ('notification-for:$id', message);
///   },
/// );
///
/// final unsubscribe = demuxed.on('notification-for:123', (message) {
///   print('Got a message for subscriber 123: $message');
/// });
/// ```
DataPublisher demultiplexDataPublisher<TSourceData>({
  required DataPublisher sourcePublisher,
  required String sourceChannelName,
  required MessageTransformer<TSourceData> messageTransformer,
}) {
  _InnerPublisherState? innerPublisherState;
  final innerPublisher = createDataPublisher();

  return _DemultiplexedDataPublisher(
    onSubscribe: (channelName, subscriber) {
      if (innerPublisherState == null) {
        final sourceUnsubscribe = sourcePublisher.on(sourceChannelName, (
          sourceMessage,
        ) {
          final transformResult = messageTransformer(
            sourceMessage as TSourceData,
          );
          if (transformResult == null) return;
          final (destinationChannelName, message) = transformResult;
          innerPublisher.publish(destinationChannelName, message);
        });
        innerPublisherState = _InnerPublisherState(dispose: sourceUnsubscribe);
      }

      innerPublisherState!.numSubscribers++;
      final innerUnsubscribe = innerPublisher.on(channelName, subscriber);

      var isActive = true;
      void handleUnsubscribe() {
        if (!isActive) return;
        isActive = false;
        innerPublisherState!.numSubscribers--;
        if (innerPublisherState!.numSubscribers == 0) {
          innerPublisherState!.dispose();
          innerPublisherState = null;
        }
        innerUnsubscribe();
      }

      return handleUnsubscribe;
    },
  );
}

class _InnerPublisherState {
  _InnerPublisherState({required this.dispose});

  final UnsubscribeFn dispose;
  int numSubscribers = 0;
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
