import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Broadcasts a base64-encoded transaction to the Helius sender.
///
/// The [restClient] is already bound to the sender base URL, so the request
/// posts to its root with `sendTransaction` as the JSON-RPC method.
Future<String> txBroadcastTransaction(
  RestClient restClient,
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
        {'encoding': 'base64', 'skipPreflight': true, 'maxRetries': 0},
      ],
    },
  );
  return _readSenderSignature(result);
}

String _readSenderSignature(Object? result) {
  if (result case final String signature) return signature;

  if (result case final Map<String, Object?> response) {
    final error = response['error'];

    if (error != null) throw Exception(error);

    if (response['result'] case final String signature) return signature;
  }

  throw Exception('Unexpected Sender response: $result');
}
