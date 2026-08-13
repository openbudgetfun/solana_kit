import 'dart:async';

import 'package:solana_kit_subscribable/src/cancellation_token.dart';

/// Creates a broadcast stream from data and error streams.
///
/// When [cancellationToken] fires, the returned stream closes after cancelling
/// both source subscriptions. Events emitted after cancellation are ignored.
Stream<TData> createStreamFromDataAndErrorStreams<TData>({
  required Stream<TData> dataStream,
  required Stream<Object?> errorStream,
  CancellationToken? cancellationToken,
}) {
  Object? firstError;
  var hasError = false;
  var isStopped = cancellationToken?.isCancelled ?? false;
  // Both subscriptions are cancelled in [cancelSourceSubscriptions] below.
  // ignore: cancel_subscriptions
  StreamSubscription<TData>? dataSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? errorSubscription;

  Future<void> cancelSourceSubscriptions() async {
    final data = dataSubscription;
    final error = errorSubscription;
    dataSubscription = null;
    errorSubscription = null;

    await Future.wait<void>([
      if (data != null) data.cancel(),
      if (error != null) error.cancel(),
    ]);
  }

  late final StreamController<TData> controller;

  Future<void> stop() async {
    if (isStopped && controller.isClosed) return;

    isStopped = true;
    try {
      await cancelSourceSubscriptions();
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  }

  bool shouldIgnoreEvents() {
    return isStopped ||
        controller.isClosed ||
        (cancellationToken?.isCancelled ?? false);
  }

  controller = StreamController<TData>.broadcast(
    sync: true,
    onListen: () {
      if (hasError) {
        controller.addError(firstError!);
        return;
      }

      if (shouldIgnoreEvents()) {
        unawaited(stop());
        return;
      }

      errorSubscription ??= errorStream.listen((error) {
        if (hasError || shouldIgnoreEvents()) return;

        final effectiveError = error ?? StateError('Unknown error');
        hasError = true;
        firstError = effectiveError;
        controller.addError(effectiveError);
        unawaited(cancelSourceSubscriptions());
      });

      dataSubscription ??= dataStream.listen((data) {
        if (!shouldIgnoreEvents()) controller.add(data);
      });
    },
    onCancel: stop,
  );

  if (isStopped) {
    unawaited(controller.close());
  } else if (cancellationToken != null) {
    unawaited(cancellationToken.future.then((_) => stop()));
  }

  return controller.stream;
}
