import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// A fee calculator containing the lamports per signature cost.
@immutable
class FeeCalculator {
  /// Creates a new [FeeCalculator].
  const FeeCalculator({required this.lamportsPerSignature});

  /// The current cost of a signature.
  ///
  /// This amount may increase/decrease over time based on cluster processing
  /// load.
  final Lamports lamportsPerSignature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeCalculator &&
          runtimeType == other.runtimeType &&
          lamportsPerSignature == other.lamportsPerSignature;

  @override
  int get hashCode => lamportsPerSignature.hashCode;

  @override
  String toString() =>
      'FeeCalculator(lamportsPerSignature: ${lamportsPerSignature.value})';
}

/// An entry in the recent blockhashes sysvar.
@immutable
class RecentBlockhashEntry {
  /// Creates a new [RecentBlockhashEntry].
  const RecentBlockhashEntry({
    required this.blockhash,
    required this.feeCalculator,
  });

  /// The blockhash.
  final Blockhash blockhash;

  /// The fee calculator for this blockhash.
  final FeeCalculator feeCalculator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentBlockhashEntry &&
          runtimeType == other.runtimeType &&
          blockhash == other.blockhash &&
          feeCalculator == other.feeCalculator;

  @override
  int get hashCode => Object.hash(blockhash, feeCalculator);

  @override
  String toString() =>
      'RecentBlockhashEntry(blockhash: ${blockhash.value}, '
      'feeCalculator: $feeCalculator)';
}

/// Information about recent blocks and their fee calculators.
///
/// @deprecated Transaction fees should be determined with the
/// `getFeeForMessage` RPC method.
typedef SysvarRecentBlockhashes = List<RecentBlockhashEntry>;

/// Returns a variable-size encoder for the [SysvarRecentBlockhashes] sysvar.
///
/// @deprecated Transaction fees should be determined with the
/// `getFeeForMessage` RPC method.
VariableSizeEncoder<SysvarRecentBlockhashes>
getSysvarRecentBlockhashesEncoder() {
  final entryEncoder = getStructEncoder([
    ('blockhash', getBlockhashEncoder()),
    (
      'feeCalculator',
      getStructEncoder([('lamportsPerSignature', getDefaultLamportsEncoder())]),
    ),
  ]);
  final arrayEncoder = getArrayEncoder<Map<String, Object?>>(entryEncoder);

  return VariableSizeEncoder<SysvarRecentBlockhashes>(
    getSizeFromValue: (SysvarRecentBlockhashes value) {
      final maps = _entriesToMaps(value);
      return getEncodedSize(maps, arrayEncoder);
    },
    write: (SysvarRecentBlockhashes value, Uint8List bytes, int offset) {
      final maps = _entriesToMaps(value);
      return arrayEncoder.write(maps, bytes, offset);
    },
  );
}

/// Returns a variable-size decoder for the [SysvarRecentBlockhashes] sysvar.
///
/// @deprecated Transaction fees should be determined with the
/// `getFeeForMessage` RPC method.
VariableSizeDecoder<SysvarRecentBlockhashes>
getSysvarRecentBlockhashesDecoder() {
  final entryDecoder = getStructDecoder([
    ('blockhash', getBlockhashDecoder()),
    (
      'feeCalculator',
      getStructDecoder([('lamportsPerSignature', getDefaultLamportsDecoder())]),
    ),
  ]);
  final arrayDecoder = getArrayDecoder<Map<String, Object?>>(entryDecoder);

  return VariableSizeDecoder<SysvarRecentBlockhashes>(
    read: (Uint8List bytes, int offset) {
      final (maps, newOffset) = arrayDecoder.read(bytes, offset);
      final entries = maps.map(_mapToEntry).toList();
      return (entries, newOffset);
    },
  );
}

/// Returns a variable-size codec for the [SysvarRecentBlockhashes] sysvar.
///
/// @deprecated Transaction fees should be determined with the
/// `getFeeForMessage` RPC method.
VariableSizeCodec<SysvarRecentBlockhashes, SysvarRecentBlockhashes>
getSysvarRecentBlockhashesCodec() {
  return combineCodec(
        getSysvarRecentBlockhashesEncoder(),
        getSysvarRecentBlockhashesDecoder(),
      )
      as VariableSizeCodec<SysvarRecentBlockhashes, SysvarRecentBlockhashes>;
}

/// Fetches the `RecentBlockhashes` sysvar account using the provided RPC
/// client.
///
/// @deprecated Transaction fees should be determined with the
/// `getFeeForMessage` RPC method.
Future<SysvarRecentBlockhashes> fetchSysvarRecentBlockhashes(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarRecentBlockhashesAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarRecentBlockhashesDecoder(),
  );
  return decoded.data;
}

List<Map<String, Object?>> _entriesToMaps(SysvarRecentBlockhashes entries) {
  return entries.map((entry) {
    return <String, Object?>{
      'blockhash': entry.blockhash,
      'feeCalculator': <String, Object?>{
        'lamportsPerSignature': entry.feeCalculator.lamportsPerSignature,
      },
    };
  }).toList();
}

RecentBlockhashEntry _mapToEntry(Map<String, Object?> map) {
  final feeCalcMap = map['feeCalculator']! as Map<String, Object?>;
  return RecentBlockhashEntry(
    blockhash: map['blockhash']! as Blockhash,
    feeCalculator: FeeCalculator(
      lamportsPerSignature: feeCalcMap['lamportsPerSignature']! as Lamports,
    ),
  );
}
