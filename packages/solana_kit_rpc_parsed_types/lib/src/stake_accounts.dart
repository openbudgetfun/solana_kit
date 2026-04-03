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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeAccountInfo &&
          runtimeType == other.runtimeType &&
          meta == other.meta &&
          stake == other.stake;

  @override
  int get hashCode => Object.hash(runtimeType, meta, stake);

  @override
  String toString() => 'JsonParsedStakeAccountInfo(meta: $meta, stake: $stake)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeMeta &&
          runtimeType == other.runtimeType &&
          authorized == other.authorized &&
          lockup == other.lockup &&
          rentExemptReserve == other.rentExemptReserve;

  @override
  int get hashCode =>
      Object.hash(runtimeType, authorized, lockup, rentExemptReserve);

  @override
  String toString() =>
      'JsonParsedStakeMeta(authorized: $authorized, lockup: $lockup, '
      'rentExemptReserve: $rentExemptReserve)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeAuthorized &&
          runtimeType == other.runtimeType &&
          staker == other.staker &&
          withdrawer == other.withdrawer;

  @override
  int get hashCode => Object.hash(runtimeType, staker, withdrawer);

  @override
  String toString() =>
      'JsonParsedStakeAuthorized(staker: $staker, withdrawer: $withdrawer)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeLockup &&
          runtimeType == other.runtimeType &&
          custodian == other.custodian &&
          epoch == other.epoch &&
          unixTimestamp == other.unixTimestamp;

  @override
  int get hashCode => Object.hash(runtimeType, custodian, epoch, unixTimestamp);

  @override
  String toString() =>
      'JsonParsedStakeLockup(custodian: $custodian, epoch: $epoch, '
      'unixTimestamp: $unixTimestamp)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeData &&
          runtimeType == other.runtimeType &&
          creditsObserved == other.creditsObserved &&
          delegation == other.delegation;

  @override
  int get hashCode => Object.hash(runtimeType, creditsObserved, delegation);

  @override
  String toString() =>
      'JsonParsedStakeData(creditsObserved: $creditsObserved, '
      'delegation: $delegation)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeDelegation &&
          runtimeType == other.runtimeType &&
          activationEpoch == other.activationEpoch &&
          deactivationEpoch == other.deactivationEpoch &&
          stake == other.stake &&
          voter == other.voter &&
          warmupCooldownRate == other.warmupCooldownRate;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    activationEpoch,
    deactivationEpoch,
    stake,
    voter,
    warmupCooldownRate,
  );

  @override
  String toString() =>
      'JsonParsedStakeDelegation(activationEpoch: $activationEpoch, '
      'deactivationEpoch: $deactivationEpoch, stake: $stake, '
      'voter: $voter, warmupCooldownRate: $warmupCooldownRate)';
}
