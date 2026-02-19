import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/rpc_v2/get_token_accounts_by_owner_v2.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Auto-paginator that fetches all token accounts owned by the address
/// specified in [request].
///
/// Repeatedly calls `getTokenAccountsByOwnerV2` with the cursor from each
/// response until all pages have been consumed, then returns the complete
/// list of [TokenAccountV2] items.
Future<List<TokenAccountV2>> rpcV2GetAllTokenAccountsByOwner(
  JsonRpcClient rpcClient,
  GetTokenAccountsByOwnerV2Request request,
) async {
  final allAccounts = <TokenAccountV2>[];
  var cursor = request.after;

  while (true) {
    final pageRequest = GetTokenAccountsByOwnerV2Request(
      ownerAddress: request.ownerAddress,
      mint: request.mint,
      programId: request.programId,
      encoding: request.encoding,
      after: cursor,
      limit: request.limit,
    );
    final response = await rpcV2GetTokenAccountsByOwnerV2(
      rpcClient,
      pageRequest,
    );
    allAccounts.addAll(response.accounts);

    if (response.cursor == null || response.accounts.isEmpty) break;
    cursor = response.cursor;
  }

  return allAccounts;
}
