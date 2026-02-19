import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/staking/create_stake_transaction.dart';
import 'package:solana_kit_helius/src/staking/create_unstake_transaction.dart';
import 'package:solana_kit_helius/src/staking/create_withdraw_transaction.dart';
import 'package:solana_kit_helius/src/staking/get_helius_stake_accounts.dart';
import 'package:solana_kit_helius/src/staking/get_withdrawable_amount.dart';
import 'package:solana_kit_helius/src/staking/stake_instructions.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Client for Helius staking operations.
///
/// Provides methods for creating stake, unstake, and withdraw transactions,
/// as well as querying stake accounts and withdrawable amounts through the
/// Helius REST API.
class StakingClient {
  /// Creates a [StakingClient] with the given [restClient] and [apiKey].
  const StakingClient({required RestClient restClient, required String apiKey})
    : _restClient = restClient,
      _apiKey = apiKey;

  final RestClient _restClient;
  final String _apiKey;

  /// Creates a stake transaction via the Helius staking API.
  Future<StakeTransactionResult> createStakeTransaction(
    CreateStakeTransactionRequest request,
  ) => stakingCreateStakeTransaction(_restClient, _apiKey, request);

  /// Creates an unstake transaction via the Helius staking API.
  Future<StakeTransactionResult> createUnstakeTransaction(
    CreateUnstakeTransactionRequest request,
  ) => stakingCreateUnstakeTransaction(_restClient, _apiKey, request);

  /// Creates a withdraw transaction via the Helius staking API.
  Future<StakeTransactionResult> createWithdrawTransaction(
    CreateWithdrawTransactionRequest request,
  ) => stakingCreateWithdrawTransaction(_restClient, _apiKey, request);

  /// Gets all Helius-managed stake accounts for the given owner.
  Future<List<StakeAccountInfo>> getHeliusStakeAccounts(
    GetHeliusStakeAccountsRequest request,
  ) => stakingGetHeliusStakeAccounts(_restClient, _apiKey, request);

  /// Gets the withdrawable amount from a stake account.
  Future<WithdrawableAmount> getWithdrawableAmount(
    GetWithdrawableAmountRequest request,
  ) => stakingGetWithdrawableAmount(_restClient, _apiKey, request);

  /// Gets raw stake instructions for building custom transactions.
  Future<Map<String, Object?>> getStakeInstructions(
    CreateStakeTransactionRequest request,
  ) => stakingGetStakeInstructions(_restClient, _apiKey, request);
}
