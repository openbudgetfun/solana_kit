import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns the latest non-voting signatures.
Future<CompressedSignatureList> zkGetLatestNonVotingSignatures(
  JsonRpcClient rpcClient,
  GetLatestNonVotingSignaturesRequest request,
) async {
  final result = await rpcClient.call(
    'getLatestNonVotingSignatures',
    request.toJson(),
  );
  return CompressedSignatureList.fromJson(result! as Map<String, Object?>);
}
