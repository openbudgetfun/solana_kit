import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// The size in bytes of the Rent sysvar account data.
const int sysvarRentSize = 17;

/// Configuration for network rent.
@immutable
class SysvarRent {
  /// Creates a new [SysvarRent].
  const SysvarRent({
    required this.lamportsPerByteYear,
    required this.exemptionThreshold,
    required this.burnPercent,
  });

  /// Rental rate in [Lamports]/byte-year.
  final Lamports lamportsPerByteYear;

  /// Amount of time (in years) a balance must include rent for the account
  /// to be rent exempt.
  final double exemptionThreshold;

  /// The percentage of collected rent that is burned.
  ///
  /// Valid values are in the range [0, 100]. The remaining percentage is
  /// distributed to validators.
  final int burnPercent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysvarRent &&
          runtimeType == other.runtimeType &&
          lamportsPerByteYear == other.lamportsPerByteYear &&
          exemptionThreshold == other.exemptionThreshold &&
          burnPercent == other.burnPercent;

  @override
  int get hashCode =>
      Object.hash(lamportsPerByteYear, exemptionThreshold, burnPercent);

  @override
  String toString() =>
      'SysvarRent(lamportsPerByteYear: ${lamportsPerByteYear.value}, '
      'exemptionThreshold: $exemptionThreshold, '
      'burnPercent: $burnPercent)';
}

/// Returns a fixed-size encoder for the [SysvarRent] sysvar.
FixedSizeEncoder<SysvarRent> getSysvarRentEncoder() {
  final structEncoder =
      getStructEncoder([
            ('lamportsPerByteYear', getDefaultLamportsEncoder()),
            ('exemptionThreshold', getF64Encoder()),
            ('burnPercent', getU8Encoder()),
          ])
          as FixedSizeEncoder<Map<String, Object?>>;

  return FixedSizeEncoder<SysvarRent>(
    fixedSize: sysvarRentSize,
    write: (SysvarRent value, Uint8List bytes, int offset) {
      return structEncoder.write(
        {
          'lamportsPerByteYear': value.lamportsPerByteYear,
          'exemptionThreshold': value.exemptionThreshold,
          'burnPercent': value.burnPercent,
        },
        bytes,
        offset,
      );
    },
  );
}

/// Returns a fixed-size decoder for the [SysvarRent] sysvar.
FixedSizeDecoder<SysvarRent> getSysvarRentDecoder() {
  final structDecoder =
      getStructDecoder([
            ('lamportsPerByteYear', getDefaultLamportsDecoder()),
            ('exemptionThreshold', getF64Decoder()),
            ('burnPercent', getU8Decoder()),
          ])
          as FixedSizeDecoder<Map<String, Object?>>;

  return FixedSizeDecoder<SysvarRent>(
    fixedSize: sysvarRentSize,
    read: (Uint8List bytes, int offset) {
      final (map, newOffset) = structDecoder.read(bytes, offset);
      return (
        SysvarRent(
          lamportsPerByteYear: map['lamportsPerByteYear']! as Lamports,
          exemptionThreshold: map['exemptionThreshold']! as double,
          burnPercent: map['burnPercent']! as int,
        ),
        newOffset,
      );
    },
  );
}

/// Returns a fixed-size codec for the [SysvarRent] sysvar.
FixedSizeCodec<SysvarRent, SysvarRent> getSysvarRentCodec() {
  return combineCodec(getSysvarRentEncoder(), getSysvarRentDecoder())
      as FixedSizeCodec<SysvarRent, SysvarRent>;
}

/// Fetches the `Rent` sysvar account using the provided RPC client.
Future<SysvarRent> fetchSysvarRent(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarRentAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarRentDecoder(),
  );
  return decoded.data;
}
