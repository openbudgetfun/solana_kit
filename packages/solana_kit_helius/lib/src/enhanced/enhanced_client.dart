import 'package:solana_kit_helius/src/enhanced/get_transactions.dart';
import 'package:solana_kit_helius/src/enhanced/get_transactions_by_address.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';

/// Client for Helius Enhanced Transactions API methods.
class EnhancedClient {
  const EnhancedClient({required RestClient restClient, required String apiKey})
    : _restClient = restClient,
      _apiKey = apiKey;

  final RestClient _restClient;
  final String _apiKey;

  /// Returns parsed enhanced transaction data for the given transaction
  /// signatures.
  Future<List<EnhancedTransaction>> getTransactions(
    GetTransactionsRequest request,
  ) => enhancedGetTransactions(_restClient, _apiKey, request);

  /// Returns parsed enhanced transaction data for a given address, with
  /// optional pagination and filtering.
  Future<List<EnhancedTransaction>> getTransactionsByAddress(
    GetTransactionsByAddressRequest request,
  ) => enhancedGetTransactionsByAddress(_restClient, _apiKey, request);
}
