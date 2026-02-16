import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

import 'package:solana_kit_transaction_confirmation/src/confirmation_strategy_racer.dart';

/// Waits for a transaction using a durable nonce to confirm.
///
/// Races the signature confirmation against nonce invalidation detection.
/// If the nonce is invalidated before the signature confirms, the returned
/// future will reject with the nonce invalidation error.
///
/// [abortSignal] can be used to cancel the confirmation process.
/// [commitment] is the target commitment level.
/// [getNonceInvalidationPromise] is a function that rejects when the nonce
/// is invalidated.
/// [getRecentSignatureConfirmationPromise] is a function that resolves when
/// the signature reaches the target commitment.
/// [nonceAccountAddress] is the address of the nonce account.
/// [nonceValue] is the expected nonce value.
/// [signature] is the transaction signature to confirm.
Future<void> waitForDurableNonceTransactionConfirmation({
  required AbortSignal abortSignal,
  required Commitment commitment,
  required Future<Never> Function({
    required AbortSignal abortSignal,
    required Commitment commitment,
    required String expectedNonceValue,
    required String nonceAccountAddress,
  })
  getNonceInvalidationPromise,
  required GetRecentSignatureConfirmationPromise
  getRecentSignatureConfirmationPromise,
  required String nonceAccountAddress,
  required String nonceValue,
  required String signature,
}) async {
  await raceStrategies(
    signature,
    BaseTransactionConfirmationStrategyConfig(
      abortSignal: abortSignal,
      commitment: commitment,
      getRecentSignatureConfirmationPromise:
          getRecentSignatureConfirmationPromise,
    ),
    ({required AbortSignal abortSignal}) => [
      getNonceInvalidationPromise(
        abortSignal: abortSignal,
        commitment: commitment,
        expectedNonceValue: nonceValue,
        nonceAccountAddress: nonceAccountAddress,
      ),
    ],
  );
}

/// Waits for a transaction using block height for lifetime to confirm.
///
/// Races the signature confirmation against block height exceedence detection.
/// If the block height exceeds the last valid block height before the
/// signature confirms, the returned future will reject with a block height
/// exceeded error.
///
/// [abortSignal] can be used to cancel the confirmation process.
/// [commitment] is the target commitment level.
/// [getBlockHeightExceedencePromise] is a function that rejects when the
/// block height has been exceeded.
/// [getRecentSignatureConfirmationPromise] is a function that resolves when
/// the signature reaches the target commitment.
/// [lastValidBlockHeight] is the last block height at which the transaction
/// is still valid.
/// [signature] is the transaction signature to confirm.
Future<void> waitForRecentTransactionConfirmation({
  required AbortSignal abortSignal,
  required Commitment commitment,
  required Future<Never> Function({
    required AbortSignal abortSignal,
    required BigInt lastValidBlockHeight,
    Commitment? commitment,
  })
  getBlockHeightExceedencePromise,
  required GetRecentSignatureConfirmationPromise
  getRecentSignatureConfirmationPromise,
  required BigInt lastValidBlockHeight,
  required String signature,
}) async {
  await raceStrategies(
    signature,
    BaseTransactionConfirmationStrategyConfig(
      abortSignal: abortSignal,
      commitment: commitment,
      getRecentSignatureConfirmationPromise:
          getRecentSignatureConfirmationPromise,
    ),
    ({required AbortSignal abortSignal}) => [
      getBlockHeightExceedencePromise(
        abortSignal: abortSignal,
        commitment: commitment,
        lastValidBlockHeight: lastValidBlockHeight,
      ),
    ],
  );
}

/// Waits for a transaction to confirm using a timeout strategy.
///
/// Races the signature confirmation against a timeout. If the timeout elapses
/// before the signature confirms, the returned future will reject with a
/// timeout error.
///
/// [abortSignal] can be used to cancel the confirmation process.
/// [commitment] is the target commitment level.
/// [getTimeoutPromise] is a function that rejects after a timeout.
/// [getRecentSignatureConfirmationPromise] is a function that resolves when
/// the signature reaches the target commitment.
/// [signature] is the transaction signature to confirm.
@Deprecated('Use waitForRecentTransactionConfirmation instead')
Future<void> waitForRecentTransactionConfirmationUntilTimeout({
  required AbortSignal abortSignal,
  required Commitment commitment,
  required Future<Never> Function({
    required AbortSignal abortSignal,
    required Commitment commitment,
  })
  getTimeoutPromise,
  required GetRecentSignatureConfirmationPromise
  getRecentSignatureConfirmationPromise,
  required String signature,
}) async {
  await raceStrategies(
    signature,
    BaseTransactionConfirmationStrategyConfig(
      abortSignal: abortSignal,
      commitment: commitment,
      getRecentSignatureConfirmationPromise:
          getRecentSignatureConfirmationPromise,
    ),
    ({required AbortSignal abortSignal}) => [
      getTimeoutPromise(abortSignal: abortSignal, commitment: commitment),
    ],
  );
}
