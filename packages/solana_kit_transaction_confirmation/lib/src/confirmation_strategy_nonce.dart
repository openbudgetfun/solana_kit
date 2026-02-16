import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The result of fetching a nonce account's current nonce value.
class NonceAccountInfo {
  /// Creates a [NonceAccountInfo].
  const NonceAccountInfo({required this.nonceValue});

  /// The current nonce value stored in the account.
  final String nonceValue;
}

/// Configuration for the nonce invalidation promise factory.
class NonceInvalidationConfig {
  /// Creates a [NonceInvalidationConfig].
  const NonceInvalidationConfig({
    required this.getNonceAccount,
    required this.onAccountNotification,
  });

  /// Function to get the current nonce value from an account via RPC.
  ///
  /// Returns `null` if the account is not found.
  final Future<NonceAccountInfo?> Function(
    String nonceAccountAddress, {
    required AbortSignal abortSignal,
    required Commitment commitment,
  })
  getNonceAccount;

  /// Function to subscribe to account notifications for the nonce account.
  ///
  /// Should call the `onNotification` callback for each notification, passing
  /// the current nonce value. Returns a future that completes when the
  /// subscription ends.
  final Future<void> Function(
    String nonceAccountAddress, {
    required AbortSignal abortSignal,
    required Commitment commitment,
    required void Function({required String nonceValue}) onNotification,
  })
  onAccountNotification;
}

/// Creates a factory function that returns a promise that rejects when a
/// durable nonce value changes (nonce has been advanced).
///
/// When a transaction's lifetime is tied to the value stored in a nonce
/// account, that transaction can be landed on the network until the nonce is
/// advanced to a new value.
///
/// Throws [SolanaError] with:
/// - [SolanaErrorCode.invalidNonce] when the nonce has been advanced.
/// - [SolanaErrorCode.nonceAccountNotFound] when the nonce account is not
///   found.
Future<Never> Function({
  required AbortSignal abortSignal,
  required Commitment commitment,
  required String expectedNonceValue,
  required String nonceAccountAddress,
})
createNonceInvalidationPromiseFactory(NonceInvalidationConfig config) {
  return ({
    required AbortSignal abortSignal,
    required Commitment commitment,
    required String expectedNonceValue,
    required String nonceAccountAddress,
  }) async {
    final abortController = AbortController();

    abortSignal.future.then((_) {
      abortController.abort(abortSignal.reason);
    }).ignore();

    try {
      // STEP 1: Set up a subscription for nonce account changes.
      final nonceInvalidationCompleter = Completer<Never>();

      // The subscription future is intentionally not awaited because it runs
      // in parallel with the one-shot nonce account check.
      // ignore: unawaited_futures
      config.onAccountNotification(
        nonceAccountAddress,
        abortSignal: abortController.signal,
        commitment: commitment,
        onNotification: ({required String nonceValue}) {
          if (nonceInvalidationCompleter.isCompleted) return;
          if (nonceValue != expectedNonceValue) {
            nonceInvalidationCompleter.completeError(
              SolanaError(SolanaErrorCode.invalidNonce, {
                'actualNonceValue': nonceValue,
                'expectedNonceValue': expectedNonceValue,
              }),
            );
          }
        },
      );

      // STEP 2: Having subscribed for updates, make a one-shot request for
      // the current nonce value to check if it has already been advanced.
      final nonceIsAlreadyInvalidCompleter = Completer<Never>();
      unawaited(
        config
            .getNonceAccount(
              nonceAccountAddress,
              abortSignal: abortController.signal,
              commitment: commitment,
            )
            .then((nonceAccount) {
              if (nonceIsAlreadyInvalidCompleter.isCompleted) return;
              if (nonceAccount == null) {
                nonceIsAlreadyInvalidCompleter.completeError(
                  SolanaError(SolanaErrorCode.nonceAccountNotFound, {
                    'nonceAccountAddress': nonceAccountAddress,
                  }),
                );
              } else if (nonceAccount.nonceValue != expectedNonceValue) {
                nonceIsAlreadyInvalidCompleter.completeError(
                  SolanaError(SolanaErrorCode.invalidNonce, {
                    'actualNonceValue': nonceAccount.nonceValue,
                    'expectedNonceValue': expectedNonceValue,
                  }),
                );
              }
              // Otherwise, leave the completer pending (never resolves).
            })
            .catchError((Object error) {
              if (!nonceIsAlreadyInvalidCompleter.isCompleted) {
                nonceIsAlreadyInvalidCompleter.completeError(error);
              }
            }),
      );

      return await Future.any([
        nonceInvalidationCompleter.future,
        nonceIsAlreadyInvalidCompleter.future,
      ]);
    } finally {
      abortController.abort();
    }
  };
}
