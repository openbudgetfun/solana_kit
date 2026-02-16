import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// An entry in the slot hashes sysvar.
@immutable
class SlotHashEntry {
  /// Creates a new [SlotHashEntry].
  const SlotHashEntry({required this.slot, required this.hash});

  /// The slot number.
  final BigInt slot;

  /// The hash of the slot's parent bank.
  final Blockhash hash;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotHashEntry &&
          runtimeType == other.runtimeType &&
          slot == other.slot &&
          hash == other.hash;

  @override
  int get hashCode => Object.hash(slot, hash);

  @override
  String toString() => 'SlotHashEntry(slot: $slot, hash: ${hash.value})';
}

/// The most recent hashes of a slot's parent banks.
typedef SysvarSlotHashes = List<SlotHashEntry>;

/// Returns a variable-size encoder for the [SysvarSlotHashes] sysvar.
VariableSizeEncoder<SysvarSlotHashes> getSysvarSlotHashesEncoder() {
  final entryEncoder = getStructEncoder([
    ('slot', getU64Encoder()),
    ('hash', getBlockhashEncoder()),
  ]);
  final arrayEncoder = getArrayEncoder<Map<String, Object?>>(entryEncoder);

  return VariableSizeEncoder<SysvarSlotHashes>(
    getSizeFromValue: (SysvarSlotHashes value) {
      final maps = _entriesToMaps(value);
      return getEncodedSize(maps, arrayEncoder);
    },
    write: (SysvarSlotHashes value, Uint8List bytes, int offset) {
      final maps = _entriesToMaps(value);
      return arrayEncoder.write(maps, bytes, offset);
    },
  );
}

/// Returns a variable-size decoder for the [SysvarSlotHashes] sysvar.
VariableSizeDecoder<SysvarSlotHashes> getSysvarSlotHashesDecoder() {
  final entryDecoder = getStructDecoder([
    ('slot', getU64Decoder()),
    ('hash', getBlockhashDecoder()),
  ]);
  final arrayDecoder = getArrayDecoder<Map<String, Object?>>(entryDecoder);

  return VariableSizeDecoder<SysvarSlotHashes>(
    read: (Uint8List bytes, int offset) {
      final (maps, newOffset) = arrayDecoder.read(bytes, offset);
      final entries = maps.map(_mapToEntry).toList();
      return (entries, newOffset);
    },
  );
}

/// Returns a variable-size codec for the [SysvarSlotHashes] sysvar.
VariableSizeCodec<SysvarSlotHashes, SysvarSlotHashes>
getSysvarSlotHashesCodec() {
  return combineCodec(
        getSysvarSlotHashesEncoder(),
        getSysvarSlotHashesDecoder(),
      )
      as VariableSizeCodec<SysvarSlotHashes, SysvarSlotHashes>;
}

/// Fetches the `SlotHashes` sysvar account using the provided RPC client.
Future<SysvarSlotHashes> fetchSysvarSlotHashes(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarSlotHashesAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarSlotHashesDecoder(),
  );
  return decoded.data;
}

List<Map<String, Object?>> _entriesToMaps(SysvarSlotHashes entries) {
  return entries.map((entry) {
    return <String, Object?>{'slot': entry.slot, 'hash': entry.hash};
  }).toList();
}

SlotHashEntry _mapToEntry(Map<String, Object?> map) {
  return SlotHashEntry(
    slot: map['slot']! as BigInt,
    hash: map['hash']! as Blockhash,
  );
}
