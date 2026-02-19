import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius wallet transaction history endpoint.
///
/// Sends a GET request to
/// `/v0/addresses/{address}/transactions?api-key={apiKey}` with optional
/// query parameters for pagination and filtering. Returns a list of
/// [EnhancedTransaction] objects.
Future<List<EnhancedTransaction>> walletGetHistory(
  RestClient restClient,
  String apiKey,
  GetHistoryRequest request,
) async {
  final queryParams = <String, String>{};
  if (request.before != null) queryParams['before'] = request.before!;
  if (request.until != null) queryParams['until'] = request.until!;
  if (request.limit != null) {
    queryParams['limit'] = request.limit.toString();
  }
  if (request.type != null) queryParams['type'] = request.type!;

  final path = '/v0/addresses/${request.address}/transactions?api-key=$apiKey';
  final result = await restClient.get(
    path,
    queryParameters: queryParams.isNotEmpty ? queryParams : null,
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(EnhancedTransaction.fromJson)
      .toList();
}
