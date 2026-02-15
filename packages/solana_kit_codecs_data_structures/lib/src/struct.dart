import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';

/// Returns an encoder for custom objects (structs).
///
/// This encoder serializes a `Map<String, Object?>` by encoding its fields
/// sequentially, using the provided field encoders.
///
/// [fields] is a list of `(fieldName, encoder)` pairs.
Encoder<Map<String, Object?>> getStructEncoder(
  List<(String, Encoder<Object?>)> fields,
) {
  final fieldCodecs = fields.map((f) => f.$2).toList();
  final fixedSize = sumCodecSizes(fieldCodecs.map(getFixedSize).toList());
  final maxSize = sumCodecSizes(fieldCodecs.map(getMaxSize).toList());

  int writeImpl(
    Map<String, Object?> struct,
    Uint8List bytes,
    int currentOffset,
  ) {
    var offset = currentOffset;
    for (final (key, codec) in fields) {
      offset = codec.write(struct[key], bytes, offset);
    }
    return offset;
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<Map<String, Object?>>(
      fixedSize: fixedSize,
      write: writeImpl,
    );
  }

  return VariableSizeEncoder<Map<String, Object?>>(
    getSizeFromValue: (Map<String, Object?> struct) {
      var total = 0;
      for (final (key, codec) in fields) {
        total += getEncodedSize(struct[key], codec);
      }
      return total;
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder for custom objects (structs).
///
/// This decoder deserializes a `Map<String, Object?>` by decoding its fields
/// sequentially, using the provided field decoders.
///
/// [fields] is a list of `(fieldName, decoder)` pairs.
Decoder<Map<String, Object?>> getStructDecoder(
  List<(String, Decoder<Object?>)> fields,
) {
  final fieldCodecs = fields.map((f) => f.$2).toList();
  final fixedSize = sumCodecSizes(fieldCodecs.map(getFixedSize).toList());
  final maxSize = sumCodecSizes(fieldCodecs.map(getMaxSize).toList());

  (Map<String, Object?>, int) readImpl(Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    final struct = <String, Object?>{};
    for (final (key, codec) in fields) {
      final (value, newOffset) = codec.read(bytes, offset);
      offset = newOffset;
      struct[key] = value;
    }
    return (struct, offset);
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<Map<String, Object?>>(
      fixedSize: fixedSize,
      read: readImpl,
    );
  }

  return VariableSizeDecoder<Map<String, Object?>>(
    read: readImpl,
    maxSize: maxSize,
  );
}

/// Returns a codec for encoding and decoding custom objects (structs).
///
/// [fields] is a list of `(fieldName, codec)` pairs.
Codec<Map<String, Object?>, Map<String, Object?>> getStructCodec(
  List<(String, Codec<Object?, Object?>)> fields,
) {
  return combineCodec(
    getStructEncoder(
      fields.map((f) => (f.$1, encoderFromCodec(f.$2))).toList(),
    ),
    getStructDecoder(
      fields.map((f) => (f.$1, decoderFromCodec(f.$2))).toList(),
    ),
  );
}
