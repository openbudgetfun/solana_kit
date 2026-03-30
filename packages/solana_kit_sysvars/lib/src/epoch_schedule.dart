import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';
import 'package:solana_kit_sysvars/src/sysvar_layout.dart';

/// The size in bytes of the EpochSchedule sysvar account data.
const int sysvarEpochScheduleSize = 33;

/// Includes the number of slots per epoch, timing of leader schedule
/// selection, and information about epoch warm-up time.
@immutable
class SysvarEpochSchedule {
  /// Creates a new [SysvarEpochSchedule].
  const SysvarEpochSchedule({
    required this.slotsPerEpoch,
    required this.leaderScheduleSlotOffset,
    required this.warmup,
    required this.firstNormalEpoch,
    required this.firstNormalSlot,
  });

  /// The maximum number of slots in each epoch.
  final BigInt slotsPerEpoch;

  /// A number of slots before beginning of an epoch to calculate a leader
  /// schedule for that epoch.
  final BigInt leaderScheduleSlotOffset;

  /// Whether epochs start short and grow.
  final bool warmup;

  /// First normal-length epoch after the warmup period.
  final BigInt firstNormalEpoch;

  /// The first slot after the warmup period.
  final BigInt firstNormalSlot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysvarEpochSchedule &&
          runtimeType == other.runtimeType &&
          slotsPerEpoch == other.slotsPerEpoch &&
          leaderScheduleSlotOffset == other.leaderScheduleSlotOffset &&
          warmup == other.warmup &&
          firstNormalEpoch == other.firstNormalEpoch &&
          firstNormalSlot == other.firstNormalSlot;

  @override
  int get hashCode => hashStructuredFields([
    slotsPerEpoch,
    leaderScheduleSlotOffset,
    warmup,
    firstNormalEpoch,
    firstNormalSlot,
  ]);

  @override
  String toString() => formatStructuredFields('SysvarEpochSchedule', {
    'slotsPerEpoch': slotsPerEpoch,
    'leaderScheduleSlotOffset': leaderScheduleSlotOffset,
    'warmup': warmup,
    'firstNormalEpoch': firstNormalEpoch,
    'firstNormalSlot': firstNormalSlot,
  });
}

/// Returns a fixed-size encoder for the [SysvarEpochSchedule] sysvar.
FixedSizeEncoder<SysvarEpochSchedule> getSysvarEpochScheduleEncoder() {
  final structEncoder =
      getStructEncoder([
            ('slotsPerEpoch', getU64Encoder()),
            ('leaderScheduleSlotOffset', getU64Encoder()),
            ('warmup', getBooleanEncoder()),
            ('firstNormalEpoch', getU64Encoder()),
            ('firstNormalSlot', getU64Encoder()),
          ])
          as FixedSizeEncoder<Map<String, Object?>>;

  return mapFixedSizeStructEncoder(
    fixedSize: sysvarEpochScheduleSize,
    structEncoder: structEncoder,
    toFields: (value) => {
      'slotsPerEpoch': value.slotsPerEpoch,
      'leaderScheduleSlotOffset': value.leaderScheduleSlotOffset,
      'warmup': value.warmup,
      'firstNormalEpoch': value.firstNormalEpoch,
      'firstNormalSlot': value.firstNormalSlot,
    },
  );
}

/// Returns a fixed-size decoder for the [SysvarEpochSchedule] sysvar.
FixedSizeDecoder<SysvarEpochSchedule> getSysvarEpochScheduleDecoder() {
  final structDecoder =
      getStructDecoder([
            ('slotsPerEpoch', getU64Decoder()),
            ('leaderScheduleSlotOffset', getU64Decoder()),
            ('warmup', getBooleanDecoder()),
            ('firstNormalEpoch', getU64Decoder()),
            ('firstNormalSlot', getU64Decoder()),
          ])
          as FixedSizeDecoder<Map<String, Object?>>;

  return mapFixedSizeStructDecoder(
    fixedSize: sysvarEpochScheduleSize,
    structDecoder: structDecoder,
    fromFields: (map) => SysvarEpochSchedule(
      slotsPerEpoch: map['slotsPerEpoch']! as BigInt,
      leaderScheduleSlotOffset: map['leaderScheduleSlotOffset']! as BigInt,
      warmup: map['warmup']! as bool,
      firstNormalEpoch: map['firstNormalEpoch']! as BigInt,
      firstNormalSlot: map['firstNormalSlot']! as BigInt,
    ),
  );
}

/// Returns a fixed-size codec for the [SysvarEpochSchedule] sysvar.
FixedSizeCodec<SysvarEpochSchedule, SysvarEpochSchedule>
getSysvarEpochScheduleCodec() {
  final structEncoder =
      getStructEncoder([
            ('slotsPerEpoch', getU64Encoder()),
            ('leaderScheduleSlotOffset', getU64Encoder()),
            ('warmup', getBooleanEncoder()),
            ('firstNormalEpoch', getU64Encoder()),
            ('firstNormalSlot', getU64Encoder()),
          ])
          as FixedSizeEncoder<Map<String, Object?>>;
  final structDecoder =
      getStructDecoder([
            ('slotsPerEpoch', getU64Decoder()),
            ('leaderScheduleSlotOffset', getU64Decoder()),
            ('warmup', getBooleanDecoder()),
            ('firstNormalEpoch', getU64Decoder()),
            ('firstNormalSlot', getU64Decoder()),
          ])
          as FixedSizeDecoder<Map<String, Object?>>;

  return mapFixedSizeStructCodec(
    fixedSize: sysvarEpochScheduleSize,
    structEncoder: structEncoder,
    structDecoder: structDecoder,
    toFields: (value) => {
      'slotsPerEpoch': value.slotsPerEpoch,
      'leaderScheduleSlotOffset': value.leaderScheduleSlotOffset,
      'warmup': value.warmup,
      'firstNormalEpoch': value.firstNormalEpoch,
      'firstNormalSlot': value.firstNormalSlot,
    },
    fromFields: (map) => SysvarEpochSchedule(
      slotsPerEpoch: map['slotsPerEpoch']! as BigInt,
      leaderScheduleSlotOffset: map['leaderScheduleSlotOffset']! as BigInt,
      warmup: map['warmup']! as bool,
      firstNormalEpoch: map['firstNormalEpoch']! as BigInt,
      firstNormalSlot: map['firstNormalSlot']! as BigInt,
    ),
  );
}

/// Fetches the `EpochSchedule` sysvar account using the provided RPC client.
Future<SysvarEpochSchedule> fetchSysvarEpochSchedule(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarEpochScheduleAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarEpochScheduleDecoder(),
  );
  return decoded.data;
}
