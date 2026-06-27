import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<TransactionWithCompressionInfo> zkGetTransactionWithCompressionInfo(
  JsonRpcClient rpcClient,
  GetTransactionWithCompressionInfoRequest request,
) async {
  final result = await rpcClient.call(
    'getTransactionWithCompressionInfo',
    request.toJson(),
  );
  return TransactionWithCompressionInfo.fromJson(
    result! as Map<String, Object?>,
  );
}
