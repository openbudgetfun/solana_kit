import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius wallet transfers endpoint.
///
/// Sends a GET request to
/// `/v0/addresses/{address}/transfers?api-key={apiKey}` with optional
/// query parameters for pagination. Returns a list of [WalletTransfer]
/// records.
Future<List<WalletTransfer>> walletGetTransfers(
  RestClient restClient,
  String apiKey,
  GetTransfersRequest request,
) async {
  final queryParams = <String, String>{};
  if (request.before != null) queryParams['before'] = request.before!;
  if (request.until != null) queryParams['until'] = request.until!;
  if (request.limit != null) {
    queryParams['limit'] = request.limit.toString();
  }

  final path = '/v0/addresses/${request.address}/transfers?api-key=$apiKey';
  final result = await restClient.get(
    path,
    queryParameters: queryParams.isNotEmpty ? queryParams : null,
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(WalletTransfer.fromJson)
      .toList();
}
