import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// The size in bytes of the LastRestartSlot sysvar account data.
const int sysvarLastRestartSlotSize = 8;

/// Information about the last restart slot (hard fork).
///
/// The `LastRestartSlot` sysvar provides access to the last restart slot kept
/// in the bank fork for the slot on the fork that executes the current
/// transaction. In case there was no fork it returns `0`.
@immutable
class SysvarLastRestartSlot {
  /// Creates a new [SysvarLastRestartSlot].
  const SysvarLastRestartSlot({required this.lastRestartSlot});

  /// The last restart slot.
  final BigInt lastRestartSlot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysvarLastRestartSlot &&
          runtimeType == other.runtimeType &&
          lastRestartSlot == other.lastRestartSlot;

  @override
  int get hashCode => lastRestartSlot.hashCode;

  @override
  String toString() =>
      'SysvarLastRestartSlot(lastRestartSlot: $lastRestartSlot)';
}

/// Returns a fixed-size encoder for the [SysvarLastRestartSlot] sysvar.
FixedSizeEncoder<SysvarLastRestartSlot> getSysvarLastRestartSlotEncoder() {
  final structEncoder =
      getStructEncoder([('lastRestartSlot', getU64Encoder())])
          as FixedSizeEncoder<Map<String, Object?>>;

  return FixedSizeEncoder<SysvarLastRestartSlot>(
    fixedSize: sysvarLastRestartSlotSize,
    write: (SysvarLastRestartSlot value, Uint8List bytes, int offset) {
      return structEncoder.write(
        {'lastRestartSlot': value.lastRestartSlot},
        bytes,
        offset,
      );
    },
  );
}

/// Returns a fixed-size decoder for the [SysvarLastRestartSlot] sysvar.
FixedSizeDecoder<SysvarLastRestartSlot> getSysvarLastRestartSlotDecoder() {
  final structDecoder =
      getStructDecoder([('lastRestartSlot', getU64Decoder())])
          as FixedSizeDecoder<Map<String, Object?>>;

  return FixedSizeDecoder<SysvarLastRestartSlot>(
    fixedSize: sysvarLastRestartSlotSize,
    read: (Uint8List bytes, int offset) {
      final (map, newOffset) = structDecoder.read(bytes, offset);
      return (
        SysvarLastRestartSlot(
          lastRestartSlot: map['lastRestartSlot']! as BigInt,
        ),
        newOffset,
      );
    },
  );
}

/// Returns a fixed-size codec for the [SysvarLastRestartSlot] sysvar.
FixedSizeCodec<SysvarLastRestartSlot, SysvarLastRestartSlot>
getSysvarLastRestartSlotCodec() {
  return combineCodec(
        getSysvarLastRestartSlotEncoder(),
        getSysvarLastRestartSlotDecoder(),
      )
      as FixedSizeCodec<SysvarLastRestartSlot, SysvarLastRestartSlot>;
}

/// Fetches the `LastRestartSlot` sysvar account using the provided RPC
/// client.
Future<SysvarLastRestartSlot> fetchSysvarLastRestartSlot(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarLastRestartSlotAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarLastRestartSlotDecoder(),
  );
  return decoded.data;
}
