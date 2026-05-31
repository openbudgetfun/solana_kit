// ignore_for_file: public_member_api_docs

import 'package:solana_kit_address/solana_kit_address.dart';

// ---------------------------------------------------------------------------
// Sysvar addresses
// ---------------------------------------------------------------------------
// Sourced from the solana-sdk-ids crate (https://docs.rs/crate/solana-sdk-ids)
// and the official Solana documentation.
//
// The sysvar fetch helpers and codecs live in `package:solana_kit_sysvars`.
// These address constants are provided here so that any package can reference
// a sysvar address without importing the full sysvar domain package.

/// The owner address for all sysvar accounts.
const sysvarOwnerAddress = Address(
  'Sysvar1111111111111111111111111111111111111',
);

/// The address of the Clock sysvar.
const sysvarClockAddress = Address(
  'SysvarC1ock11111111111111111111111111111111',
);

/// The address of the EpochRewards sysvar.
const sysvarEpochRewardsAddress = Address(
  'SysvarEpochRewards1111111111111111111111111',
);

/// The address of the EpochSchedule sysvar.
const sysvarEpochScheduleAddress = Address(
  'SysvarEpochSchedu1e111111111111111111111111',
);

/// The address of the Fees sysvar.
const sysvarFeesAddress = Address(
  'SysvarFees111111111111111111111111111111111',
);

/// The address of the Instructions sysvar.
const sysvarInstructionsAddress = Address(
  'Sysvar1nstructions1111111111111111111111111',
);

/// The address of the LastRestartSlot sysvar.
const sysvarLastRestartSlotAddress = Address(
  'SysvarLastRestartS1ot1111111111111111111111',
);

/// The address of the RecentBlockhashes sysvar.
const sysvarRecentBlockhashesAddress = Address(
  'SysvarRecentB1ockHashes11111111111111111111',
);

/// The address of the Rent sysvar.
const sysvarRentAddress = Address(
  'SysvarRent111111111111111111111111111111111',
);

/// The address of the Rewards sysvar.
const sysvarRewardsAddress = Address(
  'SysvarRewards111111111111111111111111111111',
);

/// The address of the SlotHashes sysvar.
const sysvarSlotHashesAddress = Address(
  'SysvarS1otHashes111111111111111111111111111',
);

/// The address of the SlotHistory sysvar.
const sysvarSlotHistoryAddress = Address(
  'SysvarS1otHistory11111111111111111111111111',
);

/// The address of the StakeHistory sysvar.
const sysvarStakeHistoryAddress = Address(
  'SysvarStakeHistory1111111111111111111111111',
);