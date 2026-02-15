import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Returns an encoder for literal unions.
///
/// This encoder serializes a value from a predefined set of [variants]
/// as a numerical index representing its position in the list.
Encoder<Object?> getLiteralUnionEncoder(
  List<Object?> variants, {
  Encoder<num>? size,
}) {
  final discriminator = size ?? getU8Encoder();
  return transformEncoder<num, Object?>(discriminator, (Object? variant) {
    final index = variants.indexOf(variant);
    if (index < 0) {
      throw SolanaError(SolanaErrorCode.codecsInvalidLiteralUnionVariant, {
        'value': variant,
        'variants': variants,
      });
    }
    return index;
  });
}

/// Returns a decoder for literal unions.
///
/// This decoder deserializes a numerical index into a corresponding
/// value from a predefined set of [variants].
Decoder<Object?> getLiteralUnionDecoder(
  List<Object?> variants, {
  Decoder<num>? size,
}) {
  final discriminator = size ?? getU8Decoder();
  return transformDecoder<num, Object?>(discriminator, (
    num index,
    Uint8List bytes,
    int offset,
  ) {
    final i = index.toInt();
    if (i < 0 || i >= variants.length) {
      throw SolanaError(
        SolanaErrorCode.codecsLiteralUnionDiscriminatorOutOfRange,
        {
          'discriminator': index,
          'maxRange': variants.length - 1,
          'minRange': 0,
        },
      );
    }
    return variants[i];
  });
}

/// Returns a codec for encoding and decoding literal unions.
///
/// A literal union codec serializes and deserializes values from a
/// predefined set of [variants], using a numerical index to represent
/// each value.
Codec<Object?, Object?> getLiteralUnionCodec(
  List<Object?> variants, {
  Codec<num, num>? size,
}) {
  return combineCodec(
    getLiteralUnionEncoder(
      variants,
      size: size != null ? encoderFromCodec(size) : null,
    ),
    getLiteralUnionDecoder(
      variants,
      size: size != null ? decoderFromCodec(size) : null,
    ),
  );
}
