import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Sends a transaction via the Helius sender (SWQOS) by posting a
/// `sendTransaction` JSON-RPC request with base64 encoding.
Future<String> txSendTransactionWithSender(
  RestClient restClient,
  String senderUrl,
  BroadcastTransactionRequest request,
) async {
  final result = await restClient.post(
    '',
    body: {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'sendTransaction',
      'params': [
        request.transaction,
        {'encoding': 'base64'},
      ],
    },
  );
  final response = result! as Map<String, Object?>;
  return response['result']! as String;
}
