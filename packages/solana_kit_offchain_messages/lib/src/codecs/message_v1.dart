import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/codecs/preamble_v1.dart';
import 'package:solana_kit_offchain_messages/src/message.dart';
import 'package:solana_kit_offchain_messages/src/signatory.dart';

/// Returns a variable-size decoder for [OffchainMessageV1].
///
/// Throws if the message bytes represent a version other than 1 or if the
/// content is empty.
Decoder<OffchainMessageV1> getOffchainMessageV1Decoder() {
  return transformDecoder<List<Object?>, OffchainMessageV1>(
    getTupleDecoder([
      getOffchainMessageV1PreambleDecoder() as Decoder<Object?>,
      getUtf8Decoder() as Decoder<Object?>,
    ]),
    (tuple, Uint8List bytes, int offset) {
      final preamble = tuple[0]! as Map<String, Object?>;
      final text = tuple[1]! as String;

      if (text.isEmpty) {
        throw SolanaError(SolanaErrorCode.offchainMessageMessageMustBeNonEmpty);
      }

      final requiredSignatories =
          preamble['requiredSignatories']! as List<OffchainMessageSignatory>;

      return OffchainMessageV1(
        content: text,
        requiredSignatories: List<OffchainMessageSignatory>.unmodifiable(
          requiredSignatories,
        ),
      );
    },
  );
}

/// Returns a variable-size encoder for [OffchainMessageV1].
Encoder<OffchainMessageV1> getOffchainMessageV1Encoder() {
  return transformEncoder<List<Object?>, OffchainMessageV1>(
    getTupleEncoder([
      getOffchainMessageV1PreambleEncoder() as Encoder<Object?>,
      getUtf8Encoder() as Encoder<Object?>,
    ]),
    (offchainMessage) {
      if (offchainMessage.content.isEmpty) {
        throw SolanaError(SolanaErrorCode.offchainMessageMessageMustBeNonEmpty);
      }
      final preamble = <String, Object?>{
        'version': offchainMessage.version,
        'requiredSignatories': offchainMessage.requiredSignatories,
      };
      return [preamble, offchainMessage.content];
    },
  );
}

/// Returns a codec for [OffchainMessageV1].
Codec<OffchainMessageV1, OffchainMessageV1> getOffchainMessageV1Codec() {
  return combineCodec(
    getOffchainMessageV1Encoder(),
    getOffchainMessageV1Decoder(),
  );
}
