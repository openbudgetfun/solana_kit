import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/codecs/preamble_common.dart';
import 'package:solana_kit_offchain_messages/src/signatory.dart';

/// Returns a variable-size decoder for the v1 offchain message preamble.
Decoder<Map<String, Object?>> getOffchainMessageV1PreambleDecoder() {
  return createOffchainMessagePreambleDecoder(1, [
    (
      'requiredSignatories',
      transformDecoder<List<Object?>, List<OffchainMessageSignatory>>(
            getArrayDecoder(
              fixDecoderSize(getBytesDecoder(), 32) as Decoder<Object?>,
              size: PrefixedArraySize(getU8Decoder()),
            ),
            (signatoryAddressesBytes, Uint8List bytes, int offset) {
              final addressBytes = signatoryAddressesBytes.cast<Uint8List>();
              if (addressBytes.isEmpty) {
                throw SolanaError(
                  SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
                );
              }
              // Verify signatories are sorted and unique.
              final comparator = getSignatoriesComparator();
              for (var i = 0; i < addressBytes.length - 1; i++) {
                final cmp = comparator(addressBytes[i], addressBytes[i + 1]);
                if (cmp == 0) {
                  throw SolanaError(
                    SolanaErrorCode.offchainMessageSignatoriesMustBeUnique,
                  );
                }
                if (cmp > 0) {
                  throw SolanaError(
                    SolanaErrorCode.offchainMessageSignatoriesMustBeSorted,
                  );
                }
              }
              final addressDecoder = getAddressDecoder();
              return addressBytes
                  .map(
                    (addrBytes) => OffchainMessageSignatory(
                      address: addressDecoder.decode(addrBytes),
                    ),
                  )
                  .toList();
            },
          )
          as Decoder<Object?>,
    ),
  ]);
}

/// Returns a variable-size encoder for the v1 offchain message preamble.
Encoder<Map<String, Object?>> getOffchainMessageV1PreambleEncoder() {
  return createOffchainMessagePreambleEncoder(1, [
    (
      'requiredSignatories',
      transformEncoder<List<Uint8List>, List<OffchainMessageSignatory>>(
            transformEncoder<List<Uint8List>, List<Uint8List>>(
              getArrayEncoder(
                getBytesEncoder() as Encoder<Uint8List>,
                size: PrefixedArraySize(getU8Encoder()),
              ),
              (signatoryAddressesBytes) {
                final sorted = List<Uint8List>.from(signatoryAddressesBytes)
                  ..sort(getSignatoriesComparator());
                return sorted;
              },
            ),
            (signatories) {
              if (signatories.isEmpty) {
                throw SolanaError(
                  SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero,
                );
              }
              final seenSignatories = <String>{};
              for (final signatory in signatories) {
                if (!seenSignatories.add(signatory.address.value)) {
                  throw SolanaError(
                    SolanaErrorCode.offchainMessageSignatoriesMustBeUnique,
                  );
                }
              }
              final addressEncoder = getAddressEncoder();
              return signatories
                  .map((s) => addressEncoder.encode(s.address))
                  .toList();
            },
          )
          as Encoder<Object?>,
    ),
  ]);
}
