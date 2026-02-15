import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_offchain_messages/src/application_domain.dart';
import 'package:solana_kit_offchain_messages/src/codecs/preamble_v0.dart';
import 'package:solana_kit_offchain_messages/src/content.dart';
import 'package:solana_kit_offchain_messages/src/message.dart';
import 'package:solana_kit_offchain_messages/src/signatory.dart';

/// Returns a variable-size decoder for [OffchainMessageV0].
///
/// Throws if the message bytes represent a version other than 0 or if the
/// content violates the specified format constraints.
Decoder<OffchainMessageV0> getOffchainMessageV0Decoder() {
  return transformDecoder<List<Object?>, OffchainMessageV0>(
    getTupleDecoder([
      getOffchainMessageV0PreambleDecoder() as Decoder<Object?>,
      getUtf8Decoder() as Decoder<Object?>,
    ]),
    (tuple, Uint8List bytes, int offset) {
      final preamble = tuple[0]! as Map<String, Object?>;
      final text = tuple[1]! as String;

      final messageLength = preamble['messageLength']! as int;
      final messageFormat =
          preamble['messageFormat']! as OffchainMessageContentFormat;
      final requiredSignatories =
          preamble['requiredSignatories']! as List<OffchainMessageSignatory>;
      final applicationDomain =
          preamble['applicationDomain']! as OffchainMessageApplicationDomain;

      final actualLength = utf8.encode(text).length;
      if (messageLength != actualLength) {
        throw SolanaError(
          SolanaErrorCode.offchainMessageMessageLengthMismatch,
          {'actualLength': actualLength, 'specifiedLength': messageLength},
        );
      }

      final content = OffchainMessageContent(format: messageFormat, text: text);

      // Validate the content for the given format.
      switch (messageFormat) {
        case OffchainMessageContentFormat.restrictedAscii1232BytesMax:
          assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(content);
        case OffchainMessageContentFormat.utf81232BytesMax:
          assertIsOffchainMessageContentUtf8Of1232BytesMax(content);
        case OffchainMessageContentFormat.utf865535BytesMax:
          assertIsOffchainMessageContentUtf8Of65535BytesMax(content);
      }

      return OffchainMessageV0(
        applicationDomain: applicationDomain,
        content: content,
        requiredSignatories: List<OffchainMessageSignatory>.unmodifiable(
          requiredSignatories,
        ),
      );
    },
  );
}

/// Returns a variable-size encoder for [OffchainMessageV0].
Encoder<OffchainMessageV0> getOffchainMessageV0Encoder() {
  return transformEncoder<List<Object?>, OffchainMessageV0>(
    getTupleEncoder([
      getOffchainMessageV0PreambleEncoder() as Encoder<Object?>,
      getUtf8Encoder() as Encoder<Object?>,
    ]),
    (offchainMessage) {
      // Validate content.
      switch (offchainMessage.content.format) {
        case OffchainMessageContentFormat.restrictedAscii1232BytesMax:
          assertIsOffchainMessageContentRestrictedAsciiOf1232BytesMax(
            offchainMessage.content,
          );
        case OffchainMessageContentFormat.utf81232BytesMax:
          assertIsOffchainMessageContentUtf8Of1232BytesMax(
            offchainMessage.content,
          );
        case OffchainMessageContentFormat.utf865535BytesMax:
          assertIsOffchainMessageContentUtf8Of65535BytesMax(
            offchainMessage.content,
          );
      }

      final messageLength = utf8.encode(offchainMessage.content.text).length;
      final preamble = <String, Object?>{
        'version': offchainMessage.version,
        'applicationDomain': offchainMessage.applicationDomain,
        'messageFormat': offchainMessage.content.format,
        'requiredSignatories': offchainMessage.requiredSignatories,
        'messageLength': messageLength,
      };
      return [preamble, offchainMessage.content.text];
    },
  );
}

/// Returns a codec for [OffchainMessageV0].
Codec<OffchainMessageV0, OffchainMessageV0> getOffchainMessageV0Codec() {
  return combineCodec(
    getOffchainMessageV0Encoder(),
    getOffchainMessageV0Decoder(),
  );
}
