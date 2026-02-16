import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/src/signature_status.dart';

/// Configuration for the recent signature confirmation strategy factory.
class RecentSignatureConfirmationConfig {
  /// Creates a [RecentSignatureConfirmationConfig].
  const RecentSignatureConfirmationConfig({
    required this.getSignatureStatuses,
    required this.onSignatureNotification,
  });

  /// Function to get the current status of signatures via RPC.
  ///
  /// Should return a list of [SignatureStatus] results, one per input
  /// signature. The result may be `null` if the signature is not found.
  final Future<List<SignatureStatus?>> Function(
    List<String> signatures, {
    required AbortSignal abortSignal,
  })
  getSignatureStatuses;

  /// Function to subscribe to signature notifications via RPC subscriptions.
  ///
  /// This should set up a subscription and call the `onNotification` callback
  /// each time a notification arrives. Returns a future that completes when
  /// the subscription ends.
  ///
  /// The callback receives an `err` field (null if no error).
  final Future<void> Function(
    String signature, {
    required AbortSignal abortSignal,
    required Commitment commitment,
    required void Function({required Object? err}) onNotification,
  })
  onSignatureNotification;
}

/// Creates a factory function for signature confirmation promises.
///
/// The returned function will resolve when a recently-landed transaction
/// achieves the target confirmation commitment, and throw when the transaction
/// fails with an error.
///
/// The strategy works in two parallel steps:
/// 1. Sets up a subscription for status changes to the signature.
/// 2. Makes a one-shot request for the current status to handle the case where
///    the signature reached the target commitment before the subscription
///    started.
Future<void> Function({
  required AbortSignal abortSignal,
  required Commitment commitment,
  required String signature,
})
createRecentSignatureConfirmationPromiseFactory(
  RecentSignatureConfirmationConfig config,
) {
  return ({
    required AbortSignal abortSignal,
    required Commitment commitment,
    required String signature,
  }) async {
    final abortController = AbortController();

    abortSignal.future.then((_) {
      abortController.abort(abortSignal.reason);
    }).ignore();

    try {
      // STEP 1: Set up a subscription for status changes to the signature.
      final signatureDidCommitCompleter = Completer<void>();

      // The subscription future is intentionally not awaited because it runs
      // in parallel with the one-shot status check.
      // ignore: unawaited_futures, document_ignores
      config.onSignatureNotification(
        signature,
        abortSignal: abortController.signal,
        commitment: commitment,
        onNotification: ({required Object? err}) {
          if (signatureDidCommitCompleter.isCompleted) return;
          if (err != null) {
            signatureDidCommitCompleter.completeError(
              StateError('Transaction failed: $err'),
            );
          } else {
            signatureDidCommitCompleter.complete();
          }
        },
      );

      // STEP 2: Having subscribed for updates, make a one-shot request for
      // the current status.
      final signatureStatusLookupCompleter = Completer<void>();
      unawaited(
        config
            .getSignatureStatuses([
              signature,
            ], abortSignal: abortController.signal)
            .then((results) {
              if (signatureStatusLookupCompleter.isCompleted) return;
              final signatureStatus = results.isNotEmpty ? results[0] : null;
              if (signatureStatus?.err != null) {
                signatureStatusLookupCompleter.completeError(
                  StateError('Transaction failed: ${signatureStatus!.err}'),
                );
              } else if (signatureStatus?.confirmationStatus != null &&
                  commitmentComparator(
                        signatureStatus!.confirmationStatus!,
                        commitment,
                      ) >=
                      0) {
                signatureStatusLookupCompleter.complete();
              }
              // Otherwise, leave the completer pending (never resolves).
            })
            .catchError((Object error) {
              if (!signatureStatusLookupCompleter.isCompleted) {
                signatureStatusLookupCompleter.completeError(error);
              }
            }),
      );

      await Future.any([
        signatureDidCommitCompleter.future,
        signatureStatusLookupCompleter.future,
      ]);
    } finally {
      abortController.abort();
    }
  };
}
