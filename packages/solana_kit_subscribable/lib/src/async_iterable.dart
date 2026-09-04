import 'dart:async';

import 'package:solana_kit_subscribable/src/cancellation_token.dart';

/// Creates a broadcast stream from data and error streams.
///
/// When [cancellationToken] fires, the returned stream closes after cancelling
/// both source subscriptions. Events emitted after cancellation are ignored.
/// Native error events from either source are forwarded to the returned stream,
/// including type errors from transformed notification streams.
Stream<TData> createStreamFromDataAndErrorStreams<TData>({
  required Stream<TData> dataStream,
  required Stream<Object?> errorStream,
  CancellationToken? cancellationToken,
}) {
  Object? firstError;
  var hasError = false;
  var isStopped = cancellationToken?.isCancelled ?? false;
  // The source subscriptions are tracked in a list so they can be cancelled
  // together when the merged stream stops.
  final sourceSubscriptions = <StreamSubscription<Object?>>[];
  late final StreamController<TData> controller;

  Future<void> cancelSourceSubscriptions() async {
    final subscriptions = List<StreamSubscription<Object?>>.of(
      sourceSubscriptions,
    );
    sourceSubscriptions.clear();
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
  }

  Future<void> stop() async {
    if (isStopped && controller.isClosed) return;

    isStopped = true;
    try {
      await cancelSourceSubscriptions();
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  }

  bool shouldIgnoreEvents() =>
      isStopped ||
      controller.isClosed ||
      (cancellationToken?.isCancelled ?? false);

  void handleError(Object? error, [StackTrace? stackTrace]) {
    if (hasError || shouldIgnoreEvents()) return;

    final effectiveError = error ?? StateError('Unknown error');
    hasError = true;
    firstError = effectiveError;
    controller.addError(effectiveError, stackTrace);
    unawaited(cancelSourceSubscriptions());
  }

  controller = StreamController<TData>.broadcast(
    sync: true,
    onListen: () {
      if (hasError) {
        // A broadcast controller only re-runs `onListen` after the last
        // listener cancels, at which point `stop()` has already closed the
        // controller, so this replay branch is defensive dead code.
        controller.addError(firstError!);
        return;
      }

      if (shouldIgnoreEvents()) {
        unawaited(stop());
        return;
      }

      sourceSubscriptions
        ..add(
          errorStream.listen(handleError, onError: handleError),
        )
        ..add(
          dataStream.listen((data) {
            if (!shouldIgnoreEvents()) controller.add(data);
          }, onError: handleError),
        );
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
