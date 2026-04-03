// ignore_for_file: public_member_api_docs
import 'dart:async';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart'
    show
        GetAccountInfoConfig,
        GetEpochInfoConfig,
        GetSignatureStatusesConfig,
        SendTransactionConfig;
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/src/confirmation_strategy_blockheight.dart';
import 'package:solana_kit_transaction_confirmation/src/confirmation_strategy_nonce.dart';
import 'package:solana_kit_transaction_confirmation/src/signature_status.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Default interval used by polling-based confirmation helpers.
const defaultTransactionConfirmationPollInterval = Duration(milliseconds: 400);

/// Configuration for polling-based transaction confirmation via an [Rpc]
/// client.
class RpcTransactionConfirmationConfig {
  /// Creates a new [RpcTransactionConfirmationConfig].
  const RpcTransactionConfirmationConfig({
    this.abortSignal,
    this.commitment = Commitment.confirmed,
    this.pollInterval = defaultTransactionConfirmationPollInterval,
    this.searchTransactionHistory = false,
  });

  /// Optional abort signal used to stop polling.
  final AbortSignal? abortSignal;

  /// Target commitment to wait for.
  final Commitment commitment;

  /// Delay between polling attempts.
  final Duration pollInterval;

  /// Whether to search historical signature status data while polling.
  final bool searchTransactionHistory;
}

/// Configuration for [sendAndConfirmTransaction].
class SendAndConfirmTransactionConfig extends RpcTransactionConfirmationConfig {
  /// Creates a new [SendAndConfirmTransactionConfig].
  const SendAndConfirmTransactionConfig({
    super.abortSignal,
    super.commitment = Commitment.confirmed,
    super.pollInterval = defaultTransactionConfirmationPollInterval,
    super.searchTransactionHistory = false,
    this.maxRetries,
    this.minContextSlot,
    this.preflightCommitment,
    this.skipPreflight,
  });

  /// Maximum number of retries to request from the RPC node.
  final BigInt? maxRetries;

  /// Prevents accessing stale node state when submitting the transaction.
  final Slot? minContextSlot;

  /// Commitment used for preflight simulation.
  final Commitment? preflightCommitment;

  /// Whether to skip preflight simulation.
  final bool? skipPreflight;

  SendTransactionConfig toSendTransactionConfig() {
    return SendTransactionConfig(
      maxRetries: maxRetries,
      minContextSlot: minContextSlot,
      preflightCommitment: preflightCommitment ?? commitment,
      skipPreflight: skipPreflight,
    );
  }
}

/// Waits for [transaction] to confirm using RPC polling only.
///
/// The helper inspects the transaction's lifetime constraint at runtime:
///
/// - blockhash lifetimes race signature confirmation against block height
///   expiry,
/// - durable nonce lifetimes race signature confirmation against nonce
///   invalidation.
///
/// The [transaction] must preserve lifetime metadata, which is true for
/// transactions created by `compileTransaction(...)` and the standard signing
/// helpers in `solana_kit_transactions` / `solana_kit_signers`.
Future<void> waitForTransactionConfirmation({
  required Rpc rpc,
  required Signature signature,
  required Transaction transaction,
  RpcTransactionConfirmationConfig config =
      const RpcTransactionConfirmationConfig(),
}) async {
  _throwIfAborted(config.abortSignal);

  final stopController = AbortController();
  final transactionWithLifetime = _requireTransactionWithLifetime(transaction);

  try {
    final confirmationFuture = _pollForSignatureConfirmation(
      rpc: rpc,
      signature: signature,
      commitment: config.commitment,
      pollInterval: config.pollInterval,
      searchTransactionHistory: config.searchTransactionHistory,
      abortSignal: config.abortSignal,
      stopSignal: stopController.signal,
    );

    final lifetimeFuture = switch (transactionWithLifetime.lifetimeConstraint) {
      TransactionBlockhashLifetime(:final lastValidBlockHeight) =>
        _pollForBlockHeightExceedence(
          rpc: rpc,
          lastValidBlockHeight: lastValidBlockHeight,
          commitment: config.commitment,
          pollInterval: config.pollInterval,
          abortSignal: config.abortSignal,
          stopSignal: stopController.signal,
        ),
      TransactionDurableNonceLifetime(
        :final nonce,
        :final nonceAccountAddress,
      ) =>
        _pollForNonceInvalidation(
          rpc: rpc,
          expectedNonceValue: nonce,
          nonceAccountAddress: nonceAccountAddress,
          commitment: config.commitment,
          pollInterval: config.pollInterval,
          abortSignal: config.abortSignal,
          stopSignal: stopController.signal,
        ),
    };

    await Future.any([confirmationFuture, lifetimeFuture]);
  } finally {
    stopController.abort();
  }
}

