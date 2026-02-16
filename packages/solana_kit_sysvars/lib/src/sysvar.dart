import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// The address of the Clock sysvar.
const Address sysvarClockAddress = Address(
  'SysvarC1ock11111111111111111111111111111111',
);

/// The address of the EpochRewards sysvar.
const Address sysvarEpochRewardsAddress = Address(
  'SysvarEpochRewards1111111111111111111111111',
);

/// The address of the EpochSchedule sysvar.
const Address sysvarEpochScheduleAddress = Address(
  'SysvarEpochSchedu1e111111111111111111111111',
);

/// The address of the Instructions sysvar.
const Address sysvarInstructionsAddress = Address(
  'Sysvar1nstructions1111111111111111111111111',
);

/// The address of the LastRestartSlot sysvar.
const Address sysvarLastRestartSlotAddress = Address(
  'SysvarLastRestartS1ot1111111111111111111111',
);

/// The address of the RecentBlockhashes sysvar.
const Address sysvarRecentBlockhashesAddress = Address(
  'SysvarRecentB1ockHashes11111111111111111111',
);

/// The address of the Rent sysvar.
const Address sysvarRentAddress = Address(
  'SysvarRent111111111111111111111111111111111',
);

/// The address of the SlotHashes sysvar.
const Address sysvarSlotHashesAddress = Address(
  'SysvarS1otHashes111111111111111111111111111',
);

/// The address of the SlotHistory sysvar.
const Address sysvarSlotHistoryAddress = Address(
  'SysvarS1otHistory11111111111111111111111111',
);

/// The address of the StakeHistory sysvar.
const Address sysvarStakeHistoryAddress = Address(
  'SysvarStakeHistory1111111111111111111111111',
);

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
