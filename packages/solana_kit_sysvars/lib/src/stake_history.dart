import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// Stake activation/deactivation data for a single epoch.
@immutable
class StakeHistoryData {
  /// Creates a new [StakeHistoryData].
  const StakeHistoryData({
    required this.effective,
    required this.activating,
    required this.deactivating,
  });

  /// Effective stake at this epoch, in [Lamports].
  final Lamports effective;

  /// Sum of portion of stakes requested to be warmed up, but not fully
  /// activated yet, in [Lamports].
  final Lamports activating;

  /// Sum of portion of stakes requested to be cooled down, but not fully
  /// deactivated yet, in [Lamports].
  final Lamports deactivating;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeHistoryData &&
          runtimeType == other.runtimeType &&
          effective == other.effective &&
          activating == other.activating &&
          deactivating == other.deactivating;

  @override
  int get hashCode => Object.hash(effective, activating, deactivating);

  @override
  String toString() =>
      'StakeHistoryData(effective: ${effective.value}, '
      'activating: ${activating.value}, '
      'deactivating: ${deactivating.value})';
}

/// An entry in the stake history sysvar.
@immutable
class StakeHistoryEntry {
  /// Creates a new [StakeHistoryEntry].
  const StakeHistoryEntry({required this.epoch, required this.stakeHistory});

  /// The epoch to which this stake history entry pertains.
  final BigInt epoch;

  /// The stake activation/deactivation data.
  final StakeHistoryData stakeHistory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StakeHistoryEntry &&
          runtimeType == other.runtimeType &&
          epoch == other.epoch &&
          stakeHistory == other.stakeHistory;

  @override
  int get hashCode => Object.hash(epoch, stakeHistory);

  @override
  String toString() =>
      'StakeHistoryEntry(epoch: $epoch, stakeHistory: $stakeHistory)';
}

/// History of stake activations and de-activations.
typedef SysvarStakeHistory = List<StakeHistoryEntry>;

/// Size of each entry struct: u64 epoch + u64 effective + u64 activating +
/// u64 deactivating = 32 bytes.
const int _entrySize = 32;

/// Returns a variable-size encoder for the [SysvarStakeHistory] sysvar.
VariableSizeEncoder<SysvarStakeHistory> getSysvarStakeHistoryEncoder() {
  final u64Encoder = getU64Encoder();
  final entryEncoder = getStructEncoder([
    ('epoch', getU64Encoder()),
    (
      'stakeHistory',
      getStructEncoder([
        ('effective', getDefaultLamportsEncoder()),
        ('activating', getDefaultLamportsEncoder()),
        ('deactivating', getDefaultLamportsEncoder()),
      ]),
    ),
  ]);

  return VariableSizeEncoder<SysvarStakeHistory>(
    getSizeFromValue: (SysvarStakeHistory value) {
      // 8 bytes for the u64 length prefix + entry size * count.
      return 8 + _entrySize * value.length;
    },
    write: (SysvarStakeHistory value, Uint8List bytes, int offset) {
      var o = offset;
      // Write the u64 length prefix.
      o = u64Encoder.write(BigInt.from(value.length), bytes, o);
      // Write each entry.
      for (final entry in value) {
        o = entryEncoder.write(_entryToMap(entry), bytes, o);
      }
      return o;
    },
  );
}

/// Returns a variable-size decoder for the [SysvarStakeHistory] sysvar.
VariableSizeDecoder<SysvarStakeHistory> getSysvarStakeHistoryDecoder() {
  final u64Decoder = getU64Decoder();
  final entryDecoder = getStructDecoder([
    ('epoch', getU64Decoder()),
    (
      'stakeHistory',
      getStructDecoder([
        ('effective', getDefaultLamportsDecoder()),
        ('activating', getDefaultLamportsDecoder()),
        ('deactivating', getDefaultLamportsDecoder()),
      ]),
    ),
  ]);

  return VariableSizeDecoder<SysvarStakeHistory>(
    read: (Uint8List bytes, int offset) {
      var o = offset;
      // Read the u64 length prefix.
      final (length, offsetAfterLen) = u64Decoder.read(bytes, o);
      o = offsetAfterLen;
      final count = length.toInt();
      final entries = <StakeHistoryEntry>[];
      for (var i = 0; i < count; i++) {
        final (map, newOffset) = entryDecoder.read(bytes, o);
        o = newOffset;
        entries.add(_mapToEntry(map));
      }
      return (entries, o);
    },
  );
}

/// Returns a variable-size codec for the [SysvarStakeHistory] sysvar.
VariableSizeCodec<SysvarStakeHistory, SysvarStakeHistory>
getSysvarStakeHistoryCodec() {
  return combineCodec(
        getSysvarStakeHistoryEncoder(),
        getSysvarStakeHistoryDecoder(),
      )
      as VariableSizeCodec<SysvarStakeHistory, SysvarStakeHistory>;
}

/// Fetches the `StakeHistory` sysvar account using the provided RPC client.
Future<SysvarStakeHistory> fetchSysvarStakeHistory(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarStakeHistoryAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarStakeHistoryDecoder(),
  );
  return decoded.data;
}

Map<String, Object?> _entryToMap(StakeHistoryEntry entry) {
  return <String, Object?>{
    'epoch': entry.epoch,
    'stakeHistory': <String, Object?>{
      'effective': entry.stakeHistory.effective,
      'activating': entry.stakeHistory.activating,
      'deactivating': entry.stakeHistory.deactivating,
    },
  };
}

StakeHistoryEntry _mapToEntry(Map<String, Object?> map) {
  final stakeHistoryMap = map['stakeHistory']! as Map<String, Object?>;
  return StakeHistoryEntry(
    epoch: map['epoch']! as BigInt,
    stakeHistory: StakeHistoryData(
      effective: stakeHistoryMap['effective']! as Lamports,
      activating: stakeHistoryMap['activating']! as Lamports,
      deactivating: stakeHistoryMap['deactivating']! as Lamports,
    ),
  );
}
