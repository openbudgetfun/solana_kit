import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

/// The bytes representing the string `'\xffsolana offchain'`.
final Uint8List offchainMessageSigningDomainBytes = Uint8List.fromList([
  0xff, 0x73, 0x6f, 0x6c, 0x61, 0x6e, 0x61, 0x20, //
  0x6f, 0x66, 0x66, 0x63, 0x68, 0x61, 0x69, 0x6e,
]);

/// Returns a fixed-size decoder that verifies the 16-byte signing domain.
FixedSizeDecoder<void> getOffchainMessageSigningDomainDecoder() {
  return getConstantDecoder(offchainMessageSigningDomainBytes);
}

/// Returns a fixed-size encoder that writes the 16-byte signing domain.
FixedSizeEncoder<void> getOffchainMessageSigningDomainEncoder() {
  return getConstantEncoder(offchainMessageSigningDomainBytes);
}

/// Returns a codec for the 16-byte signing domain.
FixedSizeCodec<void, void> getOffchainMessageSigningDomainCodec() {
  return combineCodec(
        getOffchainMessageSigningDomainEncoder(),
        getOffchainMessageSigningDomainDecoder(),
      )
      as FixedSizeCodec<void, void>;
}
