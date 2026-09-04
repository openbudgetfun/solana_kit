import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

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
    required CancellationToken abortSignal,
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
    required CancellationToken abortSignal,
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
  required CancellationToken abortSignal,
  required Commitment commitment,
  required String expectedNonceValue,
  required String nonceAccountAddress,
})
createNonceInvalidationPromiseFactory(NonceInvalidationConfig config) {
  return ({
    required CancellationToken abortSignal,
    required Commitment commitment,
    required String expectedNonceValue,
    required String nonceAccountAddress,
  }) async {
    if (abortSignal.isCancelled) {
      throw StateError('The operation was aborted: ${abortSignal.reason}');
    }

    final abortController = CancellationTokenSource();
    final nonceInvalidationCompleter = Completer<Never>();

    abortSignal.future.then((_) {
      if (abortController.token.isCancelled) return;
      abortController.cancel(abortSignal.reason);
      if (!nonceInvalidationCompleter.isCompleted) {
        nonceInvalidationCompleter.completeError(
          StateError('The operation was aborted: ${abortSignal.reason}'),
        );
      }
    }).ignore();

    try {
      // STEP 1: Set up a subscription for nonce account changes.
      unawaited(
        config
            .onAccountNotification(
              nonceAccountAddress,
              abortSignal: abortController.token,
              commitment: commitment,
              onNotification: ({required nonceValue}) {
                if (abortController.token.isCancelled) return;
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
            )
            .then<void>(
              (_) {
                if (abortController.token.isCancelled) return;
                if (!nonceInvalidationCompleter.isCompleted) {
                  nonceInvalidationCompleter.completeError(
                    StateError(
                      'The confirmation subscription ended unexpectedly.',
                    ),
                  );
                }
              },
              onError: (Object error, StackTrace stackTrace) {
                if (abortController.token.isCancelled) return;
                if (!nonceInvalidationCompleter.isCompleted) {
                  nonceInvalidationCompleter.completeError(error, stackTrace);
                }
              },
            ),
      );

      // STEP 2: Having subscribed for updates, make a one-shot request for
      // the current nonce value to check if it has already been advanced.
      final nonceIsAlreadyInvalidCompleter = Completer<Never>();
      unawaited(
        config
            .getNonceAccount(
              nonceAccountAddress,
              abortSignal: abortController.token,
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
      abortController.cancel();
    }
  };
}
