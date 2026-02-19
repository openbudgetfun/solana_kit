import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';
import 'package:solana_kit_helius/src/wallet/get_balances.dart';
import 'package:solana_kit_helius/src/wallet/get_batch_identity.dart';
import 'package:solana_kit_helius/src/wallet/get_funded_by.dart';
import 'package:solana_kit_helius/src/wallet/get_history.dart';
import 'package:solana_kit_helius/src/wallet/get_identity.dart';
import 'package:solana_kit_helius/src/wallet/get_transfers.dart';

/// Client for Helius Wallet API methods.
class WalletClient {
  const WalletClient({required RestClient restClient, required String apiKey})
    : _restClient = restClient,
      _apiKey = apiKey;

  final RestClient _restClient;
  final String _apiKey;

  /// Returns identity information for the given wallet address.
  Future<Identity> getIdentity(GetIdentityRequest request) =>
      walletGetIdentity(_restClient, _apiKey, request);

  /// Returns identity information for multiple wallet addresses.
  Future<Map<String, Identity>> getBatchIdentity(
    GetBatchIdentityRequest request,
  ) => walletGetBatchIdentity(_restClient, _apiKey, request);

  /// Returns native SOL and token balances for the given wallet address.
  Future<WalletBalances> getBalances(GetBalancesRequest request) =>
      walletGetBalances(_restClient, _apiKey, request);

  /// Returns enhanced transaction history for the given wallet address.
  Future<List<EnhancedTransaction>> getHistory(GetHistoryRequest request) =>
      walletGetHistory(_restClient, _apiKey, request);

  /// Returns transfer records for the given wallet address.
  Future<List<WalletTransfer>> getTransfers(GetTransfersRequest request) =>
      walletGetTransfers(_restClient, _apiKey, request);

  /// Returns funded-by information for the given wallet address.
  Future<FundedByResult> getFundedBy(GetFundedByRequest request) =>
      walletGetFundedBy(_restClient, _apiKey, request);
}
