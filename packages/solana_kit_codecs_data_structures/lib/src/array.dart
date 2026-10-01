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

/// Whether the sentinel of a [SentinelArraySize] strategy is written when
/// encoding and required when decoding.
///
/// This mirrors the `sentinelCountStrategy` enumeration of Codama's
/// `sentinelCountNode`.
///
/// - [SentinelCountStrategy.required] — The sentinel is written after the
///   last item and must be present when decoding. Reaching the end of the
///   byte array without it is an error. This is the default.
/// - [SentinelCountStrategy.optional] — The sentinel is written after the
///   last item; when decoding, it is consumed if present but the collection
///   may also end at the end of the byte array. Use this to tolerate tightly
///   sized or legacy data that lacks the sentinel.
/// - [SentinelCountStrategy.omitted] — The sentinel is never written; when
///   decoding, it is consumed if present and the collection also ends at the
///   end of the byte array. Only meaningful when the collection is followed
///   by unused space or the end of the byte array.
///
/// Under [SentinelCountStrategy.optional] and
/// [SentinelCountStrategy.omitted], the sentinel must be no wider than the
/// smallest possible item (see the constraints on [SentinelArraySize]).
///
/// Added in @solana/kit v8.4.0.
enum SentinelCountStrategy {
  /// The sentinel is written after the last item and must be present when
  /// decoding. Reaching the end of the byte array without it is an error.
  /// This is the default.
  required,

  /// The sentinel is written after the last item; when decoding, it is
  /// consumed if present but the collection may also end at the end of the
  /// byte array. Use this to tolerate tightly sized or legacy data that
  /// lacks the sentinel.
  optional,

  /// The sentinel is never written; when decoding, it is consumed if present
  /// and the collection also ends at the end of the byte array. Only
  /// meaningful when the collection is followed by unused space or the end
  /// of the byte array.
  omitted,
}

/// A size strategy for array-like codecs where the collection ends when the
/// bytes at the next item position match a constant [sentinel], compared at
/// item boundaries only.
///
/// Unlike a codec wrapped with `addCodecSentinel`, the sentinel is never
/// searched for within an item's bytes, so its bytes may occur _inside_ an
/// item without terminating the collection. This mirrors Codama's
/// `sentinelCountNode`.
///
/// Because the sentinel is only compared at the start of the next item slot,
/// two invariants must hold for the collection to round-trip correctly. The
/// codec does **not** enforce them — like Codama's `sentinelCountNode`, it is
/// the caller's (or IDL author's) responsibility to guarantee them:
///
/// 1. **No item may _begin_ with the sentinel's bytes.** A valid item that
///    starts with the sentinel is indistinguishable from the terminator, so
///    decoding would stop early at that item. The sentinel may still appear
///    _inside_ an item, just never at its start. For instance, a single
///    `0xff` byte is a poor sentinel for a list of public keys: roughly one
///    key in 256 starts with `0xff`, so such a key would prematurely
///    terminate the list. A sentinel as wide as an item — for instance the
///    all-zero (default) public key — avoids this, since only that exact key
///    can ever match the terminator.
/// 2. Under [SentinelCountStrategy.optional] and
///    [SentinelCountStrategy.omitted], the sentinel must be no wider than
///    the smallest possible item. Otherwise a trailing region shorter than
///    the sentinel but large enough to hold a valid item would be skipped:
///    decoding stops as soon as fewer bytes than the sentinel remain, so
///    that final item would never be read. This cannot arise under
///    [SentinelCountStrategy.required] because a terminator is always
///    written.
///
/// Added in @solana/kit v8.4.0.
class SentinelArraySize extends ArrayLikeCodecSize {
  /// Creates a sentinel array size with the given [sentinel] bytes and
  /// [strategy].
  const SentinelArraySize(
    this.sentinel, {
    this.strategy = SentinelCountStrategy.required,
  });

  /// The fixed-size constant compared against the bytes at each item
  /// position.
  ///
  /// No valid item may begin with these bytes, and under the
  /// [SentinelCountStrategy.optional] / [SentinelCountStrategy.omitted]
  /// strategies this must be no wider than the smallest possible item. See
  /// the class documentation for the full constraints.
  final Uint8List sentinel;

