import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_offchain_messages/src/content.dart';

/// Returns a fixed-size encoder for [OffchainMessageContentFormat].
FixedSizeEncoder<OffchainMessageContentFormat>
getOffchainMessageContentFormatEncoder() {
  return transformEncoder<num, OffchainMessageContentFormat>(
        getU8Encoder(),
        (format) => format.value,
      )
      as FixedSizeEncoder<OffchainMessageContentFormat>;
}

/// Returns a fixed-size decoder for [OffchainMessageContentFormat].
FixedSizeDecoder<OffchainMessageContentFormat>
getOffchainMessageContentFormatDecoder() {
  return transformDecoder<int, OffchainMessageContentFormat>(
        getU8Decoder(),
        (value, Uint8List bytes, int offset) =>
            OffchainMessageContentFormat.fromValue(value),
      )
      as FixedSizeDecoder<OffchainMessageContentFormat>;
}

/// Returns a codec for [OffchainMessageContentFormat].
FixedSizeCodec<OffchainMessageContentFormat, OffchainMessageContentFormat>
getOffchainMessageContentFormatCodec() {
  return combineCodec(
        getOffchainMessageContentFormatEncoder(),
        getOffchainMessageContentFormatDecoder(),
      )
      as FixedSizeCodec<
        OffchainMessageContentFormat,
        OffchainMessageContentFormat
      >;
}
