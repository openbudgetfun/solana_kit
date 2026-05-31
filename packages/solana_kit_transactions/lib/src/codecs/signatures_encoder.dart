import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// Extracts the list of [SignatureBytes] to encode from a signatures map.
///
/// Null signatures are replaced with 64 zero bytes.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionCannotEncodeWithEmptySignatures] if the
/// signatures map is empty.
List<Uint8List> _getSignaturesToEncode(
  Map<Address, SignatureBytes?> signaturesMap,
) {
  final signatures = signaturesMap.values.toList();
  if (signatures.isEmpty) {
    throw SolanaError(
      SolanaErrorCode.transactionCannotEncodeWithEmptySignatures,
    );
  }

  return signatures.map((signature) {
    if (signature == null) {
      return Uint8List(64);
    }
    return signature.value;
  }).toList();
}

/// Signatures encoder for legacy and v0 transactions, which encode signatures
/// as an array with a shortU16 size prefix.
VariableSizeEncoder<Map<Address, SignatureBytes?>>
getSignaturesEncoderWithSizePrefix() {
  return transformEncoder<List<Uint8List>, Map<Address, SignatureBytes?>>(
        getArrayEncoder(
          fixEncoderSize(getBytesEncoder(), 64) as Encoder<Uint8List>,
          size: PrefixedArraySize(getShortU16Encoder()),
        ),
        _getSignaturesToEncode,
      )
      as VariableSizeEncoder<Map<Address, SignatureBytes?>>;
}

/// Signatures encoder for v1 transactions, which encode signatures as a
/// known-size array with no size prefix.
FixedSizeEncoder<Map<Address, SignatureBytes?>> getSignaturesEncoderWithLength(
  int size,
) {
  return transformEncoder<List<Uint8List>, Map<Address, SignatureBytes?>>(
        getArrayEncoder(
          fixEncoderSize(getBytesEncoder(), 64) as Encoder<Uint8List>,
          size: FixedArraySize(size),
          description: 'signatures',
        ),
        _getSignaturesToEncode,
      )
      as FixedSizeEncoder<Map<Address, SignatureBytes?>>;
}
