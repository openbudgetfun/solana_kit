import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/transactions/sender.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// A signed transaction accepted by the Sender bundle helper.
typedef SignedBundleTransaction = Transaction;

/// Options for [sendBundleWithSender].
class SendBundleOptions {
  /// Creates send-bundle options.
  const SendBundleOptions({
    this.region,
    this.pollTimeoutMs,
    this.pollIntervalMs,
  });

  /// Sender region to route through. Defaults to `SenderRegion.defaultRegion`.
  final SenderRegion? region;

  /// Overall polling timeout in milliseconds. Defaults to 60 seconds.
  final int? pollTimeoutMs;

  /// Polling cadence in milliseconds. Defaults to 2 seconds.
  final int? pollIntervalMs;
}

const _defaultTimeoutMs = 60000;
const _defaultPollMs = 2000;
const _maxBundleSize = 5;

/// Submits a **bundle** of up to 5 transactions to Sender Max via
/// `sendBundle`.
///
/// Sender Max handles single transactions and bundles over the same paths and
/// priority auction. The caller only needs to include the **0.001 SOL Sender
/// tip** in at least one transaction of the bundle — Helius adds any pathway
/// tips on your behalf. Do **not** add a separate pathway-specific tip or set
/// a pathway-region header.
///
/// Bundles are submitted to the Sender endpoint
/// (`https://sender.helius-rpc.com/fast` and regional hosts) with
/// `method: "sendBundle"` and `params: [[base64Tx, ...], { encoding: "base64" }]`.
///
/// Landing is tracked via each transaction's **signature**
/// (`getSignatureStatuses`), not bundle IDs / `getBundleStatuses`.
///
/// Returns the signatures of every transaction in the bundle, in submission
/// order.
Future<List<String>> sendBundleWithSender(
  http.Client httpClient,
  JsonRpcClient rpcClient,
  List<SignedBundleTransaction> transactions, {
  SendBundleOptions options = const SendBundleOptions(),
}) async {
  final region = options.region ?? SenderRegion.defaultRegion;
  final pollTimeoutMs = options.pollTimeoutMs ?? _defaultTimeoutMs;
  final pollIntervalMs = options.pollIntervalMs ?? _defaultPollMs;

  if (transactions.isEmpty) {
    throw ArgumentError('Bundle must contain at least one transaction');
  }
  if (transactions.length > _maxBundleSize) {
    throw ArgumentError(
      'Bundle supports at most $_maxBundleSize transactions, got '
      '${transactions.length}',
    );
  }

  final encoded = transactions
      .map(getBase64EncodedWireTransaction)
      .toList(growable: false);
  final signatures = transactions
      .map(getSignatureFromTransaction)
      .map((sig) => sig.toString())
      .toList(growable: false);

  // Bundles always go through Sender Max — no `?swqos_only=true`.
  final response = await httpClient.post(
    Uri.parse(senderFastUrl(region)),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(<String, Object?>{
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'method': 'sendBundle',
      'params': [
        encoded,
        {'encoding': 'base64'},
      ],
    }),
  );

  if (response.statusCode != 200) {
    throw StateError(
      'Sender bundle HTTP ${response.statusCode}: '
      '${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
    );
  }

  final body = jsonDecode(response.body);
  if (body is Map<String, Object?> && body['error'] != null) {
    throw StateError('Sender bundle error: ${body['error']}');
  }
  // The result (bundle id, etc.) is intentionally ignored — landing is
  // tracked by transaction signature, not bundle id.

  // Track landing via each transaction's signature.
  for (final signature in signatures) {
    await _pollSignature(
      rpcClient,
      signature,
      timeoutMs: pollTimeoutMs,
      intervalMs: pollIntervalMs,
    );
  }

  return signatures;
}

Future<void> _pollSignature(
  JsonRpcClient rpcClient,
  String signature, {
  required int timeoutMs,
  required int intervalMs,
}) async {
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsedMilliseconds < timeoutMs) {
    final result = await rpcClient.call('getSignatureStatuses', [
      [signature],
      {'searchTransactionHistory': true},
    ]);
    final response = result as Map<String, Object?>?;
    if (response != null) {
      final value = response['value'] as List<Object?>?;
      if (value != null && value.isNotEmpty && value[0] != null) {
        final status = value[0]! as Map<String, Object?>;
        final confirmationStatus = status['confirmationStatus'] as String?;
        if (confirmationStatus == 'confirmed' ||
            confirmationStatus == 'finalized') {
          return;
        }
      }
    }
    await Future<void>.delayed(Duration(milliseconds: intervalMs));
  }

  throw SolanaError(SolanaErrorCode.heliusTransactionConfirmationTimeout, {
    'signature': signature,
    'timeoutMs': timeoutMs,
  });
}