  /// Whether the sentinel is written when encoding and required when
  /// decoding.
  final SentinelCountStrategy strategy;
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
  _assertValidArrayLikeSize(effectiveSize);
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
      final prefixObject = prefixedSize.prefix;
      if (prefixObject is Encoder<BigInt>) {
        // Sized prefixes wider than 32 bits (e.g. u64) are
        // generated as `BigInt` encoders, so the item count
        // must be widened to `BigInt` before writing.
        offset = prefixObject.write(BigInt.from(array.length), bytes, offset);
      } else if (prefixObject is Encoder<num>) {
        offset = prefixObject.write(array.length, bytes, offset);
      }
    }
    for (final value in array) {
      offset = item.write(value, bytes, offset);
    }
    if (effectiveSize case final SentinelArraySize sentinelSize
        when sentinelSize.strategy != SentinelCountStrategy.omitted) {
      bytes.setAll(offset, sentinelSize.sentinel);
      offset += sentinelSize.sentinel.length;
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
    getSizeFromValue: (array) {
      var prefixSize = 0;
      if (effectiveSize case final PrefixedArraySize prefixedSize) {
        final prefixObject = prefixedSize.prefix;
        prefixSize = prefixObject is Encoder<BigInt>
            ? getEncodedSize(BigInt.from(array.length), prefixObject)
            : getEncodedSize(array.length, prefixObject as Encoder<num>);
      }
      var suffixSize = 0;
      if (effectiveSize case final SentinelArraySize sentinelSize
          when sentinelSize.strategy != SentinelCountStrategy.omitted) {
        suffixSize = sentinelSize.sentinel.length;
      }
      var itemsSize = 0;
      for (final value in array) {
        itemsSize += getEncodedSize(value, item);
      }
      return prefixSize + suffixSize + itemsSize;
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
  int maxItems = 1000000,
  bool requireSizePrefix = true,
}) {
  if (maxItems < 0) {
    throw ArgumentError.value(maxItems, 'maxItems', 'must not be negative');
  }

  final effectiveSize = size ?? PrefixedArraySize(getU32Decoder());
  _assertValidArrayLikeSize(effectiveSize);
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

    if (effectiveSize is PrefixedArraySize && offset >= bytes.length) {
      // Upstream `@solana/kit` decodes an exhausted byte array as an empty
      // collection so arrays can be appended to existing layouts. This port
      // throws unless the caller opts out, because a silently empty
      // collection hides truncated input.
      if (requireSizePrefix) {
        _throwInvalidArraySize(description, 'missing size prefix');
      }
      return (array, offset);
    }

    if (effectiveSize is RemainderArraySize) {
      while (offset < bytes.length) {
        final (value, newOffset) = item.read(bytes, offset);

        // Security: a remainder decoder must consume input on every item.
        // Otherwise malformed input can make this loop grow without bound.
        if (newOffset <= offset) {
          _throwInvalidArraySize(description, newOffset - offset);
        }

        offset = newOffset;
        array.add(value);
      }
      return (array, offset);
    }

    if (effectiveSize case final SentinelArraySize sentinelSize) {
      final sentinel = sentinelSize.sentinel;
      while (true) {
        if (offset + sentinel.length > bytes.length) {
          // Not enough bytes remain to hold the sentinel.
          if (sentinelSize.strategy == SentinelCountStrategy.required) {
            throw SolanaError(
              SolanaErrorCode.codecsSentinelMissingAtEndOfBytes,
              {
                'codecDescription': description ?? 'array',
                'hexSentinel': _hexBytes(sentinel),
                'sentinel': sentinel,
              },
            );
          }
          return (array, offset);
        }
        if (containsBytes(bytes, sentinel, offset)) {
          // The sentinel is present; consume it and stop.
          return (array, offset + sentinel.length);
        }
        final (value, newOffset) = item.read(bytes, offset);

        // Security: like the remainder branch, every item must consume at
        // least one byte or malformed input could loop forever.
        if (newOffset <= offset) {
          _throwInvalidArraySize(description, newOffset - offset);
        }

        offset = newOffset;
        array.add(value);
      }
    }

    final int resolvedSize;
    if (effectiveSize case final FixedArraySize fixedSize) {
      resolvedSize = fixedSize.size;
    } else {
      final prefixedSize = effectiveSize as PrefixedArraySize;
      final prefixObject = prefixedSize.prefix;
      int resolvedSizeLocal;
      if (prefixObject is Decoder<BigInt>) {
        final (prefixValue, newOffset) = prefixObject.read(bytes, offset);
        if (prefixValue < BigInt.zero || prefixValue > BigInt.from(maxItems)) {
          _throwInvalidArraySize(description, prefixValue);
        }
        resolvedSizeLocal = prefixValue.toInt();
        offset = newOffset;
      } else {
        final prefix = prefixObject as Decoder<num>;
        final (prefixValue, newOffset) = prefix.read(bytes, offset);
        if (!prefixValue.isFinite ||
            prefixValue != prefixValue.truncate() ||
            prefixValue < 0 ||
            prefixValue > maxItems) {
          _throwInvalidArraySize(description, prefixValue);
        }
        resolvedSizeLocal = prefixValue.toInt();
        offset = newOffset;
      }
      resolvedSize = resolvedSizeLocal;
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
  int maxItems = 1000000,
  bool requireSizePrefix = true,
}) {
  // Determine matching encoder/decoder size configs.
  final ArrayLikeCodecSize? encoderSize;
  final ArrayLikeCodecSize? decoderSize;
  if (size case final PrefixedArraySize prefixedSize) {
    final prefix = prefixedSize.prefix;
    if (prefix is Codec<BigInt, BigInt>) {
      // `BigInt` is not a `num`, so wide integer codecs need a separate
      // branch before the standard numeric codec path.
      encoderSize = PrefixedArraySize(encoderFromCodec(prefix));
      decoderSize = PrefixedArraySize(decoderFromCodec(prefix));
    } else if (prefix is Codec<num, num>) {
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
      maxItems: maxItems,
      requireSizePrefix: requireSizePrefix,
    ),
  );
}

Never _throwInvalidArraySize(String? description, Object actual) {
  throw SolanaError(SolanaErrorCode.codecsInvalidNumberOfItems, {
    'codecDescription': description ?? 'array',
    'expected': 'an integer between 0 and the configured maximum',
    'actual': actual,
  });
}

/// Throws if an array-like size strategy is misconfigured — e.g. a sentinel
/// that can never delimit a collection.
void _assertValidArrayLikeSize(ArrayLikeCodecSize size) {
  if (size case final SentinelArraySize sentinelSize
      when sentinelSize.sentinel.isEmpty) {
    throw SolanaError(SolanaErrorCode.codecsSentinelMustNotBeEmpty);
  }
}

String _hexBytes(Uint8List bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

int? _computeArrayLikeCodecSize(ArrayLikeCodecSize size, int? itemSize) {
  if (size case final FixedArraySize fixedSize) {
    if (fixedSize.size == 0) return 0;
    if (itemSize == null) return null;
    return itemSize * fixedSize.size;
  }
  return null;
}
