import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns compressed token balances (V2) for the given owner address.
Future<CompressedTokenBalanceV2List> zkGetCompressedTokenBalancesByOwnerV2(
  JsonRpcClient rpcClient,
  GetCompressedTokenBalancesByOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedTokenBalancesByOwnerV2',
    request.toJson(),
  );
  return CompressedTokenBalanceV2List.fromJson(result! as Map<String, Object?>);
}
