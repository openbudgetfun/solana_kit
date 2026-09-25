import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius wallet balances endpoint.
///
/// Sends a GET request to `/v0/addresses/{address}/balances?api-key={apiKey}`.
/// Returns the [WalletBalances] containing native SOL and token balances.
Future<WalletBalances> walletGetBalances(
  RestClient restClient,
  String apiKey,
  GetBalancesRequest request,
) async {
  final result = await restClient.get(
    '/v0/addresses/${request.address}/balances?api-key=$apiKey',
  );
  return WalletBalances.fromJson(result! as Map<String, Object?>);
}
