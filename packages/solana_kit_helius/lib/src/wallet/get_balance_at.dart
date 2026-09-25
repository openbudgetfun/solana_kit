import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius wallet balance-at endpoint.
///
/// Sends a GET request to `/v0/addresses/{wallet}/balance-at?api-key={apiKey}`
/// with the mint and exactly one of `time`, `datetime`, or `slot` as query
/// parameters. Returns the wallet's balance of the token at the requested
/// point in the past.
///
/// Each request costs 100 credits.
Future<GetBalanceAtResponse> walletGetBalanceAt(
  RestClient restClient,
  String apiKey,
  GetBalanceAtRequest request,
) async {
  final query = <String, Object?>{
    'api-key': apiKey,
    'mint': request.mint,
    if (request.time != null) 'time': request.time,
    if (request.datetime != null) 'datetime': request.datetime,
    if (request.slot != null) 'slot': request.slot,
  };
  final queryString = query.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent('${e.value}')}')
      .join('&');
  final result = await restClient.get(
    '/v0/addresses/${request.wallet}/balance-at?$queryString',
  );
  return GetBalanceAtResponse.fromJson(result! as Map<String, Object?>);
}
