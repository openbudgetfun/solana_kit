import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

/// Returns `true` if [error] is an abort/cancellation error.
///
/// This is the Dart counterpart of `@solana/promises`' `isAbortError`. It
/// recognizes the [AbortError] thrown by the websocket channel when a
/// subscription is aborted.
bool isAbortError(Object? error) => error is AbortError;

/// Returns a future that completes with the result of [future], or rejects
/// with the [CancellationToken]'s reason if it fires first.
///
/// This is the Dart counterpart of `@solana/promises`' `getAbortablePromise`.
/// When [cancellationToken] is `null`, [future] is returned unchanged.
Future<T> getAbortablePromise<T>(
  Future<T> future, {
  CancellationToken? cancellationToken,
}) {
  if (cancellationToken == null) return future;
  return safeRace([
    // This future only ever completes when the token is cancelled; otherwise
    // it idles forever. It comes first so an abort wins even if [future]'s
    // result is already ready.
    cancellationToken.future.then((_) {
      final reason = cancellationToken.reason;
      if (reason is Error) throw reason;
      if (reason is Exception) throw reason;
      throw StateError('Aborted');
    }),
    future,
  ]);
}

/// Races [futures] without leaking unhandled rejections from the losers.
///
/// This is the Dart counterpart of `@solana/promises`' `safeRace`. The first
/// future to complete wins; the others' results and errors are silently
/// discarded (their errors are caught so they do not become unhandled).
Future<T> safeRace<T>(List<Future<T>> futures) {
  final completer = Completer<T>();
  for (final future in futures) {
    future.then(
      (value) {
        if (!completer.isCompleted) completer.complete(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    );
  }
  return completer.future;
}
