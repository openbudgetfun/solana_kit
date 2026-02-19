import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/transactions/broadcast_transaction.dart';
import 'package:solana_kit_helius/src/transactions/create_smart_transaction.dart';
import 'package:solana_kit_helius/src/transactions/get_compute_units.dart';
import 'package:solana_kit_helius/src/transactions/poll_transaction_confirmation.dart';
import 'package:solana_kit_helius/src/transactions/send_smart_transaction.dart';
import 'package:solana_kit_helius/src/transactions/send_transaction_with_sender.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Client for Helius smart transaction operations.
///
/// Provides methods for creating, sending, broadcasting, and polling
/// smart transactions through Helius infrastructure.
class TransactionsClient {
  /// Creates a [TransactionsClient] with the given [rpcClient], [restClient],
  /// and [senderUrl] for SWQOS-based transaction sending.
  const TransactionsClient({
    required JsonRpcClient rpcClient,
    required RestClient restClient,
    required String senderUrl,
  }) : _rpcClient = rpcClient,
       _restClient = restClient,
       _senderUrl = senderUrl;

  final JsonRpcClient _rpcClient;
  final RestClient _restClient;
  final String _senderUrl;

  /// Simulates the transaction to estimate compute units consumed.
  Future<ComputeUnitsEstimate> getComputeUnits(
    CreateSmartTransactionInput input,
  ) => txGetComputeUnits(_rpcClient, input);

  /// Polls `getSignatureStatuses` in a loop until the transaction is confirmed
  /// or the timeout is reached.
  Future<SmartTransactionResult> pollTransactionConfirmation(
    PollTransactionConfirmationRequest request,
  ) => txPollTransactionConfirmation(_rpcClient, request);

  /// Broadcasts a base64-encoded transaction to the sender URL.
  Future<String> broadcastTransaction(BroadcastTransactionRequest request) =>
      txBroadcastTransaction(_restClient, _senderUrl, request);

  /// Builds a smart transaction by fetching a recent blockhash and preparing
  /// the transaction for signing.
  Future<String> createSmartTransaction(CreateSmartTransactionInput input) =>
      txCreateSmartTransaction(_rpcClient, input);

  /// Orchestrates creating, broadcasting, and polling a smart transaction.
  Future<SmartTransactionResult> sendSmartTransaction(
    SendSmartTransactionInput input,
  ) => txSendSmartTransaction(_rpcClient, _restClient, _senderUrl, input);

  /// Sends a transaction via the Helius sender (SWQOS).
  Future<String> sendTransactionWithSender(
    BroadcastTransactionRequest request,
  ) => txSendTransactionWithSender(_restClient, _senderUrl, request);
}
