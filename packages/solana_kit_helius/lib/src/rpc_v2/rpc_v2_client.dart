import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_all_program_accounts.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_all_token_accounts_by_owner.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_program_accounts_v2.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_token_accounts_by_owner_v2.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_transactions_for_address.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Client for Helius RPC V2 API methods with cursor-based pagination.
class RpcV2Client {
  const RpcV2Client({required JsonRpcClient rpcClient})
    : _rpcClient = rpcClient;

  final JsonRpcClient _rpcClient;

  /// Returns a single page of program accounts matching the given filters.
  Future<GetProgramAccountsV2Response> getProgramAccountsV2(
    GetProgramAccountsV2Request request,
  ) => rpcV2GetProgramAccountsV2(_rpcClient, request);

  /// Returns all program accounts matching the given filters by
  /// automatically paginating through every page.
  Future<List<ProgramAccountV2>> getAllProgramAccounts(
    GetProgramAccountsV2Request request,
  ) => rpcV2GetAllProgramAccounts(_rpcClient, request);

  /// Returns a single page of token accounts owned by the given address.
  Future<GetTokenAccountsByOwnerV2Response> getTokenAccountsByOwnerV2(
    GetTokenAccountsByOwnerV2Request request,
  ) => rpcV2GetTokenAccountsByOwnerV2(_rpcClient, request);

  /// Returns all token accounts owned by the given address by automatically
  /// paginating through every page.
  Future<List<TokenAccountV2>> getAllTokenAccountsByOwner(
    GetTokenAccountsByOwnerV2Request request,
  ) => rpcV2GetAllTokenAccountsByOwner(_rpcClient, request);

  /// Returns transactions associated with the given address.
  Future<GetTransactionsForAddressResponse> getTransactionsForAddress(
    GetTransactionsForAddressRequest request,
  ) => rpcV2GetTransactionsForAddress(_rpcClient, request);
}
