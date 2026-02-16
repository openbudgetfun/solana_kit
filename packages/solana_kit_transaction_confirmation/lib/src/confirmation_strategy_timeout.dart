import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Returns a [Future] that rejects after a timeout.
///
/// The timeout is 30 seconds when [commitment] is [Commitment.processed], and
/// 60 seconds otherwise.
///
/// When no other heuristic exists to infer that a transaction has expired, you
/// can use this promise factory with a commitment level. You would typically
/// race this with another confirmation strategy.
///
/// Throws a [TimeoutException] after the timeout elapses.
/// Throws a [StateError] if the [abortSignal] is aborted before the timeout.
Future<Never> getTimeoutPromise({
  required AbortSignal abortSignal,
  required Commitment commitment,
}) async {
  final completer = Completer<Never>();

  if (abortSignal.isAborted) {
    throw StateError('The operation was aborted: ${abortSignal.reason}');
  }

  final timeoutMs = commitment == Commitment.processed ? 30000 : 60000;
  final stopwatch = Stopwatch()..start();

  final timer = Timer(Duration(milliseconds: timeoutMs), () {
    final elapsedMs = stopwatch.elapsedMilliseconds;
    stopwatch.stop();
    if (!completer.isCompleted) {
      completer.completeError(
        TimeoutException(
          'Timeout elapsed after $elapsedMs ms',
          Duration(milliseconds: timeoutMs),
        ),
      );
    }
  });

  abortSignal.future.then((_) {
    timer.cancel();
    stopwatch.stop();
    if (!completer.isCompleted) {
      completer.completeError(
        StateError('The operation was aborted: ${abortSignal.reason}'),
      );
    }
  }).ignore();

  return completer.future;
}
