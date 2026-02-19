import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/assertions.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Determines how the size of an array-like codec is specified.
sealed class ArrayLikeCodecSize {
  /// Creates an [ArrayLikeCodecSize].
  const ArrayLikeCodecSize();
}

/// The array size is prefixed with a number codec.
class PrefixedArraySize extends ArrayLikeCodecSize {
  /// Creates a prefixed array size with the given codec, encoder, or decoder.
  const PrefixedArraySize(this.prefix);

  /// The number codec/encoder/decoder used to encode/decode the size prefix.
  final Object prefix;
}

/// The array has a fixed number of items.
class FixedArraySize extends ArrayLikeCodecSize {
  /// Creates a fixed array size.
  const FixedArraySize(this.size);

  /// The fixed number of items.
  final int size;
}

/// The array size is inferred from remaining bytes (only for fixed-size items).
class RemainderArraySize extends ArrayLikeCodecSize {
  /// Creates a remainder array size.
  const RemainderArraySize();
}

/// Returns an encoder for arrays of values.
///
/// This encoder serializes arrays by encoding each element using the provided
/// [item] encoder. By default, a `u32` size prefix is included to indicate
/// the number of items in the array. The [size] option can be used to modify
/// this behaviour.
Encoder<List<T>> getArrayEncoder<T>(
  Encoder<T> item, {
  ArrayLikeCodecSize? size,
  String? description,
}) {
  final effectiveSize = size ?? PrefixedArraySize(getU32Encoder());
  final itemFixedSize = getFixedSize(item);
  final computedFixed = _computeArrayLikeCodecSize(
    effectiveSize,
    itemFixedSize,
  );

  int writeImpl(List<T> array, Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    if (effectiveSize case final FixedArraySize fixedSize) {
      assertValidNumberOfItemsForCodec(
        description ?? 'array',
        fixedSize.size,
        array.length,
      );
    }
    if (effectiveSize case final PrefixedArraySize prefixedSize) {
      final prefix = prefixedSize.prefix as Encoder<num>;
      offset = prefix.write(array.length, bytes, offset);
    }
    for (final value in array) {
      offset = item.write(value, bytes, offset);
    }
    return offset;
  }

  if (computedFixed != null) {
    return FixedSizeEncoder<List<T>>(
      fixedSize: computedFixed,
      write: writeImpl,
    );
  }

  final itemMaxSize = getMaxSize(item);
  final computedMax = _computeArrayLikeCodecSize(effectiveSize, itemMaxSize);

  return VariableSizeEncoder<List<T>>(
    getSizeFromValue: (List<T> array) {
      var prefixSize = 0;
      if (effectiveSize case final PrefixedArraySize prefixedSize) {
        prefixSize = getEncodedSize(
          array.length,
          prefixedSize.prefix as Encoder<num>,
        );
      }
      var itemsSize = 0;
      for (final value in array) {
        itemsSize += getEncodedSize(value, item);
      }
      return prefixSize + itemsSize;
    },
    write: writeImpl,
    maxSize: computedMax,
  );
}

/// Returns a decoder for arrays of values.
///
/// This decoder deserializes arrays by decoding each element using the
/// provided [item] decoder. By default, a `u32` size prefix is expected to
/// indicate the number of items in the array.
Decoder<List<T>> getArrayDecoder<T>(
  Decoder<T> item, {
  ArrayLikeCodecSize? size,
  String? description,
}) {
  final effectiveSize = size ?? PrefixedArraySize(getU32Decoder());
  final itemFixedSize = getFixedSize(item);
  final computedFixed = _computeArrayLikeCodecSize(
    effectiveSize,
    itemFixedSize,
  );
  final itemMaxSize = getMaxSize(item);
  final computedMax = _computeArrayLikeCodecSize(effectiveSize, itemMaxSize);

  (List<T>, int) readImpl(Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    final array = <T>[];

    // If prefixed and no bytes remain, return empty.
    if (effectiveSize is PrefixedArraySize && bytes.sublist(offset).isEmpty) {
      return (array, offset);
    }

    if (effectiveSize is RemainderArraySize) {
      while (offset < bytes.length) {
        final (value, newOffset) = item.read(bytes, offset);
        offset = newOffset;
        array.add(value);
      }
      return (array, offset);
    }

    final int resolvedSize;
    if (effectiveSize case final FixedArraySize fixedSize) {
      resolvedSize = fixedSize.size;
    } else {
      final prefixedSize = effectiveSize as PrefixedArraySize;
      final prefix = prefixedSize.prefix as Decoder<num>;
      final (prefixValue, newOffset) = prefix.read(bytes, offset);
      resolvedSize = prefixValue.toInt();
      offset = newOffset;
    }

    if (resolvedSize < 0) {
      throw SolanaError(SolanaErrorCode.codecsInvalidNumberOfItems, {
        'codecDescription': description ?? 'array',
        'expected': 0,
        'actual': resolvedSize,
      });
    }

    for (var i = 0; i < resolvedSize; i++) {
      final (value, newOffset) = item.read(bytes, offset);
      offset = newOffset;
      array.add(value);
    }
    return (array, offset);
  }

  if (computedFixed != null) {
    return FixedSizeDecoder<List<T>>(fixedSize: computedFixed, read: readImpl);
  }

  return VariableSizeDecoder<List<T>>(read: readImpl, maxSize: computedMax);
}

/// Returns a codec for encoding and decoding arrays of values.
///
/// This codec serializes arrays by encoding each element using the provided
/// [item] codec. By default, a `u32` size prefix is included.
Codec<List<T>, List<T>> getArrayCodec<T>(
  Codec<T, T> item, {
  ArrayLikeCodecSize? size,
  String? description,
}) {
  // Determine matching encoder/decoder size configs.
  final ArrayLikeCodecSize? encoderSize;
  final ArrayLikeCodecSize? decoderSize;
  if (size case final PrefixedArraySize prefixedSize) {
    final prefix = prefixedSize.prefix;
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
    getArrayEncoder<T>(
      encoderFromCodec(item),
      size: encoderSize,
      description: description,
    ),
    getArrayDecoder<T>(
      decoderFromCodec(item),
      size: decoderSize,
      description: description,
    ),
  );
}

int? _computeArrayLikeCodecSize(ArrayLikeCodecSize size, int? itemSize) {
  if (size case final FixedArraySize fixedSize) {
    if (fixedSize.size == 0) return 0;
    if (itemSize == null) return null;
    return itemSize * fixedSize.size;
  }
  return null;
}
