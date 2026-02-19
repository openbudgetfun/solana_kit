import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/transactions/poll_transaction_confirmation.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Orchestrates sending a smart transaction: submits the transaction via
/// `sendTransaction` RPC and then polls for confirmation.
Future<SmartTransactionResult> txSendSmartTransaction(
  JsonRpcClient rpcClient,
  RestClient restClient,
  String senderUrl,
  SendSmartTransactionInput input,
) async {
  // Send via RPC sendTransaction
  final result = await rpcClient.call('sendTransaction', [
    input.instructions,
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
