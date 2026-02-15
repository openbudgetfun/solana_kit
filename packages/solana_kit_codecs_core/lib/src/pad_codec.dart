import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';
import 'package:solana_kit_codecs_core/src/offset_codec.dart';
import 'package:solana_kit_codecs_core/src/resize_codec.dart';

/// Adds left padding to [encoder], shifting the encoded value forward
/// by [offset] bytes and increasing the encoder size accordingly.
Encoder<T> padLeftEncoder<T>(Encoder<T> encoder, int offset) {
  return offsetEncoder(
    resizeEncoder(encoder, (size) => size + offset),
    OffsetConfig(preOffset: (scope) => scope.preOffset + offset),
  );
}

/// Adds right padding to [encoder], extending the encoded value by
/// [offset] bytes and increasing the encoder size accordingly.
Encoder<T> padRightEncoder<T>(Encoder<T> encoder, int offset) {
  return offsetEncoder(
    resizeEncoder(encoder, (size) => size + offset),
    OffsetConfig(postOffset: (scope) => scope.postOffset + offset),
  );
}

/// Adds left padding to [decoder], shifting the decoding position forward
/// by [offset] bytes and increasing the decoder size accordingly.
Decoder<T> padLeftDecoder<T>(Decoder<T> decoder, int offset) {
  return offsetDecoder(
    resizeDecoder(decoder, (size) => size + offset),
    OffsetConfig(preOffset: (scope) => scope.preOffset + offset),
  );
}

/// Adds right padding to [decoder], extending the post-offset by
/// [offset] bytes and increasing the decoder size accordingly.
Decoder<T> padRightDecoder<T>(Decoder<T> decoder, int offset) {
  return offsetDecoder(
    resizeDecoder(decoder, (size) => size + offset),
    OffsetConfig(postOffset: (scope) => scope.postOffset + offset),
  );
}

/// Adds left padding to [codec], shifting encoding and decoding positions
/// forward by [offset] bytes.
Codec<TFrom, TTo> padLeftCodec<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  int offset,
) {
  return combineCodec(
    padLeftEncoder(encoderFromCodec(codec), offset),
    padLeftDecoder(decoderFromCodec(codec), offset),
  );
}

/// Adds right padding to [codec], extending the encoded/decoded value
/// by [offset] bytes.
Codec<TFrom, TTo> padRightCodec<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  int offset,
) {
  return combineCodec(
    padRightEncoder(encoderFromCodec(codec), offset),
    padRightDecoder(decoderFromCodec(codec), offset),
  );
}
