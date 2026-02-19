import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Gets all Helius-managed stake accounts for the given owner.
///
/// Sends a GET request to `/v0/staking/accounts/{owner}` and returns
/// a list of [StakeAccountInfo] objects.
Future<List<StakeAccountInfo>> stakingGetHeliusStakeAccounts(
  RestClient restClient,
  String apiKey,
  GetHeliusStakeAccountsRequest request,
) async {
  final result = await restClient.get(
    '/v0/staking/accounts/${request.owner}?api-key=$apiKey',
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(StakeAccountInfo.fromJson)
      .toList();
}
