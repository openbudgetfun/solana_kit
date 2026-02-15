import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parsed account data for a sysvar account.
///
/// This is a discriminated union covering all sysvar account types:
/// - [JsonParsedClockSysvar] ('clock')
/// - [JsonParsedEpochRewardsSysvar] ('epochRewards')
/// - [JsonParsedEpochScheduleSysvar] ('epochSchedule')
/// - [JsonParsedFeesSysvar] ('fees') - deprecated
/// - [JsonParsedLastRestartSlotSysvar] ('lastRestartSlot')
/// - [JsonParsedRecentBlockhashesSysvar] ('recentBlockhashes') - deprecated
/// - [JsonParsedRentSysvar] ('rent')
/// - [JsonParsedSlotHashesSysvar] ('slotHashes')
/// - [JsonParsedSlotHistorySysvar] ('slotHistory')
/// - [JsonParsedStakeHistorySysvar] ('stakeHistory')
sealed class JsonParsedSysvarAccount {
  const JsonParsedSysvarAccount();
}

// ---------------------------------------------------------------------------
// Clock
// ---------------------------------------------------------------------------

/// A parsed sysvar 'clock' variant.
class JsonParsedClockSysvar extends RpcParsedType<String, JsonParsedClockInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedClockSysvar].
  const JsonParsedClockSysvar({required super.info}) : super(type: 'clock');
}

/// The info payload for the clock sysvar.
class JsonParsedClockInfo {
  /// Creates a new [JsonParsedClockInfo].
  const JsonParsedClockInfo({
    required this.epoch,
    required this.epochStartTimestamp,
    required this.leaderScheduleEpoch,
    required this.slot,
    required this.unixTimestamp,
  });

  /// The current epoch.
  final Epoch epoch;

  /// The Unix timestamp at the start of the current epoch.
  final UnixTimestamp epochStartTimestamp;

  /// The epoch for which the leader schedule is valid.
  final Epoch leaderScheduleEpoch;

  /// The current slot.
  final Slot slot;

  /// The current Unix timestamp.
  final UnixTimestamp unixTimestamp;
}

// ---------------------------------------------------------------------------
// Epoch Schedule
// ---------------------------------------------------------------------------

/// A parsed sysvar 'epochSchedule' variant.
class JsonParsedEpochScheduleSysvar
    extends RpcParsedType<String, JsonParsedEpochScheduleInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedEpochScheduleSysvar].
  const JsonParsedEpochScheduleSysvar({required super.info})
    : super(type: 'epochSchedule');
}

/// The info payload for the epoch schedule sysvar.
class JsonParsedEpochScheduleInfo {
  /// Creates a new [JsonParsedEpochScheduleInfo].
  const JsonParsedEpochScheduleInfo({
    required this.firstNormalEpoch,
    required this.firstNormalSlot,
    required this.leaderScheduleSlotOffset,
    required this.slotsPerEpoch,
    required this.warmup,
  });

  /// The first epoch that is not in the warmup period.
  final Epoch firstNormalEpoch;

  /// The first slot that is not in the warmup period.
  final Slot firstNormalSlot;

  /// The number of slots ahead the leader schedule is computed.
  final BigInt leaderScheduleSlotOffset;

  /// The number of slots per epoch.
  final BigInt slotsPerEpoch;

  /// Whether the cluster is in the warmup period.
  final bool warmup;
}

// ---------------------------------------------------------------------------
// Fees (deprecated)
// ---------------------------------------------------------------------------

/// A parsed sysvar 'fees' variant.
///
/// This sysvar is deprecated.
class JsonParsedFeesSysvar extends RpcParsedType<String, JsonParsedFeesInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedFeesSysvar].
  const JsonParsedFeesSysvar({required super.info}) : super(type: 'fees');
}

/// The info payload for the fees sysvar (deprecated).
class JsonParsedFeesInfo {
  /// Creates a new [JsonParsedFeesInfo].
  const JsonParsedFeesInfo({required this.feeCalculator});

  /// The fee calculator.
  final JsonParsedFeeCalculator feeCalculator;
}

/// A fee calculator containing the lamports per signature.
class JsonParsedFeeCalculator {
  /// Creates a new [JsonParsedFeeCalculator].
  const JsonParsedFeeCalculator({required this.lamportsPerSignature});

  /// The fee in lamports charged per signature.
  final StringifiedBigInt lamportsPerSignature;
}

// ---------------------------------------------------------------------------
// Recent Blockhashes (deprecated)
// ---------------------------------------------------------------------------

/// A parsed sysvar 'recentBlockhashes' variant.
///
/// This sysvar is deprecated.
class JsonParsedRecentBlockhashesSysvar
    extends RpcParsedType<String, List<JsonParsedRecentBlockhashEntry>>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedRecentBlockhashesSysvar].
  const JsonParsedRecentBlockhashesSysvar({required super.info})
    : super(type: 'recentBlockhashes');
}

/// An entry in the recent blockhashes sysvar (deprecated).
class JsonParsedRecentBlockhashEntry {
  /// Creates a new [JsonParsedRecentBlockhashEntry].
  const JsonParsedRecentBlockhashEntry({
    required this.blockhash,
    required this.feeCalculator,
  });

  /// The blockhash.
  final Blockhash blockhash;

  /// The fee calculator associated with this blockhash.
  final JsonParsedFeeCalculator feeCalculator;
}

// ---------------------------------------------------------------------------
// Rent
// ---------------------------------------------------------------------------

