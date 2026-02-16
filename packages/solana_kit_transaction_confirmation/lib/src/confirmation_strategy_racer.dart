import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The type of a function that creates a recent signature confirmation promise.
typedef GetRecentSignatureConfirmationPromise =
    Future<void> Function({
      required AbortSignal abortSignal,
      required Commitment commitment,
      required String signature,
    });

/// Configuration for a confirmation strategy race.
class BaseTransactionConfirmationStrategyConfig {
  /// Creates a [BaseTransactionConfirmationStrategyConfig].
  const BaseTransactionConfirmationStrategyConfig({
    required this.commitment,
    required this.getRecentSignatureConfirmationPromise,
    this.abortSignal,
  });

  /// An optional abort signal to cancel the confirmation.
  final AbortSignal? abortSignal;

  /// The target commitment level.
  final Commitment commitment;

  /// A function that returns a promise resolving when a signature reaches
  /// the target commitment level.
  final GetRecentSignatureConfirmationPromise
  getRecentSignatureConfirmationPromise;
}

/// Races a signature confirmation promise against specific strategies.
///
/// The first strategy to resolve or reject determines the outcome. All
/// strategies are aborted when one completes.
///
/// [signature] is the transaction signature to confirm.
/// [config] contains the base configuration for the race.
/// [getSpecificStrategiesForRace] returns the specific strategy futures to
/// race against the signature confirmation promise.
Future<void> raceStrategies(
  String signature,
  BaseTransactionConfirmationStrategyConfig config,
  List<Future<void>> Function({required AbortSignal abortSignal})
  getSpecificStrategiesForRace,
) async {
  final callerAbortSignal = config.abortSignal;

  if (callerAbortSignal != null && callerAbortSignal.isAborted) {
    throw StateError('The operation was aborted: ${callerAbortSignal.reason}');
  }

  final abortController = AbortController();

  if (callerAbortSignal != null) {
    callerAbortSignal.future.then((_) {
      abortController.abort(callerAbortSignal.reason);
    }).ignore();
  }

  try {
    final specificStrategies = getSpecificStrategiesForRace(
      abortSignal: abortController.signal,
    );

    final signatureConfirmation = config.getRecentSignatureConfirmationPromise(
      abortSignal: abortController.signal,
      commitment: config.commitment,
      signature: signature,
    );

    final allFutures = [signatureConfirmation, ...specificStrategies];

    // Implement a safe race equivalent to TypeScript's `safeRace`.
    // Using a Completer that completes with the first future to settle.
    // `then<void>` with `onError` is used instead of `catchError` because
    // some futures may be `Future<Never>` at runtime, and `catchError`
    // requires the handler to return the same type as the future.
    final raceCompleter = Completer<void>();
    for (final future in allFutures) {
      unawaited(
        future.then<void>(
          (value) {
            if (!raceCompleter.isCompleted) {
              raceCompleter.complete();
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!raceCompleter.isCompleted) {
              raceCompleter.completeError(error, stackTrace);
            }
          },
        ),
      );
    }

    await raceCompleter.future;
  } finally {
    abortController.abort();
  }
}
