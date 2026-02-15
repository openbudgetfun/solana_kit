import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/array.dart';

/// Returns an encoder for sets.
///
/// This encoder serializes [Set<T>] values by encoding each item using the
/// provided [item] encoder. The number of items is stored as a prefix
/// using a `u32` codec by default.
Encoder<Set<T>> getSetEncoder<T>(Encoder<T> item, {ArrayLikeCodecSize? size}) {
  final arrayEncoder = getArrayEncoder<T>(item, size: size);
  return transformEncoder<List<T>, Set<T>>(
    arrayEncoder,
    (Set<T> set) => set.toList(),
  );
}

/// Returns a decoder for sets.
///
/// This decoder deserializes a [Set<T>] from a byte array by decoding
/// each item using the provided [item] decoder. The number of items is
/// determined by a `u32` size prefix by default.
Decoder<Set<T>> getSetDecoder<T>(Decoder<T> item, {ArrayLikeCodecSize? size}) {
  final arrayDecoder = getArrayDecoder<T>(item, size: size);
  return transformDecoder<List<T>, Set<T>>(
    arrayDecoder,
    (List<T> entries, Uint8List bytes, int offset) => entries.toSet(),
  );
}

/// Returns a codec for encoding and decoding sets.
///
/// This codec serializes [Set<T>] values by encoding each item using the
/// provided [item] codec. The number of items is stored as a prefix using
/// a `u32` codec by default.
Codec<Set<T>, Set<T>> getSetCodec<T>(
  Codec<T, T> item, {
  ArrayLikeCodecSize? size,
}) {
  // Split size config for encoder/decoder.
  final ArrayLikeCodecSize? encoderSize;
  final ArrayLikeCodecSize? decoderSize;
  if (size is PrefixedArraySize) {
    final prefix = size.prefix;
    if (prefix is Codec<num, num>) {
      encoderSize = PrefixedArraySize(encoderFromCodec(prefix));
      decoderSize = PrefixedArraySize(decoderFromCodec(prefix));
    } else {
      encoderSize = size;
      decoderSize = size;
    }
  } else {
    encoderSize = size;
    decoderSize = size;
  }

  return combineCodec(
    getSetEncoder<T>(encoderFromCodec(item), size: encoderSize),
    getSetDecoder<T>(decoderFromCodec(item), size: decoderSize),
  );
}
