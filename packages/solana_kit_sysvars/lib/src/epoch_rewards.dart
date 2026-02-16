import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// The size in bytes of the EpochRewards sysvar account data.
const int sysvarEpochRewardsSize = 81;

/// Tracks whether the rewards period (including calculation and distribution)
/// is in progress, as well as the details needed to resume distribution when
/// starting from a snapshot during the rewards period.
///
/// The sysvar is repopulated at the start of the first block of each epoch.
/// Therefore, the sysvar contains data about the current epoch until a new
/// epoch begins.
@immutable
class SysvarEpochRewards {
  /// Creates a new [SysvarEpochRewards].
  const SysvarEpochRewards({
    required this.distributionStartingBlockHeight,
    required this.numPartitions,
    required this.parentBlockhash,
    required this.totalPoints,
    required this.totalRewards,
    required this.distributedRewards,
    required this.active,
  });

  /// The starting block height of the rewards distribution in the current
  /// epoch.
  final BigInt distributionStartingBlockHeight;

  /// Number of partitions in the rewards distribution in the current epoch,
  /// used to generate an `EpochRewardsHasher`.
  final BigInt numPartitions;

  /// The [Blockhash] of the parent block of the first block in the epoch,
  /// used to seed an `EpochRewardsHasher`.
  final Blockhash parentBlockhash;

  /// The total rewards points calculated for the current epoch, where points
  /// equals the sum of (delegated stake * credits observed) for all
  /// delegations.
  final BigInt totalPoints;

  /// The total rewards for the current epoch, in [Lamports].
  final Lamports totalRewards;

  /// The rewards currently distributed for the current epoch, in [Lamports].
  final Lamports distributedRewards;

  /// Whether the rewards period (including calculation and distribution) is
  /// active.
  final bool active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysvarEpochRewards &&
          runtimeType == other.runtimeType &&
          distributionStartingBlockHeight ==
              other.distributionStartingBlockHeight &&
          numPartitions == other.numPartitions &&
          parentBlockhash == other.parentBlockhash &&
          totalPoints == other.totalPoints &&
          totalRewards == other.totalRewards &&
          distributedRewards == other.distributedRewards &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
    distributionStartingBlockHeight,
    numPartitions,
    parentBlockhash,
    totalPoints,
    totalRewards,
    distributedRewards,
    active,
  );

  @override
  String toString() =>
      'SysvarEpochRewards(distributionStartingBlockHeight: '
      '$distributionStartingBlockHeight, numPartitions: $numPartitions, '
      'parentBlockhash: ${parentBlockhash.value}, '
      'totalPoints: $totalPoints, totalRewards: ${totalRewards.value}, '
      'distributedRewards: ${distributedRewards.value}, active: $active)';
}

/// Returns a fixed-size encoder for the [SysvarEpochRewards] sysvar.
FixedSizeEncoder<SysvarEpochRewards> getSysvarEpochRewardsEncoder() {
  final structEncoder =
      getStructEncoder([
            ('distributionStartingBlockHeight', getU64Encoder()),
            ('numPartitions', getU64Encoder()),
            ('parentBlockhash', getBlockhashEncoder()),
            ('totalPoints', getU128Encoder()),
            ('totalRewards', getDefaultLamportsEncoder()),
            ('distributedRewards', getDefaultLamportsEncoder()),
            ('active', getBooleanEncoder()),
          ])
          as FixedSizeEncoder<Map<String, Object?>>;

  return FixedSizeEncoder<SysvarEpochRewards>(
    fixedSize: sysvarEpochRewardsSize,
    write: (SysvarEpochRewards value, Uint8List bytes, int offset) {
      return structEncoder.write(
        {
          'distributionStartingBlockHeight':
              value.distributionStartingBlockHeight,
          'numPartitions': value.numPartitions,
          'parentBlockhash': value.parentBlockhash,
          'totalPoints': value.totalPoints,
          'totalRewards': value.totalRewards,
          'distributedRewards': value.distributedRewards,
          'active': value.active,
        },
        bytes,
        offset,
      );
    },
  );
}

/// Returns a fixed-size decoder for the [SysvarEpochRewards] sysvar.
FixedSizeDecoder<SysvarEpochRewards> getSysvarEpochRewardsDecoder() {
  final structDecoder =
      getStructDecoder([
            ('distributionStartingBlockHeight', getU64Decoder()),
            ('numPartitions', getU64Decoder()),
            ('parentBlockhash', getBlockhashDecoder()),
            ('totalPoints', getU128Decoder()),
            ('totalRewards', getDefaultLamportsDecoder()),
            ('distributedRewards', getDefaultLamportsDecoder()),
            ('active', getBooleanDecoder()),
          ])
          as FixedSizeDecoder<Map<String, Object?>>;

  return FixedSizeDecoder<SysvarEpochRewards>(
    fixedSize: sysvarEpochRewardsSize,
    read: (Uint8List bytes, int offset) {
      final (map, newOffset) = structDecoder.read(bytes, offset);
      return (
        SysvarEpochRewards(
          distributionStartingBlockHeight:
              map['distributionStartingBlockHeight']! as BigInt,
          numPartitions: map['numPartitions']! as BigInt,
          parentBlockhash: map['parentBlockhash']! as Blockhash,
          totalPoints: map['totalPoints']! as BigInt,
          totalRewards: map['totalRewards']! as Lamports,
          distributedRewards: map['distributedRewards']! as Lamports,
          active: map['active']! as bool,
        ),
        newOffset,
      );
    },
  );
}

/// Returns a fixed-size codec for the [SysvarEpochRewards] sysvar.
FixedSizeCodec<SysvarEpochRewards, SysvarEpochRewards>
getSysvarEpochRewardsCodec() {
  return combineCodec(
        getSysvarEpochRewardsEncoder(),
        getSysvarEpochRewardsDecoder(),
      )
      as FixedSizeCodec<SysvarEpochRewards, SysvarEpochRewards>;
}

/// Fetches the `EpochRewards` sysvar account using the provided RPC client.
Future<SysvarEpochRewards> fetchSysvarEpochRewards(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarEpochRewardsAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarEpochRewardsDecoder(),
  );
  return decoded.data;
}
