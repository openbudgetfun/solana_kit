import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/src/option.dart';

/// Specifies how [None] values are represented in the encoded data.
sealed class OptionNoneValue {
  /// Creates an [OptionNoneValue].
  const OptionNoneValue();
}

/// [None] values are omitted from encoding (the default).
class OmitOptionNoneValue extends OptionNoneValue {
  /// Creates an omit none value.
  const OmitOptionNoneValue();
}

/// The bytes allocated for the value are filled with zeroes.
/// This requires a fixed-size codec for the item.
class ZeroesOptionNoneValue extends OptionNoneValue {
  /// Creates a zeroes none value.
  const ZeroesOptionNoneValue();
}

/// [None] values are replaced with a predefined byte sequence.
class ConstantOptionNoneValue extends OptionNoneValue {
  /// Creates a constant none value.
  const ConstantOptionNoneValue(this.bytes);

  /// The byte sequence used to represent [None].
  final Uint8List bytes;
}

/// Returns an encoder for optional values using the [Option] type.
///
/// This encoder serializes an [Option] or nullable value using a configurable
/// approach:
/// - By default, a `u8` prefix is used (`0 = None`, `1 = Some`).
/// - If [noneValue] is [ZeroesOptionNoneValue], [None] values are encoded as
///   zeroes.
/// - If [noneValue] is [ConstantOptionNoneValue], [None] values are replaced
///   with the provided constant.
/// - If [hasPrefix] is `false`, no prefix is used.
///
/// The input accepts `Option<TFrom>` or `TFrom?` (via `Object?`) for encoding
/// convenience.
Encoder<Object?> getOptionEncoder<TFrom>(
  Encoder<TFrom> item, {
  Encoder<num>? prefix,
  bool hasPrefix = true,
  OptionNoneValue noneValue = const OmitOptionNoneValue(),
}) {
  // Determine none value size and encoder.
  final int noneValueFixedSize;
  if (noneValue is ZeroesOptionNoneValue) {
    assertIsFixedSize(item);
    noneValueFixedSize = (item as FixedSizeEncoder<TFrom>).fixedSize;
  } else if (noneValue is ConstantOptionNoneValue) {
    noneValueFixedSize = noneValue.bytes.length;
  } else {
    noneValueFixedSize = 0;
  }

  // Determine if the item is fixed-size.
  final itemFixedSize = _getFixedSize(item);

  // Determine overall codec size characteristics.
  final prefixEncoderSize = hasPrefix
      ? _getFixedSize(prefix ?? getU8Encoder())
      : 0;

  // Check if this should be fixed-size:
  // Fixed if all components are fixed AND None + prefix == Some + prefix
  final bool isFixed;
  if (prefixEncoderSize != null &&
      itemFixedSize != null &&
      noneValueFixedSize == itemFixedSize) {
    isFixed = true;
  } else {
    isFixed = false;
  }

  int writeImpl(Object? value, Uint8List bytes, int currentOffset) {
    var pos = currentOffset;
    final option = _toOption<TFrom>(value);
    final actualPrefix = prefix ?? getU8Encoder();

    if (isNone(option)) {
      // Write prefix (0 = None).
      if (hasPrefix) {
        pos = actualPrefix.write(0, bytes, pos);
      }
      // Write none value.
      if (noneValue is ZeroesOptionNoneValue) {
        // Write zeroes for the item's fixed size.
        for (var i = 0; i < noneValueFixedSize; i++) {
          bytes[pos + i] = 0;
        }
        pos += noneValueFixedSize;
      } else if (noneValue is ConstantOptionNoneValue) {
        bytes.setAll(pos, noneValue.bytes);
        pos += noneValue.bytes.length;
      }
      // OmitOptionNoneValue: write nothing extra.
      return pos;
    }

    // Some case.
    final someValue = (option as Some<TFrom>).value;
    if (hasPrefix) {
      pos = actualPrefix.write(1, bytes, pos);
    }
    return item.write(someValue, bytes, pos);
  }

  if (isFixed) {
    final totalFixedSize = (prefixEncoderSize ?? 0) + itemFixedSize!;
    return FixedSizeEncoder<Object?>(
      fixedSize: totalFixedSize,
      write: writeImpl,
    );
  }

  return VariableSizeEncoder<Object?>(
    getSizeFromValue: (Object? value) {
      final option = _toOption<TFrom>(value);
      if (isNone(option)) {
        final pSize = hasPrefix
            ? getEncodedSize(0, prefix ?? getU8Encoder())
            : 0;
        return pSize + noneValueFixedSize;
      }
      final someValue = (option as Some<TFrom>).value;
      final pSize = hasPrefix ? getEncodedSize(1, prefix ?? getU8Encoder()) : 0;
      return pSize + getEncodedSize(someValue, item);
    },
    write: writeImpl,
    maxSize: _computeMaxSize(
      hasPrefix ? (prefix ?? getU8Encoder()) : null,
      item,
      noneValueFixedSize,
    ),
  );
}

