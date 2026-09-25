import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Gets the withdrawable amount from a stake account.
///
/// Sends a GET request to `/v0/staking/withdrawable/{stakeAccount}` and
/// returns the [WithdrawableAmount].
Future<WithdrawableAmount> stakingGetWithdrawableAmount(
  RestClient restClient,
  String apiKey,
  GetWithdrawableAmountRequest request,
) async {
  final result = await restClient.get(
    '/v0/staking/withdrawable/${request.stakeAccount}?api-key=$apiKey',
  );
  return WithdrawableAmount.fromJson(result! as Map<String, Object?>);
}
