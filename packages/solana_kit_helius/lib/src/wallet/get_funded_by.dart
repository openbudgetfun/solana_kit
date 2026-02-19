import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius wallet funded-by endpoint.
///
/// Sends a GET request to
/// `/v0/addresses/{address}/funded-by?api-key={apiKey}`. Returns a
/// [FundedByResult] containing the funded-by transaction records.
Future<FundedByResult> walletGetFundedBy(
  RestClient restClient,
  String apiKey,
  GetFundedByRequest request,
) async {
  final result = await restClient.get(
    '/v0/addresses/${request.address}/funded-by?api-key=$apiKey',
  );
  return FundedByResult.fromJson(result! as Map<String, Object?>);
}
