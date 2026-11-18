import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Calls the `getHistoricalTokenAccountsByOwner` JSON-RPC method.
///
/// Returns one page of the SPL Token and Token-2022 accounts [request] reads
/// at the requested historical position, with a cursor for the next page.
/// Pin the query's slot across pages so every page reads the same state, and
/// stop only when the cursor is null: a short or empty page can still have
/// more behind it, since each call scans at most 25,000 accounts.
///
/// Beta: mainnet only, Business plans and above, from slot 444959999 onward
/// (earlier slots fail with a Helius RPC error).
Future<GetHistoricalTokenAccountsByOwnerResponse>
rpcV2GetHistoricalTokenAccountsByOwner(
  JsonRpcClient rpcClient,
  GetHistoricalTokenAccountsByOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getHistoricalTokenAccountsByOwner',
    request.toJson(),
  );
  return GetHistoricalTokenAccountsByOwnerResponse.fromJson(
    result! as Map<String, Object?>,
  );
}
