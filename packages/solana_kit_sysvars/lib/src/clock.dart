import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';
import 'package:solana_kit_sysvars/src/sysvar_layout.dart';

/// The size in bytes of the Clock sysvar account data.
const int sysvarClockSize = 40;

/// Contains data on cluster time, including the current slot, epoch, and
/// estimated wall-clock Unix timestamp. It is updated every slot.
@immutable
class SysvarClock {
  /// Creates a new [SysvarClock].
  const SysvarClock({
    required this.slot,
    required this.epochStartTimestamp,
    required this.epoch,
    required this.leaderScheduleEpoch,
    required this.unixTimestamp,
  });

  /// The current slot.
  final BigInt slot;

  /// The Unix timestamp of the first slot in this epoch.
  ///
  /// In the first slot of an epoch, this timestamp is identical to the
  /// [unixTimestamp].
  final BigInt epochStartTimestamp;

  /// The current epoch.
  final BigInt epoch;

  /// The most recent epoch for which the leader schedule has already been
  /// generated.
  final BigInt leaderScheduleEpoch;

  /// The Unix timestamp of this slot.
  final BigInt unixTimestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysvarClock &&
          runtimeType == other.runtimeType &&
          slot == other.slot &&
          epochStartTimestamp == other.epochStartTimestamp &&
          epoch == other.epoch &&
          leaderScheduleEpoch == other.leaderScheduleEpoch &&
          unixTimestamp == other.unixTimestamp;

  @override
  int get hashCode => hashStructuredFields([
    slot,
    epochStartTimestamp,
    epoch,
    leaderScheduleEpoch,
    unixTimestamp,
  ]);

  @override
  String toString() => formatStructuredFields('SysvarClock', {
    'slot': slot,
    'epochStartTimestamp': epochStartTimestamp,
    'epoch': epoch,
    'leaderScheduleEpoch': leaderScheduleEpoch,
    'unixTimestamp': unixTimestamp,
  });
}

/// Returns a fixed-size encoder for the [SysvarClock] sysvar.
FixedSizeEncoder<SysvarClock> getSysvarClockEncoder() {
  final structEncoder =
      getStructEncoder([
            ('slot', getU64Encoder()),
            ('epochStartTimestamp', getI64Encoder()),
            ('epoch', getU64Encoder()),
            ('leaderScheduleEpoch', getU64Encoder()),
            ('unixTimestamp', getI64Encoder()),
          ])
          as FixedSizeEncoder<Map<String, Object?>>;

  return mapFixedSizeStructEncoder(
    fixedSize: sysvarClockSize,
    structEncoder: structEncoder,
    toFields: (value) => {
      'slot': value.slot,
      'epochStartTimestamp': value.epochStartTimestamp,
      'epoch': value.epoch,
      'leaderScheduleEpoch': value.leaderScheduleEpoch,
      'unixTimestamp': value.unixTimestamp,
    },
  );
}

/// Returns a fixed-size decoder for the [SysvarClock] sysvar.
FixedSizeDecoder<SysvarClock> getSysvarClockDecoder() {
  final structDecoder =
      getStructDecoder([
            ('slot', getU64Decoder()),
            ('epochStartTimestamp', getI64Decoder()),
            ('epoch', getU64Decoder()),
            ('leaderScheduleEpoch', getU64Decoder()),
            ('unixTimestamp', getI64Decoder()),
          ])
          as FixedSizeDecoder<Map<String, Object?>>;

  return mapFixedSizeStructDecoder(
    fixedSize: sysvarClockSize,
    structDecoder: structDecoder,
    fromFields: (map) => SysvarClock(
      slot: map['slot']! as BigInt,
      epochStartTimestamp: map['epochStartTimestamp']! as BigInt,
      epoch: map['epoch']! as BigInt,
      leaderScheduleEpoch: map['leaderScheduleEpoch']! as BigInt,
      unixTimestamp: map['unixTimestamp']! as BigInt,
    ),
  );
}

/// Returns a fixed-size codec for the [SysvarClock] sysvar.
FixedSizeCodec<SysvarClock, SysvarClock> getSysvarClockCodec() {
  final structEncoder =
      getStructEncoder([
            ('slot', getU64Encoder()),
            ('epochStartTimestamp', getI64Encoder()),
            ('epoch', getU64Encoder()),
            ('leaderScheduleEpoch', getU64Encoder()),
            ('unixTimestamp', getI64Encoder()),
          ])
          as FixedSizeEncoder<Map<String, Object?>>;
  final structDecoder =
      getStructDecoder([
            ('slot', getU64Decoder()),
            ('epochStartTimestamp', getI64Decoder()),
            ('epoch', getU64Decoder()),
            ('leaderScheduleEpoch', getU64Decoder()),
            ('unixTimestamp', getI64Decoder()),
          ])
          as FixedSizeDecoder<Map<String, Object?>>;

  return mapFixedSizeStructCodec(
    fixedSize: sysvarClockSize,
    structEncoder: structEncoder,
    structDecoder: structDecoder,
    toFields: (value) => {
      'slot': value.slot,
      'epochStartTimestamp': value.epochStartTimestamp,
      'epoch': value.epoch,
      'leaderScheduleEpoch': value.leaderScheduleEpoch,
      'unixTimestamp': value.unixTimestamp,
    },
    fromFields: (map) => SysvarClock(
      slot: map['slot']! as BigInt,
      epochStartTimestamp: map['epochStartTimestamp']! as BigInt,
      epoch: map['epoch']! as BigInt,
      leaderScheduleEpoch: map['leaderScheduleEpoch']! as BigInt,
      unixTimestamp: map['unixTimestamp']! as BigInt,
    ),
  );
}

/// Fetches the `Clock` sysvar account using the provided RPC client.
Future<SysvarClock> fetchSysvarClock(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarClockAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarClockDecoder(),
  );
  return decoded.data;
}
