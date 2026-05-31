import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// Returns an encoder for the signatures portion of an offchain message
/// envelope.
///
/// Each signature is 64 bytes. Missing signatures are encoded as 64 zero
/// bytes.
Encoder<Map<Address, SignatureBytes?>> getSignaturesEncoder() {
  return transformEncoder<List<Uint8List>, Map<Address, SignatureBytes?>>(
    getArrayEncoder(
      fixEncoderSize(getBytesEncoder(), 64) as Encoder<Uint8List>,
      size: PrefixedArraySize(getU8Encoder()),
    ),
    (signaturesMap) {
      final signatures = signaturesMap.values.toList();
      if (signatures.isEmpty) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageNumEnvelopeSignaturesCannotBeZero,
        );
      }

      return signatures.map((sig) {
        if (sig == null) {
          return Uint8List(64);
        }
        return sig.value;
      }).toList();
    },
  );
}
