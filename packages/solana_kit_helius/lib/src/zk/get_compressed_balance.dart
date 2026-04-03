// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedBalance> zkGetCompressedBalance(
  JsonRpcClient rpcClient,
  GetCompressedBalanceRequest request,
) async {
  final result = await rpcClient.call('getCompressedBalance', request.toJson());
  return CompressedBalance.fromJson(result! as Map<String, Object?>);
}
