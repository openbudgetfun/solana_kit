import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show
        sysvarClockAddress,
        sysvarEpochRewardsAddress,
        sysvarEpochScheduleAddress,
        sysvarFeesAddress,
        sysvarInstructionsAddress,
        sysvarLastRestartSlotAddress,
        sysvarOwnerAddress,
        sysvarRecentBlockhashesAddress,
        sysvarRentAddress,
        sysvarRewardsAddress,
        sysvarSlotHashesAddress,
        sysvarSlotHistoryAddress,
        sysvarStakeHistoryAddress;

/// Backward-compatible alias for [sysvarRecentBlockhashesAddress].
const recentBlockhashesSysvarAddress = sysvarRecentBlockhashesAddress;

/// Fetches an encoded sysvar account.
///
/// Sysvars are special accounts that contain dynamically-updated data about
/// the network cluster, the blockchain history, and the executing transaction.
Future<MaybeEncodedAccount> fetchEncodedSysvarAccount(
  Rpc rpc,
  Address address, {
  FetchAccountConfig? config,
}) {
  return fetchEncodedAccount(rpc, address, config: config);
}
