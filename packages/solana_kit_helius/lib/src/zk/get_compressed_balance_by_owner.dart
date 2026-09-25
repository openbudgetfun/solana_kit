import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns the compressed balance for the given owner address.
Future<CompressedBalance> zkGetCompressedBalanceByOwner(
  JsonRpcClient rpcClient,
  GetCompressedBalanceByOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedBalanceByOwner',
    request.toJson(),
  );
  return CompressedBalance.fromJson(result! as Map<String, Object?>);
}
