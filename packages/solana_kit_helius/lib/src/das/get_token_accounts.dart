import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getTokenAccounts` DAS API method.
///
/// Returns a paginated list of token accounts matching the given criteria.
Future<TokenAccountList> dasGetTokenAccounts(
  JsonRpcClient rpcClient,
  GetTokenAccountsRequest request,
) async {
  final result = await rpcClient.call('getTokenAccounts', request.toJson());
  return TokenAccountList.fromJson(result! as Map<String, Object?>);
}
