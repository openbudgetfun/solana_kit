import 'dart:async';

/// Creates a broadcast stream from data and error streams.
Stream<TData> createStreamFromDataAndErrorStreams<TData>({
  required Stream<TData> dataStream,
  required Stream<Object?> errorStream,
}) {
  Object? firstError;
  var hasError = false;
  StreamSubscription<TData>? dataSubscription;
  StreamSubscription<Object?>? errorSubscription;

  late final StreamController<TData> controller;
  controller = StreamController<TData>.broadcast(
    sync: true,
    onListen: () {
      if (hasError) {
        controller.addError(firstError!); // coverage:ignore-line
        return;
      }

      errorSubscription ??= errorStream.listen((err) {
        if (!hasError) {
          hasError = true;
          firstError = err;
          controller.addError(err ?? StateError('Unknown error'));
          unawaited(dataSubscription?.cancel());
          dataSubscription = null;
          unawaited(errorSubscription?.cancel());
          errorSubscription = null;
        }
      });

      dataSubscription ??= dataStream.listen((data) {
        if (!controller.isClosed) controller.add(data);
      });
    },
    onCancel: () {
      unawaited(dataSubscription?.cancel());
      dataSubscription = null;
      unawaited(errorSubscription?.cancel());
      errorSubscription = null;
      unawaited(controller.close());
    },
  );

  return controller.stream;
}
