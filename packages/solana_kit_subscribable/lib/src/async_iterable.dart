import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_subscribable/src/data_publisher.dart';

/// Configuration for [createStreamFromDataPublisher].
class StreamFromDataPublisherConfig {
  /// Creates configuration for [createStreamFromDataPublisher].
  const StreamFromDataPublisherConfig({
    required this.dataChannelName,
    required this.dataPublisher,
    required this.errorChannelName,
  });

  /// The channel name from which data messages will be streamed.
  ///
  /// Messages only begin to be forwarded when the stream has a listener.
  /// Channel messages published before a listener is attached will be dropped.
  final String dataChannelName;

  /// The data publisher to subscribe to.
  final DataPublisher dataPublisher;

  /// The channel name from which error messages will be received.
  ///
  /// The first error received will be added to the stream as an error event.
  /// Any new listeners attached after the first error is encountered will
  /// receive that error immediately.
  final String errorChannelName;
}

/// Creates a broadcast `Stream` from a `DataPublisher`.
///
/// The stream will emit data published to the configured data channel name
/// and will emit errors published to the configured error channel name.
///
/// Things to note:
///
/// - Messages only begin to be forwarded when the stream has at least one
///   listener. Channel messages published before that time will be dropped.
/// - The first error received on the error channel will be added to the stream
///   as an error event.
/// - Any new listeners attached after the first error is encountered will
///   receive that error immediately.
///
/// ```dart
/// final stream = createStreamFromDataPublisher(
///   StreamFromDataPublisherConfig(
///     dataChannelName: 'message',
///     dataPublisher: publisher,
///     errorChannelName: 'error',
///   ),
/// );
/// stream.listen(
///   (message) => print('Got message: $message'),
///   onError: (error) => print('Got error: $error'),
/// );
/// ```
Stream<TData> createStreamFromDataPublisher<TData>(
  StreamFromDataPublisherConfig config,
) {
  Object? firstError;
  var hasError = false;
  UnsubscribeFn? dataUnsubscribe;
  UnsubscribeFn? errorUnsubscribe;

  late final StreamController<TData> controller;
  controller = StreamController<TData>.broadcast(
    sync: true,
    onListen: () {
      if (hasError) {
        controller.addError(firstError!);
        return;
      }

      // Subscribe to the error channel.
      errorUnsubscribe ??= config.dataPublisher.on(config.errorChannelName, (
        err,
      ) {
        if (!hasError) {
          hasError = true;
          firstError = err;
          controller.addError(err ?? StateError('Unknown error'));

          // Clean up subscriptions after error.
          dataUnsubscribe?.call();
          dataUnsubscribe = null;
          errorUnsubscribe?.call();
          errorUnsubscribe = null;
        }
      });

      // Subscribe to the data channel.
      dataUnsubscribe ??= config.dataPublisher.on(config.dataChannelName, (
        data,
      ) {
        if (!controller.isClosed) {
          controller.add(data as TData);
        }
      });
    },
    onCancel: () {
      dataUnsubscribe?.call();
      dataUnsubscribe = null;
      errorUnsubscribe?.call();
      errorUnsubscribe = null;
      controller.close();
    },
  );

  return controller.stream;
}

