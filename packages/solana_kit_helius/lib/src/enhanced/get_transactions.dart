import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';

/// Calls the Helius enhanced transactions endpoint.
///
/// Sends a POST request to `/v0/transactions?api-key={apiKey}` with the
/// transaction signatures in the request body. Returns a list of
/// [EnhancedTransaction] objects with parsed metadata.
Future<List<EnhancedTransaction>> enhancedGetTransactions(
  RestClient restClient,
  String apiKey,
  GetTransactionsRequest request,
) async {
  final result = await restClient.post(
    '/v0/transactions?api-key=$apiKey',
    body: request.toJson(),
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(EnhancedTransaction.fromJson)
      .toList();
}
