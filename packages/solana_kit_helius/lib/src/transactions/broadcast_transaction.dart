import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Broadcasts a base64-encoded transaction to the Helius sender and tracks it
/// until it lands.
///
/// The [restClient] is already bound to the sender base URL, so the request
/// posts to its root with `sendTransaction` as the JSON-RPC method. After
/// submission the transaction is polled against the standard RPC endpoint
/// ([rpcClient]) using an expiry derived from the blockhash and the current
/// chain height.
///
/// When the chain passes the computed expiry, one more status read is made
/// before giving up, so a transaction that landed in the last available block
/// is still reported as confirmed instead of expiring prematurely.
Future<String> txBroadcastTransaction(
  JsonRpcClient rpcClient,
  RestClient restClient,
  BroadcastTransactionRequest request, {
  BroadcastTransactionOptions options = const BroadcastTransactionOptions(),
}) async {
  if (options.lastValidBlockHeightOffset < 0) {
    throw ArgumentError.value(
      options.lastValidBlockHeightOffset,
      'lastValidBlockHeightOffset',
      'must be a positive number',
    );
  }

  final signature = await _submit(restClient, request, options);
  final expiry = await _expiry(rpcClient, options);
  await _pollUntilLanded(rpcClient, signature, expiry, options);

  return signature;
}

Future<String> _submit(
  RestClient restClient,
  BroadcastTransactionRequest request,
  BroadcastTransactionOptions options,
) async {
  final result = await restClient.post(
    '',
    body: {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'sendTransaction',
      'params': [
        request.transaction,
        {
          'encoding': 'base64',
          'skipPreflight': options.skipPreflight,
          'preflightCommitment': options.commitment.toJson(),
          'maxRetries': options.maxRetries,
        },
      ],
    },
  );

  return _readSenderSignature(result);
}

Future<int> _expiry(
  JsonRpcClient rpcClient,
  BroadcastTransactionOptions options,
) async {
  final blockhash = await rpcClient.call('getLatestBlockhash', [
    options.commitment.toJson(),
  ]);
  final blockhashValue =
      (blockhash! as Map<String, Object?>)['value']! as Map<String, Object?>;
  final lastValidBlockHeight = blockhashValue['lastValidBlockHeight']! as int;

  final chainHeight = await rpcClient.call('getBlockHeight');
  final height =
      (chainHeight! as num).toInt() + options.lastValidBlockHeightOffset;

  return lastValidBlockHeight < height ? lastValidBlockHeight : height;
}

Future<void> _pollUntilLanded(
  JsonRpcClient rpcClient,
  String signature,
  int expiry,
  BroadcastTransactionOptions options,
) async {
  final stopwatch = Stopwatch()..start();
  var expired = false;

  while (true) {
    if (!expired && stopwatch.elapsedMilliseconds > options.pollTimeoutMs) {
      throw SolanaError(
        SolanaErrorCode.heliusTransactionConfirmationTimeout,
        {'timeoutMs': options.pollTimeoutMs, 'signature': signature},
      );
    }

    final status = await _signatureStatus(rpcClient, signature);

    if (status != null) {
      final error = status['err'];

      if (error != null) throw getSolanaErrorFromTransactionError(error);

      final confirmationStatus = status['confirmationStatus'] as String?;

      if (confirmationStatus == 'confirmed' ||
          confirmationStatus == 'finalized') {
        return;
      }
    }

    // Give up only after a status read fresher than the expiry height read.
    if (expired) {
      throw StateError(
        'Block height exceeded lastValidBlockHeight, and the transaction '
        'failed to land on-chain',
      );
    }

    final blockHeight = await rpcClient.call('getBlockHeight');

    if ((blockHeight! as num).toInt() > expiry) {
      expired = true;
      continue;
    }

    await Future<void>.delayed(Duration(milliseconds: options.pollIntervalMs));
  }
}

Future<Map<String, Object?>?> _signatureStatus(
  JsonRpcClient rpcClient,
  String signature,
) async {
  final result = await rpcClient.call('getSignatureStatuses', [
    [signature],
    {'searchTransactionHistory': false},
  ]);
  final value = (result! as Map<String, Object?>)['value'] as List<Object?>?;

  if (value == null || value.isEmpty || value[0] == null) return null;

  return value[0]! as Map<String, Object?>;
}

String _readSenderSignature(Object? result) {
  if (result case final String signature) return signature;

  if (result case final Map<String, Object?> response) {
    final error = response['error'];

    if (error != null) throw Exception(error);

    if (response['result'] case final String signature) return signature;
  }

  throw Exception('Unexpected Sender response: $result');
}
