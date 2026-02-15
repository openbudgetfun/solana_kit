import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/codecs/application_domain.dart';
import 'package:solana_kit_offchain_messages/src/codecs/content_format.dart';
import 'package:solana_kit_offchain_messages/src/codecs/preamble_common.dart';
import 'package:solana_kit_offchain_messages/src/signatory.dart';

/// Returns a variable-size decoder for the v0 offchain message preamble.
Decoder<Map<String, Object?>> getOffchainMessageV0PreambleDecoder() {
  return createOffchainMessagePreambleDecoder(0, [
    (
      'applicationDomain',
      getOffchainMessageApplicationDomainDecoder() as Decoder<Object?>,
    ),
    (
      'messageFormat',
      getOffchainMessageContentFormatDecoder() as Decoder<Object?>,
    ),
    (
      'requiredSignatories',
      transformDecoder<List<Object?>, List<OffchainMessageSignatory>>(
            getArrayDecoder(
              getAddressDecoder() as Decoder<Object?>,
              size: PrefixedArraySize(getU8Decoder()),
            ),
            (signatoryAddresses, Uint8List bytes, int offset) {
              final addresses = signatoryAddresses.cast<Address>();
              if (addresses.isEmpty) {
                throw SolanaError(
                  SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
                );
              }
              return addresses
                  .map((address) => OffchainMessageSignatory(address: address))
                  .toList();
            },
          )
          as Decoder<Object?>,
    ),
    ('messageLength', getU16Decoder() as Decoder<Object?>),
  ]);
}

/// Returns a variable-size encoder for the v0 offchain message preamble.
Encoder<Map<String, Object?>> getOffchainMessageV0PreambleEncoder() {
  return createOffchainMessagePreambleEncoder(0, [
    (
      'applicationDomain',
      getOffchainMessageApplicationDomainEncoder() as Encoder<Object?>,
    ),
    (
      'messageFormat',
      getOffchainMessageContentFormatEncoder() as Encoder<Object?>,
    ),
    (
      'requiredSignatories',
      transformEncoder<List<Address>, List<OffchainMessageSignatory>>(
            getArrayEncoder(
              getAddressEncoder() as Encoder<Address>,
              size: PrefixedArraySize(getU8Encoder()),
            ),
            (signatories) {
              if (signatories.isEmpty) {
                throw SolanaError(
                  SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
                );
              }
              return signatories.map((s) => s.address).toList();
            },
          )
          as Encoder<Object?>,
    ),
    ('messageLength', getU16Encoder() as Encoder<Object?>),
  ]);
}