/// Returns a decoder for optional values using the [Option] type.
///
/// This decoder deserializes an `Option<TTo>` value using a configurable
/// approach:
/// - By default, a `u8` prefix is used (`0 = None`, `1 = Some`).
/// - If [noneValue] is [ZeroesOptionNoneValue], [None] values are identified
///   by zeroes.
/// - If [noneValue] is [ConstantOptionNoneValue], [None] values match the
///   provided constant.
/// - If [hasPrefix] is `false`, no prefix is used.
Decoder<Option<TTo>> getOptionDecoder<TTo>(
  Decoder<TTo> item, {
  Decoder<num>? prefix,
  bool hasPrefix = true,
  OptionNoneValue noneValue = const OmitOptionNoneValue(),
}) {
  // Determine prefix size.
  final int? prefixDecoderSize;
  if (!hasPrefix) {
    prefixDecoderSize = 0;
  } else {
    prefixDecoderSize = _getFixedSize(prefix ?? getU8Decoder());
  }

  // Determine none value size.
  final int noneValueFixedSize;
  if (noneValue is ZeroesOptionNoneValue) {
    assertIsFixedSize(item);
    noneValueFixedSize = (item as FixedSizeDecoder<TTo>).fixedSize;
  } else if (noneValue is ConstantOptionNoneValue) {
    noneValueFixedSize = noneValue.bytes.length;
  } else {
    noneValueFixedSize = 0;
  }

  // Determine if the item is fixed-size.
  final itemFixedSize = _getFixedSize(item);

  // Check if this should be fixed-size.
  final bool isFixed;
  if (prefixDecoderSize != null &&
      itemFixedSize != null &&
      noneValueFixedSize == itemFixedSize) {
    isFixed = true;
  } else {
    isFixed = false;
  }

  (Option<TTo>, int) readImpl(Uint8List bytes, int currentOffset) {
    var pos = currentOffset;
    final actualPrefix = prefix ?? getU8Decoder();

    // Determine if the value is present.
    final bool isPresent;
    if (!hasPrefix && noneValue is OmitOptionNoneValue) {
      // No prefix, no none value: present if there are bytes left.
      isPresent = pos < bytes.length;
    } else if (!hasPrefix && noneValue is! OmitOptionNoneValue) {
      // No prefix, but has none value: compare bytes.
      final Uint8List zeroValue;
      if (noneValue is ZeroesOptionNoneValue) {
        zeroValue = Uint8List(noneValueFixedSize);
      } else {
        zeroValue = (noneValue as ConstantOptionNoneValue).bytes;
      }
      isPresent = !containsBytes(bytes, zeroValue, pos);
    } else {
      // Has prefix: read it.
      final (prefixValue, newOffset) = actualPrefix.read(bytes, pos);
      isPresent = prefixValue.toInt() != 0;
      pos = newOffset;
    }

    if (!isPresent) {
      // Skip the none value bytes.
      pos += noneValueFixedSize;
      return (none<TTo>(), pos);
    }

    final (value, newOffset) = item.read(bytes, pos);
    return (some(value), newOffset);
  }

  if (isFixed) {
    final totalFixedSize = (prefixDecoderSize ?? 0) + itemFixedSize!;
    return FixedSizeDecoder<Option<TTo>>(
      fixedSize: totalFixedSize,
      read: readImpl,
    );
  }

  return VariableSizeDecoder<Option<TTo>>(read: readImpl);
}

