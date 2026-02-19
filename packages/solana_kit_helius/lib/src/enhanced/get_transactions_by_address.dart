import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';

/// Calls the Helius enhanced transactions-by-address endpoint.
///
/// Sends a GET request to `/v0/addresses/{address}/transactions?api-key={apiKey}`
/// with optional query parameters for pagination and filtering (`before`,
/// `until`, `commitment`, `type`). Returns a list of [EnhancedTransaction]
/// objects with parsed metadata.
Future<List<EnhancedTransaction>> enhancedGetTransactionsByAddress(
  RestClient restClient,
  String apiKey,
  GetTransactionsByAddressRequest request,
) async {
  final queryParams = <String, String>{};
  if (request.before != null) {
    queryParams['before'] = request.before!;
  }
  if (request.until != null) {
    queryParams['until'] = request.until!;
  }
  if (request.commitment != null) {
    queryParams['commitment'] = request.commitment!.toJson();
  }
  if (request.type != null) {
    queryParams['type'] = request.type!;
  }

  final result = await restClient.get(
    '/v0/addresses/${request.address}/transactions?api-key=$apiKey',
    queryParameters: queryParams.isNotEmpty ? queryParams : null,
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(EnhancedTransaction.fromJson)
      .toList();
}