/// A parsed sysvar 'rent' variant.
class JsonParsedRentSysvar extends RpcParsedType<String, JsonParsedRentInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedRentSysvar].
  const JsonParsedRentSysvar({required super.info}) : super(type: 'rent');
}

/// The info payload for the rent sysvar.
class JsonParsedRentInfo {
  /// Creates a new [JsonParsedRentInfo].
  const JsonParsedRentInfo({
    required this.burnPercent,
    required this.exemptionThreshold,
    required this.lamportsPerByteYear,
  });

  /// The percentage of collected rent to burn.
  final int burnPercent;

  /// The exemption threshold multiplier.
  final double exemptionThreshold;

  /// The lamports charged per byte-year.
  final StringifiedBigInt lamportsPerByteYear;
}

// ---------------------------------------------------------------------------
// Slot Hashes
// ---------------------------------------------------------------------------

/// A parsed sysvar 'slotHashes' variant.
class JsonParsedSlotHashesSysvar
    extends RpcParsedType<String, List<JsonParsedSlotHashEntry>>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedSlotHashesSysvar].
  const JsonParsedSlotHashesSysvar({required super.info})
    : super(type: 'slotHashes');
}

/// An entry in the slot hashes sysvar.
class JsonParsedSlotHashEntry {
  /// Creates a new [JsonParsedSlotHashEntry].
  const JsonParsedSlotHashEntry({required this.hash, required this.slot});

  /// The hash of the slot.
  final String hash;

  /// The slot number.
  final Slot slot;
}

// ---------------------------------------------------------------------------
// Slot History
// ---------------------------------------------------------------------------

/// A parsed sysvar 'slotHistory' variant.
class JsonParsedSlotHistorySysvar
    extends RpcParsedType<String, JsonParsedSlotHistoryInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedSlotHistorySysvar].
  const JsonParsedSlotHistorySysvar({required super.info})
    : super(type: 'slotHistory');
}

/// The info payload for the slot history sysvar.
class JsonParsedSlotHistoryInfo {
  /// Creates a new [JsonParsedSlotHistoryInfo].
  const JsonParsedSlotHistoryInfo({required this.bits, required this.nextSlot});

  /// The bit vector representing slot history.
  final String bits;

  /// The next slot to be recorded.
  final Slot nextSlot;
}

// ---------------------------------------------------------------------------
// Stake History
// ---------------------------------------------------------------------------

/// A parsed sysvar 'stakeHistory' variant.
class JsonParsedStakeHistorySysvar
    extends RpcParsedType<String, List<JsonParsedStakeHistoryEntry>>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedStakeHistorySysvar].
  const JsonParsedStakeHistorySysvar({required super.info})
    : super(type: 'stakeHistory');
}

/// An entry in the stake history sysvar.
class JsonParsedStakeHistoryEntry {
  /// Creates a new [JsonParsedStakeHistoryEntry].
  const JsonParsedStakeHistoryEntry({
    required this.epoch,
    required this.stakeHistory,
  });

  /// The epoch number.
  final Epoch epoch;

  /// The stake history for this epoch.
  final JsonParsedStakeHistoryData stakeHistory;
}

/// The stake history data for a single epoch.
class JsonParsedStakeHistoryData {
  /// Creates a new [JsonParsedStakeHistoryData].
  const JsonParsedStakeHistoryData({
    required this.activating,
    required this.deactivating,
    required this.effective,
  });

  /// The amount of stake activating.
  final BigInt activating;

  /// The amount of stake deactivating.
  final BigInt deactivating;

  /// The effective stake.
  final BigInt effective;
}

// ---------------------------------------------------------------------------
// Last Restart Slot
// ---------------------------------------------------------------------------

/// A parsed sysvar 'lastRestartSlot' variant.
class JsonParsedLastRestartSlotSysvar
    extends RpcParsedType<String, JsonParsedLastRestartSlotInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedLastRestartSlotSysvar].
  const JsonParsedLastRestartSlotSysvar({required super.info})
    : super(type: 'lastRestartSlot');
}

/// The info payload for the last restart slot sysvar.
class JsonParsedLastRestartSlotInfo {
  /// Creates a new [JsonParsedLastRestartSlotInfo].
  const JsonParsedLastRestartSlotInfo({required this.lastRestartSlot});

  /// The last restart slot.
  final Slot lastRestartSlot;
}

// ---------------------------------------------------------------------------
// Epoch Rewards
// ---------------------------------------------------------------------------

/// A parsed sysvar 'epochRewards' variant.
class JsonParsedEpochRewardsSysvar
    extends RpcParsedType<String, JsonParsedEpochRewardsInfo>
    implements JsonParsedSysvarAccount {
  /// Creates a new [JsonParsedEpochRewardsSysvar].
  const JsonParsedEpochRewardsSysvar({required super.info})
    : super(type: 'epochRewards');
}

/// The info payload for the epoch rewards sysvar.
class JsonParsedEpochRewardsInfo {
  /// Creates a new [JsonParsedEpochRewardsInfo].
  const JsonParsedEpochRewardsInfo({
    required this.distributedRewards,
    required this.distributionCompleteBlockHeight,
    required this.totalRewards,
  });

  /// The total rewards distributed so far.
  final BigInt distributedRewards;

  /// The block height at which distribution will be complete.
  final BigInt distributionCompleteBlockHeight;

  /// The total rewards for the epoch.
  final BigInt totalRewards;
}
