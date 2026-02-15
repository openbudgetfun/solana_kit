import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/codecs/message_v0.dart';
import 'package:solana_kit_offchain_messages/src/codecs/message_v1.dart';
import 'package:solana_kit_offchain_messages/src/codecs/signing_domain.dart';
import 'package:solana_kit_offchain_messages/src/message.dart';

/// Returns a variable-size decoder for [OffchainMessage] that dispatches
/// to the appropriate version-specific decoder.
Decoder<OffchainMessage> getOffchainMessageDecoder() {
  return VariableSizeDecoder<OffchainMessage>(
    read: (Uint8List bytes, int offset) {
      // Read the version (after the 16-byte signing domain).
      final version = getHiddenPrefixDecoder(getU8Decoder() as Decoder<int>, [
        getOffchainMessageSigningDomainDecoder(),
      ]).decode(bytes, offset);

      switch (version) {
        case 0:
          return getOffchainMessageV0Decoder().read(bytes, offset);
        case 1:
          return getOffchainMessageV1Decoder().read(bytes, offset);
        default:
          throw SolanaError(
            SolanaErrorCode.offchainMessageVersionNumberNotSupported,
            {'unsupportedVersion': version},
          );
      }
    },
  );
}

/// Returns a variable-size encoder for [OffchainMessage] that dispatches
/// to the appropriate version-specific encoder.
Encoder<OffchainMessage> getOffchainMessageEncoder() {
  return VariableSizeEncoder<OffchainMessage>(
    getSizeFromValue: (OffchainMessage offchainMessage) {
      return switch (offchainMessage) {
        OffchainMessageV0() =>
          (getOffchainMessageV0Encoder()
                  as VariableSizeEncoder<OffchainMessageV0>)
              .getSizeFromValue(offchainMessage),
        OffchainMessageV1() =>
          (getOffchainMessageV1Encoder()
                  as VariableSizeEncoder<OffchainMessageV1>)
              .getSizeFromValue(offchainMessage),
      };
    },
    write: (OffchainMessage offchainMessage, Uint8List bytes, int offset) {
      return switch (offchainMessage) {
        OffchainMessageV0() => getOffchainMessageV0Encoder().write(
          offchainMessage,
          bytes,
          offset,
        ),
        OffchainMessageV1() => getOffchainMessageV1Encoder().write(
          offchainMessage,
          bytes,
          offset,
        ),
      };
    },
  );
}

/// Returns a codec for [OffchainMessage].
Codec<OffchainMessage, OffchainMessage> getOffchainMessageCodec() {
  return combineCodec(getOffchainMessageEncoder(), getOffchainMessageDecoder());
}
