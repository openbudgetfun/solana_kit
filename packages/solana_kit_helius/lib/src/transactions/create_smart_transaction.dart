import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Builds a smart transaction by fetching a recent blockhash.
///
/// In a full implementation this would: get recent blockhash, estimate compute
/// units, get priority fees, build and sign the transaction. For now, it
/// returns the latest blockhash as a placeholder.
Future<String> txCreateSmartTransaction(
  JsonRpcClient rpcClient,
  CreateSmartTransactionInput input,
) async {
  final result = await rpcClient.call('getLatestBlockhash');
  final blockhash =
      (result! as Map<String, Object?>)['value']! as Map<String, Object?>;
  return blockhash['blockhash']! as String;
}
