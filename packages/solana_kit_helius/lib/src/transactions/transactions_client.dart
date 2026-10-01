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
  /// Creates a [TransactionsClient] with the given [_rpcClient] for standard
  /// RPC calls and [_restClient], which is bound to the Helius Sender base URL
  /// for SWQOS-based transaction submission.
  const TransactionsClient({
    required this._rpcClient,
    required this._restClient,
  });

  final JsonRpcClient _rpcClient;
  final RestClient _restClient;

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
      txBroadcastTransaction(_restClient, request);

  /// Builds a smart transaction by estimating its compute units and priority
  /// fee, then refreshing the blockhash it should be built against.
  Future<SmartTransaction> createSmartTransaction(
    CreateSmartTransactionInput input,
  ) => txCreateSmartTransaction(_rpcClient, input);

  /// Orchestrates creating, broadcasting, and polling a smart transaction.
  Future<SmartTransactionResult> sendSmartTransaction(
    SendSmartTransactionInput input,
  ) => txSendSmartTransaction(_rpcClient, input);

  /// Sends a transaction via the Helius sender (SWQOS).
  Future<String> sendTransactionWithSender(
    BroadcastTransactionRequest request,
  ) => txSendTransactionWithSender(_restClient, request);
}
