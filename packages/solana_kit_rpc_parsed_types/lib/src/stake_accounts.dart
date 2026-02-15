import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parsed account data for a Stake program account.
///
/// This is a discriminated union that can be either a
/// [JsonParsedDelegatedStake] ('delegated') or a
/// [JsonParsedInitializedStake] ('initialized').
sealed class JsonParsedStakeProgramAccount {
  const JsonParsedStakeProgramAccount();
}

/// A parsed Stake program 'delegated' variant.
class JsonParsedDelegatedStake
    extends RpcParsedType<String, JsonParsedStakeAccountInfo>
    implements JsonParsedStakeProgramAccount {
  /// Creates a new [JsonParsedDelegatedStake].
  const JsonParsedDelegatedStake({required super.info})
    : super(type: 'delegated');
}

/// A parsed Stake program 'initialized' variant.
class JsonParsedInitializedStake
    extends RpcParsedType<String, JsonParsedStakeAccountInfo>
    implements JsonParsedStakeProgramAccount {
  /// Creates a new [JsonParsedInitializedStake].
  const JsonParsedInitializedStake({required super.info})
    : super(type: 'initialized');
}

/// The info payload for a parsed stake account.
class JsonParsedStakeAccountInfo {
  /// Creates a new [JsonParsedStakeAccountInfo].
  const JsonParsedStakeAccountInfo({required this.meta, this.stake});

  /// The stake account metadata.
  final JsonParsedStakeMeta meta;

  /// The stake delegation data, or `null` if not yet delegated.
  final JsonParsedStakeData? stake;
}

/// Metadata for a parsed stake account.
class JsonParsedStakeMeta {
  /// Creates a new [JsonParsedStakeMeta].
  const JsonParsedStakeMeta({
    required this.authorized,
    required this.lockup,
    required this.rentExemptReserve,
  });

  /// The authorized staker and withdrawer.
  final JsonParsedStakeAuthorized authorized;

  /// The lockup configuration.
  final JsonParsedStakeLockup lockup;

  /// The rent-exempt reserve amount.
  final StringifiedBigInt rentExemptReserve;
}

/// The authorized staker and withdrawer for a stake account.
class JsonParsedStakeAuthorized {
  /// Creates a new [JsonParsedStakeAuthorized].
  const JsonParsedStakeAuthorized({
    required this.staker,
    required this.withdrawer,
  });

  /// The address authorized to stake.
  final Address staker;

  /// The address authorized to withdraw.
  final Address withdrawer;
}

/// The lockup configuration for a stake account.
class JsonParsedStakeLockup {
  /// Creates a new [JsonParsedStakeLockup].
  const JsonParsedStakeLockup({
    required this.custodian,
    required this.epoch,
    required this.unixTimestamp,
  });

  /// The custodian address that can modify the lockup.
  final Address custodian;

  /// The epoch at which the lockup expires.
  final BigInt epoch;

  /// The Unix timestamp at which the lockup expires.
  final UnixTimestamp unixTimestamp;
}

/// The stake delegation data for a stake account.
class JsonParsedStakeData {
  /// Creates a new [JsonParsedStakeData].
  const JsonParsedStakeData({
    required this.creditsObserved,
    required this.delegation,
  });

  /// The total credits observed.
  final BigInt creditsObserved;

  /// The delegation details.
  final JsonParsedStakeDelegation delegation;
}

/// The delegation details for a stake account.
class JsonParsedStakeDelegation {
  /// Creates a new [JsonParsedStakeDelegation].
  const JsonParsedStakeDelegation({
    required this.activationEpoch,
    required this.deactivationEpoch,
    required this.stake,
    required this.voter,
    required this.warmupCooldownRate,
  });

  /// The epoch in which the stake was activated.
  final StringifiedBigInt activationEpoch;

  /// The epoch in which the stake was deactivated.
  final StringifiedBigInt deactivationEpoch;

  /// The amount of stake delegated.
  final StringifiedBigInt stake;

  /// The vote account to which the stake is delegated.
  final Address voter;

  /// The warmup/cooldown rate.
  final double warmupCooldownRate;
}
