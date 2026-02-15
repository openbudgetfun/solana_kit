import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/src/codecs/preamble_common.dart';
import 'package:solana_kit_offchain_messages/src/codecs/signatures.dart';
import 'package:solana_kit_offchain_messages/src/envelope.dart';

/// Returns a variable-size encoder for [OffchainMessageEnvelope].
Encoder<OffchainMessageEnvelope> getOffchainMessageEnvelopeEncoder() {
  return transformEncoder<Map<String, Object?>, OffchainMessageEnvelope>(
    getStructEncoder([
      ('signatures', getSignaturesEncoder() as Encoder<Object?>),
      ('content', getBytesEncoder() as Encoder<Object?>),
    ]),
    (envelope) {
      final signaturesMapAddresses = envelope.signatures.keys
          .map((a) => a)
          .toList();
      if (signaturesMapAddresses.isEmpty) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageNumEnvelopeSignaturesCannotBeZero,
        );
      }
      final signatoryAddresses = _decodeAndValidateRequiredSignatoryAddresses(
        envelope.content,
      );

      final missingRequiredSigners = <Address>[];
      final unexpectedSigners = <Address>[];
      for (final addr in signatoryAddresses) {
        if (!signaturesMapAddresses.any((a) => a.value == addr.value)) {
          missingRequiredSigners.add(addr);
        }
      }
      for (final addr in signaturesMapAddresses) {
        if (!signatoryAddresses.any((a) => a.value == addr.value)) {
          unexpectedSigners.add(addr);
        }
      }
      if (missingRequiredSigners.isNotEmpty || unexpectedSigners.isNotEmpty) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageEnvelopeSignersMismatch,
          {
            'missingRequiredSigners': missingRequiredSigners
                .map((a) => a.value)
                .toList(),
            'unexpectedSigners': unexpectedSigners.map((a) => a.value).toList(),
          },
        );
      }

      // Order signatures by the order specified in the preamble.
      final orderedSignatureMap = <Address, SignatureBytes?>{};
      for (final addr in signatoryAddresses) {
        final matchingKey = envelope.signatures.keys.firstWhere(
          (k) => k.value == addr.value,
        );
        orderedSignatureMap[matchingKey] = envelope.signatures[matchingKey];
      }

      return {'signatures': orderedSignatureMap, 'content': envelope.content};
    },
  );
}

/// Returns a variable-size decoder for [OffchainMessageEnvelope].
Decoder<OffchainMessageEnvelope> getOffchainMessageEnvelopeDecoder() {
  return transformDecoder<Map<String, Object?>, OffchainMessageEnvelope>(
    getStructDecoder([
      (
        'signatures',
        getArrayDecoder(
              fixDecoderSize(getBytesDecoder(), 64) as Decoder<Object?>,
              size: PrefixedArraySize(getU8Decoder()),
            )
            as Decoder<Object?>,
      ),
      ('content', getBytesDecoder() as Decoder<Object?>),
    ]),
    (decoded, Uint8List bytes, int offset) {
      final signatures = (decoded['signatures']! as List<Object?>)
          .cast<Uint8List>();
      final content = decoded['content']! as Uint8List;

      if (signatures.isEmpty) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageNumEnvelopeSignaturesCannotBeZero,
        );
      }

      final signatoryAddresses = _decodeAndValidateRequiredSignatoryAddresses(
        content,
      );

      if (signatoryAddresses.length != signatures.length) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageNumSignaturesMismatch,
          {
            'numRequiredSignatures': signatoryAddresses.length,
            'signatoryAddresses': signatoryAddresses
                .map((a) => a.value)
                .toList(),
            'signaturesLength': signatures.length,
          },
        );
      }

      final signaturesMap = <Address, SignatureBytes?>{};
      for (var i = 0; i < signatoryAddresses.length; i++) {
        final sigBytes = signatures[i];
        final isAllZero = sigBytes.every((b) => b == 0);
        signaturesMap[signatoryAddresses[i]] = isAllZero
            ? null
            : SignatureBytes(sigBytes);
      }

      return OffchainMessageEnvelope(
        content: content,
        signatures: Map<Address, SignatureBytes?>.unmodifiable(signaturesMap),
      );
    },
  );
}

/// Returns a codec for [OffchainMessageEnvelope].
Codec<OffchainMessageEnvelope, OffchainMessageEnvelope>
getOffchainMessageEnvelopeCodec() {
  return combineCodec(
    getOffchainMessageEnvelopeEncoder(),
    getOffchainMessageEnvelopeDecoder(),
  );
}

List<Address> _decodeAndValidateRequiredSignatoryAddresses(Uint8List bytes) {
  final signatoryAddresses = decodeRequiredSignatoryAddresses(bytes);
  if (signatoryAddresses.isEmpty) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
    );
  }
  return signatoryAddresses;
}
