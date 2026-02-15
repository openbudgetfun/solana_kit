import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/assertions.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';

/// Returns an encoder for tuples (fixed-length lists with heterogeneous item
/// encoders).
///
/// Each item in the tuple is encoded sequentially using its corresponding
/// encoder from [items].
Encoder<List<Object?>> getTupleEncoder(
  List<Encoder<Object?>> items, {
  String? description,
}) {
  final fixedSize = sumCodecSizes(items.map(getFixedSize).toList());
  final maxSize = sumCodecSizes(items.map(getMaxSize).toList());

  int writeImpl(List<Object?> value, Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    assertValidNumberOfItemsForCodec(
      description ?? 'tuple',
      items.length,
      value.length,
    );
    for (var i = 0; i < items.length; i++) {
      offset = items[i].write(value[i], bytes, offset);
    }
    return offset;
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<List<Object?>>(
      fixedSize: fixedSize,
      write: writeImpl,
    );
  }

  return VariableSizeEncoder<List<Object?>>(
    getSizeFromValue: (List<Object?> value) {
      var total = 0;
      for (var i = 0; i < items.length; i++) {
        total += getEncodedSize(value[i], items[i]);
      }
      return total;
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder for tuples (fixed-length lists with heterogeneous item
/// decoders).
///
/// Each item in the tuple is decoded sequentially using its corresponding
/// decoder from [items].
Decoder<List<Object?>> getTupleDecoder(List<Decoder<Object?>> items) {
  final fixedSize = sumCodecSizes(items.map(getFixedSize).toList());
  final maxSize = sumCodecSizes(items.map(getMaxSize).toList());

  (List<Object?>, int) readImpl(Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    final values = <Object?>[];
    for (final item in items) {
      final (value, newOffset) = item.read(bytes, offset);
      values.add(value);
      offset = newOffset;
    }
    return (values, offset);
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<List<Object?>>(
      fixedSize: fixedSize,
      read: readImpl,
    );
  }

  return VariableSizeDecoder<List<Object?>>(read: readImpl, maxSize: maxSize);
}

/// Returns a codec for encoding and decoding tuples.
///
/// Unlike the array codec, each item in the tuple has its own codec
/// and can be of a different type.
Codec<List<Object?>, List<Object?>> getTupleCodec(
  List<Codec<Object?, Object?>> items, {
  String? description,
}) {
  return combineCodec(
    getTupleEncoder(
      items.map(encoderFromCodec).toList(),
      description: description,
    ),
    getTupleDecoder(items.map(decoderFromCodec).toList()),
  );
}
