import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns a compressed account by its address.
///
/// The response's [GetCompressedAccountResponse.value] is null when no
/// account matches (upstream v4.0.0 #397); absence is not an error.
Future<GetCompressedAccountResponse> zkGetCompressedAccount(
  JsonRpcClient rpcClient,
  GetCompressedAccountRequest request,
) async {
  final result = await rpcClient.call('getCompressedAccount', request.toJson());

  return GetCompressedAccountResponse.fromJson(result! as Map<String, Object?>);
}