/// Sends [transaction] over [rpc] and waits for it to confirm.
///
/// This is an additive convenience API layered over the existing lower-level
/// transaction and confirmation primitives.
Future<Signature> sendAndConfirmTransaction({
  required Rpc rpc,
  required Transaction transaction,
  SendAndConfirmTransactionConfig config =
      const SendAndConfirmTransactionConfig(),
}) async {
  _throwIfAborted(config.abortSignal);
  _requireTransactionWithLifetime(transaction);
  assertIsFullySignedTransaction(transaction);

  final signatureValue = await rpc
      .sendTransaction(
        getBase64EncodedWireTransaction(transaction),
        config.toSendTransactionConfig(),
      )
      .send(
        config.abortSignal == null
            ? null
            : RpcSendOptions(abortSignal: config.abortSignal!.future),
      );

  final transactionSignature = signature(signatureValue);

  await waitForTransactionConfirmation(
    rpc: rpc,
    signature: transactionSignature,
    transaction: transaction,
    config: RpcTransactionConfirmationConfig(
      abortSignal: config.abortSignal,
      commitment: config.commitment,
      pollInterval: config.pollInterval,
      searchTransactionHistory: config.searchTransactionHistory,
    ),
  );

  return transactionSignature;
}

Future<void> _pollForSignatureConfirmation({
  required Rpc rpc,
  required Signature signature,
  required Commitment commitment,
  required Duration pollInterval,
  required bool searchTransactionHistory,
  required AbortSignal? abortSignal,
  required AbortSignal stopSignal,
}) async {
  while (true) {
    if (stopSignal.isAborted) return;
    _throwIfAborted(abortSignal);

    final response = await rpc
        .getSignatureStatuses(
          [signature],
          searchTransactionHistory
              ? const GetSignatureStatusesConfig(searchTransactionHistory: true)
              : null,
        )
        .send(
          abortSignal == null
              ? null
              : RpcSendOptions(abortSignal: abortSignal.future),
        );

    if (stopSignal.isAborted) return;
    _throwIfAborted(abortSignal);

    final statuses = _parseSignatureStatusesResponse(response);
    final status = statuses.isNotEmpty ? statuses[0] : null;

    if (status?.err != null) {
      throw StateError('Transaction failed: ${status!.err}');
    }

    if (status?.confirmationStatus != null &&
        commitmentComparator(status!.confirmationStatus!, commitment) >= 0) {
      return;
    }

    await _waitForNextPoll(
      pollInterval,
      abortSignal: abortSignal,
      stopSignal: stopSignal,
    );
  }
}

Future<void> _pollForBlockHeightExceedence({
  required Rpc rpc,
  required BigInt lastValidBlockHeight,
  required Commitment commitment,
  required Duration pollInterval,
  required AbortSignal? abortSignal,
  required AbortSignal stopSignal,
}) async {
  while (true) {
    if (stopSignal.isAborted) return;
    _throwIfAborted(abortSignal);

    final response = await rpc
        .getEpochInfo(GetEpochInfoConfig(commitment: commitment))
        .send(
          abortSignal == null
              ? null
              : RpcSendOptions(abortSignal: abortSignal.future),
        );

    if (stopSignal.isAborted) return;
    _throwIfAborted(abortSignal);

    final epochInfo = _parseEpochInfoResponse(response);
    if (epochInfo.blockHeight > lastValidBlockHeight) {
      throw SolanaError(SolanaErrorCode.blockHeightExceeded, {
        'currentBlockHeight': epochInfo.blockHeight,
        'lastValidBlockHeight': lastValidBlockHeight,
      });
    }

    await _waitForNextPoll(
      pollInterval,
      abortSignal: abortSignal,
      stopSignal: stopSignal,
    );
  }
}

Future<void> _pollForNonceInvalidation({
  required Rpc rpc,
  required String expectedNonceValue,
  required Address nonceAccountAddress,
  required Commitment commitment,
  required Duration pollInterval,
  required AbortSignal? abortSignal,
  required AbortSignal stopSignal,
}) async {
  while (true) {
    if (stopSignal.isAborted) return;
    _throwIfAborted(abortSignal);

    final response = await rpc
        .getAccountInfo(
          nonceAccountAddress,
          GetAccountInfoConfig(
            commitment: commitment,
            encoding: AccountEncoding.jsonParsed,
          ),
        )
        .send(
          abortSignal == null
              ? null
              : RpcSendOptions(abortSignal: abortSignal.future),
        );

    if (stopSignal.isAborted) return;
    _throwIfAborted(abortSignal);

    final nonceAccount = _parseNonceAccountInfoResponse(
      nonceAccountAddress,
      response,
    );

    if (nonceAccount.nonceValue != expectedNonceValue) {
      throw SolanaError(SolanaErrorCode.invalidNonce, {
        'actualNonceValue': nonceAccount.nonceValue,
        'expectedNonceValue': expectedNonceValue,
      });
    }

    await _waitForNextPoll(
      pollInterval,
      abortSignal: abortSignal,
      stopSignal: stopSignal,
    );
  }
}

