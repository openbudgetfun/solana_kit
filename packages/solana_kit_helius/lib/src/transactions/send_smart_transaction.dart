import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/transactions/poll_transaction_confirmation.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Orchestrates sending a smart transaction: submits the serialized
/// transaction through the standard RPC endpoint and then polls for
/// confirmation.
///
/// Matches upstream's `makeSendSmartTransaction`, which sends through the RPC
/// client rather than the Helius sender. Use `sendTransactionWithSender` when
/// the SWQOS path is wanted instead.
///
/// `sendTransaction` takes a base64-encoded wire transaction, so
/// [SendSmartTransactionInput.instructions] is expected to carry exactly one
/// such string.
Future<SmartTransactionResult> txSendSmartTransaction(
  JsonRpcClient rpcClient,
  SendSmartTransactionInput input,
) async {
  final serialized = _serializedTransaction(input.instructions);

  final result = await rpcClient.call('sendTransaction', [
    serialized,
    {
      if (input.skipPreflight != null) 'skipPreflight': input.skipPreflight,
      if (input.maxRetries != null) 'maxRetries': input.maxRetries,
    },
  ]);
  final signature = result! as String;

  return txPollTransactionConfirmation(
    rpcClient,
    PollTransactionConfirmationRequest(signature: signature),
  );
}

/// Returns the serialized transaction to submit.
///
/// A smart transaction is submitted as a single base64 wire transaction, so
/// [entries] is expected to hold exactly one [String]. `sendTransaction`
/// rejects a non-string first parameter, so anything else is reported here
/// rather than sent.
String _serializedTransaction(List<Object?> entries) {
  for (final entry in entries) {
    if (entry is String) return entry;
  }

  throw StateError(
    'sendSmartTransaction: expected a base64-encoded transaction to submit, '
    'but none of the ${entries.length} entries was a String.',
  );
}