/// Creates a single-subscription `Stream` from a `DataPublisher`.
///
/// This is the Dart equivalent of TypeScript's
/// `createAsyncIterableFromDataPublisher`. It returns a `Stream` that closely
/// matches the behavior of the TS async iterable:
///
/// - Messages published before the first listener are dropped.
/// - The first error is captured; queued messages are delivered before the
///   error.
/// - Aborting causes the stream to close after all queued messages are
///   delivered.
///
/// The `abortSignal` future, when completed, will signal the stream to close.
/// Use a `Completer` to control when the abort happens.
///
/// ```dart
/// final abortCompleter = Completer<void>();
/// final stream = createAsyncIterableFromDataPublisher(
///   dataPublisher: publisher,
///   dataChannelName: 'message',
///   errorChannelName: 'error',
///   abortSignal: abortCompleter.future,
/// );
///
/// await for (final message in stream) {
///   print('Got message: $message');
/// }
///
/// // To abort:
/// abortCompleter.complete();
/// ```
Stream<TData> createAsyncIterableFromDataPublisher<TData>({
  required Future<void> abortSignal,
  required String dataChannelName,
  required DataPublisher dataPublisher,
  required String errorChannelName,
}) {
  final iteratorStates = <Symbol, _IteratorState<TData>>{};
  var aborted = false;
  Object? firstError;
  var hasError = false;

  var symbolCounter = 0;
  Symbol nextSymbol() => Symbol('iterator_${symbolCounter++}');

  void publishErrorToAllIterators(Object error, {bool isAbort = false}) {
    for (final entry in iteratorStates.entries) {
      final state = entry.value;
      if (state.hasPolled) {
        final onError = state.onError!;
        iteratorStates.remove(entry.key);
        if (isAbort) {
          state.onAbort?.call();
        } else {
          onError(error);
        }
      } else {
        if (isAbort) {
          state.publishQueue.add(const _AbortItem());
        } else {
          state.publishQueue.add(_ErrorItem<TData>(error));
        }
      }
    }
  }

  // Set up abort handling.
  abortSignal.then((_) {
    if (aborted) return;
    aborted = true;
    publishErrorToAllIterators(StateError('Aborted'), isAbort: true);
  }).ignore();

  // Subscribe to error channel eagerly.
  UnsubscribeFn? errorUnsub;
  UnsubscribeFn? dataUnsub;

  void setupSubscriptions() {
    errorUnsub ??= dataPublisher.on(errorChannelName, (err) {
      if (!hasError) {
        hasError = true;
        firstError = err;
        publishErrorToAllIterators(err ?? StateError('Unknown error'));
      }
    });

    dataUnsub ??= dataPublisher.on(dataChannelName, (data) {
      for (final entry in iteratorStates.entries.toList()) {
        final state = entry.value;
        if (state.hasPolled) {
          final onData = state.onData!;
          iteratorStates[entry.key] = _IteratorState<TData>();
          onData(data as TData);
        } else {
          state.publishQueue.add(_DataItem<TData>(data as TData));
        }
      }
    });
  }

  setupSubscriptions();

  // Return a stream that mimics the async iterable behavior.
  late StreamController<TData> controller;
  controller = StreamController<TData>(
    onListen: () async {
      if (aborted) {
        await controller.close();
        return;
      }
      if (hasError) {
        controller.addError(firstError!);
        await controller.close();
        return;
      }

      final iteratorKey = nextSymbol();
      iteratorStates[iteratorKey] = _IteratorState<TData>();

      try {
        while (true) {
          final state = iteratorStates[iteratorKey];
          if (state == null) {
            controller.addError(
              SolanaError(
                SolanaErrorCode
                    .invariantViolationSubscriptionIteratorStateMissing,
              ),
            );
            break;
          }
          if (state.hasPolled) {
            controller.addError(
              SolanaError(
                SolanaErrorCode
                    .invariantViolationSubscriptionIteratorMustNotPollBeforeResolvingExistingMessagePromise,
              ),
            );
            break;
          }

          final publishQueue = state.publishQueue;
          if (publishQueue.isNotEmpty) {
            final items = List<_PublishItem<TData>>.of(publishQueue);
            publishQueue.clear();

            var shouldBreak = false;
            for (final item in items) {
              switch (item) {
                case _DataItem<TData>(:final data):
                  controller.add(data);
                case _ErrorItem<TData>(:final error):
                  controller.addError(error);
                  shouldBreak = true;
                case _AbortItem<TData>():
                  shouldBreak = true;
              }
              if (shouldBreak) break;
            }
            if (shouldBreak) break;
          } else {
            // Wait for the next message.
            final completer = Completer<_PublishItem<TData>>();
            iteratorStates[iteratorKey] = _IteratorState<TData>(
              hasPolled: true,
              onData: (data) {
                if (!completer.isCompleted) {
                  completer.complete(_DataItem<TData>(data));
                }
              },
              onError: (error) {
                if (!completer.isCompleted) {
                  completer.complete(_ErrorItem<TData>(error));
                }
              },
              onAbort: () {
                if (!completer.isCompleted) {
                  completer.complete(const _AbortItem());
                }
              },
            );

            final item = await completer.future;
            switch (item) {
              case _DataItem<TData>(:final data):
                controller.add(data);
              case _ErrorItem<TData>(:final error):
                controller.addError(error);
              case _AbortItem<TData>():
                break;
            }
            if (item is! _DataItem<TData>) break;
          }
        }
      } finally {
        iteratorStates.remove(iteratorKey);
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    },
    onCancel: () {
      dataUnsub?.call();
      errorUnsub?.call();
    },
  );

  return controller.stream;
}

sealed class _PublishItem<TData> {
  const _PublishItem();
}

class _DataItem<TData> extends _PublishItem<TData> {
  const _DataItem(this.data);
  final TData data;
}

class _ErrorItem<TData> extends _PublishItem<TData> {
  const _ErrorItem(this.error);
  final Object error;
}

class _AbortItem<TData> extends _PublishItem<TData> {
  const _AbortItem();
}

class _IteratorState<TData> {
  _IteratorState({
    this.hasPolled = false,
    this.onData,
    this.onError,
    this.onAbort,
  });

  final bool hasPolled;
  final void Function(TData)? onData;
  final void Function(Object)? onError;
  final void Function()? onAbort;
  final List<_PublishItem<TData>> publishQueue = [];
}
