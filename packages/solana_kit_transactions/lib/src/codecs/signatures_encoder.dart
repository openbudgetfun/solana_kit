import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
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
List<SignatureBytes> _getSignaturesToEncode(
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
      return SignatureBytes(Uint8List(64));
    }
    return signature;
  }).toList();
}

/// Signatures encoder for legacy and v0 transactions, which encode signatures
/// as an array with a shortU16 size prefix.
VariableSizeEncoder<Map<Address, SignatureBytes?>>
getSignaturesEncoderWithSizePrefix() {
  final shortU16Enc = getShortU16Encoder();

  return VariableSizeEncoder<Map<Address, SignatureBytes?>>(
    getSizeFromValue: (signaturesMap) {
      final sigs = _getSignaturesToEncode(signaturesMap);
      final prefixSize = getEncodedSize(sigs.length, shortU16Enc);
      return prefixSize + (sigs.length * 64);
    },
    write: (signaturesMap, bytes, offset) {
      final sigs = _getSignaturesToEncode(signaturesMap);
      var pos = shortU16Enc.write(sigs.length, bytes, offset);
      for (final sig in sigs) {
        bytes.setAll(pos, sig.value);
        pos += 64;
      }
      return pos;
    },
  );
}