/// Returns a codec for encoding and decoding optional values using the
/// [Option] type.
///
/// This codec serializes and deserializes `Option<T>` values.
///
/// See [getOptionEncoder] and [getOptionDecoder] for details on
/// configuration options.
Codec<Object?, Option<TTo>> getOptionCodec<TFrom, TTo extends TFrom>(
  Codec<TFrom, TTo> item, {
  Codec<num, num>? prefix,
  bool hasPrefix = true,
  OptionNoneValue noneValue = const OmitOptionNoneValue(),
}) {
  final encoder = getOptionEncoder<TFrom>(
    encoderFromCodec(item),
    prefix: prefix != null ? encoderFromCodec(prefix) : null,
    hasPrefix: hasPrefix,
    noneValue: noneValue,
  );
  final decoder = getOptionDecoder<TTo>(
    decoderFromCodec(item),
    prefix: prefix != null ? decoderFromCodec(prefix) : null,
    hasPrefix: hasPrefix,
    noneValue: noneValue,
  );

  // Determine sizes to construct the right codec type.
  final encoderIsFixed = isFixedSize(encoder);
  final decoderIsFixed = isFixedSize(decoder);

  if (encoderIsFixed && decoderIsFixed) {
    final enc = encoder as FixedSizeEncoder<Object?>;
    return FixedSizeCodec<Object?, Option<TTo>>(
      fixedSize: enc.fixedSize,
      write: encoder.write,
      read: decoder.read,
    );
  }

  final maxSize = encoder is VariableSizeEncoder<Object?>
      ? encoder.maxSize
      : null;

  return VariableSizeCodec<Object?, Option<TTo>>(
    getSizeFromValue: (Object? value) {
      if (encoder case VariableSizeEncoder<Object?>()) {
        return encoder.getSizeFromValue(value);
      }
      return (encoder as FixedSizeEncoder<Object?>).fixedSize;
    },
    write: encoder.write,
    read: decoder.read,
    maxSize: maxSize,
  );
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// Converts an input value to an [Option].
///
/// Accepts [Option<TFrom>], `TFrom?`, or `null`.
Option<TFrom> _toOption<TFrom>(Object? value) {
  if (value is Option<TFrom>) return value;
  if (value == null) return none<TFrom>();
  // Treat as a raw value (TFrom).
  return some(value as TFrom);
}

/// Returns the fixed size of a codec, encoder, or decoder, or `null` if it
/// is variable-size.
int? _getFixedSize(Object codec) {
  if (codec is FixedSizeEncoder) return codec.fixedSize;
  if (codec is FixedSizeDecoder) return codec.fixedSize;
  if (codec is FixedSizeCodec) return codec.fixedSize;
  return null;
}

/// Computes the max size for a variable-size option codec.
int? _computeMaxSize(
  Encoder<num>? prefix,
  Object itemCodec,
  int noneValueSize,
) {
  // Get prefix max.
  final int prefixMax;
  if (prefix == null) {
    prefixMax = 0;
  } else if (prefix is FixedSizeEncoder<num>) {
    prefixMax = prefix.fixedSize;
  } else if (prefix is VariableSizeEncoder<num>) {
    if (prefix.maxSize == null) return null;
    prefixMax = prefix.maxSize!;
  } else {
    return null;
  }

  // Get item max.
  final int itemMax;
  if (itemCodec is FixedSizeEncoder) {
    itemMax = itemCodec.fixedSize;
  } else if (itemCodec is VariableSizeEncoder) {
    if (itemCodec.maxSize == null) return null;
    itemMax = itemCodec.maxSize!;
  } else if (itemCodec is FixedSizeDecoder) {
    itemMax = itemCodec.fixedSize;
  } else if (itemCodec is VariableSizeDecoder) {
    if (itemCodec.maxSize == null) return null;
    itemMax = itemCodec.maxSize!;
  } else {
    return null;
  }

  // Max is the larger of the two branches:
  // Branch 1 (Some): prefix + item
  // Branch 2 (None): prefix + noneValue
  final someSize = prefixMax + itemMax;
  final noneSize = prefixMax + noneValueSize;
  return someSize > noneSize ? someSize : noneSize;
}