Future<void> _waitForNextPoll(
  Duration pollInterval, {
  required AbortSignal? abortSignal,
  required AbortSignal stopSignal,
}) async {
  if (stopSignal.isAborted) return;
  _throwIfAborted(abortSignal);

  final completer = Completer<void>();
  final timer = Timer(pollInterval, () {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });

  stopSignal.future.then((_) {
    timer.cancel();
    if (!completer.isCompleted) {
      completer.complete();
    }
  }).ignore();

  abortSignal?.future.then((_) {
    timer.cancel();
    if (!completer.isCompleted) {
      completer.completeError(
        StateError('The operation was aborted: ${abortSignal.reason}'),
      );
    }
  }).ignore();

  await completer.future;
}

TransactionWithLifetime _requireTransactionWithLifetime(
  Transaction transaction,
) {
  if (transaction is TransactionWithLifetime) {
    return transaction;
  }

  throw StateError(
    'Transaction confirmation requires a TransactionWithLifetime. '
    'Use compileTransaction(...) and preserve the returned lifetime metadata.',
  );
}

void _throwIfAborted(AbortSignal? abortSignal) {
  if (abortSignal?.isAborted ?? false) {
    throw StateError('The operation was aborted: ${abortSignal!.reason}');
  }
}

List<SignatureStatus?> _parseSignatureStatusesResponse(
  Map<String, Object?> response,
) {
  final values = _asList(response['value'], 'getSignatureStatuses.value');
  return values.map(_parseSignatureStatus).toList();
}

SignatureStatus? _parseSignatureStatus(Object? value) {
  if (value == null) return null;

  final map = _asMap(value, 'signature status');
  return SignatureStatus(
    confirmationStatus: _parseCommitment(map['confirmationStatus']),
    err: map['err'],
  );
}

EpochInfo _parseEpochInfoResponse(Map<String, Object?> response) {
  return EpochInfo(
    absoluteSlot: _asBigInt(response['absoluteSlot'], 'absoluteSlot'),
    blockHeight: _asBigInt(response['blockHeight'], 'blockHeight'),
  );
}

NonceAccountInfo _parseNonceAccountInfoResponse(
  Address nonceAccountAddress,
  Map<String, Object?> response,
) {
  final accountValue = response['value'];
  if (accountValue == null) {
    throw SolanaError(SolanaErrorCode.nonceAccountNotFound, {
      'nonceAccountAddress': nonceAccountAddress.value,
    });
  }

  final accountMap = _asMap(accountValue, 'account info value');
  final dataMap = _asMap(accountMap['data'], 'account info data');
  final parsedMap = _asMap(dataMap['parsed'], 'parsed account data');
  final infoMap = _asMap(parsedMap['info'], 'parsed nonce account info');
  final blockhash = infoMap['blockhash'];

  if (blockhash is! String) {
    throw StateError(
      'Expected parsed nonce account info to contain a string blockhash.',
    );
  }

  return NonceAccountInfo(nonceValue: blockhash);
}

List<Object?> _asList(Object? value, String context) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return List<Object?>.from(value);
  }
  throw StateError('Expected $context to be a list, got $value.');
}

Map<String, Object?> _asMap(Object? value, String context) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return Map<String, Object?>.fromEntries(
      value.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)),
    );
  }
  throw StateError('Expected $context to be a map, got $value.');
}

BigInt _asBigInt(Object? value, String context) {
  if (value is BigInt) {
    return value;
  }
  if (value is int) {
    return BigInt.from(value);
  }
  if (value is String) {
    return BigInt.parse(value);
  }
  throw StateError('Expected $context to be numeric, got $value.');
}

Commitment? _parseCommitment(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw StateError('Expected commitment to be a string, got $value.');
  }

  return switch (value) {
    'processed' => Commitment.processed,
    'confirmed' => Commitment.confirmed,
    'finalized' => Commitment.finalized,
    _ => throw StateError('Unsupported commitment value: $value'),
  };
}
