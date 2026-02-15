import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/array.dart';
import 'package:solana_kit_codecs_data_structures/src/tuple.dart';

/// Returns an encoder for maps.
///
/// This encoder serializes maps where the keys and values are encoded
/// using the provided [key] and [value] encoders. The number of entries
/// is determined by the [size] configuration (defaults to u32 prefix).
Encoder<Map<K, V>> getMapEncoder<K, V>(
  Encoder<K> key,
  Encoder<V> value, {
  ArrayLikeCodecSize? size,
}) {
  final tupleEncoder = getTupleEncoder([
    key as Encoder<Object?>,
    value as Encoder<Object?>,
  ]);
  final arrayEncoder = getArrayEncoder<List<Object?>>(tupleEncoder, size: size);
  return transformEncoder<List<List<Object?>>, Map<K, V>>(
    arrayEncoder,
    (Map<K, V> map) =>
        map.entries.map((e) => <Object?>[e.key, e.value]).toList(),
  );
}

/// Returns a decoder for maps.
///
/// This decoder deserializes maps where the keys and values are decoded
/// using the provided [key] and [value] decoders. The number of entries
/// is determined by the [size] configuration (defaults to u32 prefix).
Decoder<Map<K, V>> getMapDecoder<K, V>(
  Decoder<K> key,
  Decoder<V> value, {
  ArrayLikeCodecSize? size,
}) {
  final tupleDecoder = getTupleDecoder([
    key as Decoder<Object?>,
    value as Decoder<Object?>,
  ]);
  final arrayDecoder = getArrayDecoder<List<Object?>>(tupleDecoder, size: size);
  return transformDecoder<List<List<Object?>>, Map<K, V>>(arrayDecoder, (
    List<List<Object?>> entries,
    Uint8List bytes,
    int offset,
  ) {
    final map = <K, V>{};
    for (final entry in entries) {
      map[entry[0] as K] = entry[1] as V;
    }
    return map;
  });
}

/// Returns a codec for encoding and decoding maps.
///
/// This codec serializes maps where the key/value pairs are encoded
/// and decoded using the provided [key] and [value] codecs. Defaults to
/// a u32 size prefix.
Codec<Map<K, V>, Map<K, V>> getMapCodec<K, V>(
  Codec<K, K> key,
  Codec<V, V> value, {
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
    getMapEncoder<K, V>(
      encoderFromCodec(key),
      encoderFromCodec(value),
      size: encoderSize,
    ),
    getMapDecoder<K, V>(
      decoderFromCodec(key),
      decoderFromCodec(value),
      size: decoderSize,
    ),
  );
}
