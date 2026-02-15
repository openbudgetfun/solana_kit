import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/boolean.dart';
import 'package:solana_kit_codecs_data_structures/src/constant.dart';
import 'package:solana_kit_codecs_data_structures/src/unit.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';

/// Specifies how `null` values are represented in the encoded data.
sealed class NoneValue {
  /// Creates a [NoneValue].
  const NoneValue();
}

/// `null` values are omitted from encoding (the default).
class OmitNoneValue extends NoneValue {
  /// Creates an omit none value.
  const OmitNoneValue();
}

/// The bytes allocated for the value are filled with zeroes.
/// This requires a fixed-size codec.
class ZeroesNoneValue extends NoneValue {
  /// Creates a zeroes none value.
  const ZeroesNoneValue();
}

/// `null` values are replaced with a predefined byte sequence.
class ConstantNoneValue extends NoneValue {
  /// Creates a constant none value.
  const ConstantNoneValue(this.bytes);

  /// The byte sequence used to represent `null`.
  final Uint8List bytes;
}

/// Returns an encoder for optional (nullable) values.
///
/// By default, a `u8` boolean prefix is used (0 = `null`, 1 = present).
/// The [prefix] parameter allows customizing the number encoder for the
/// prefix, or disabling it entirely by setting [hasPrefix] to `false`.
/// The [noneValue] parameter controls how `null` is represented.
Encoder<T?> getNullableEncoder<T>(
  Encoder<T> item, {
  Encoder<num>? prefix,
  bool hasPrefix = true,
  NoneValue noneValue = const OmitNoneValue(),
}) {
  // Build the prefix encoder.
  final Encoder<bool> prefixEncoder;
  if (!hasPrefix) {
    prefixEncoder = transformEncoder<void, bool>(getUnitEncoder(), (_) {});
  } else {
    prefixEncoder = getBooleanEncoder(size: prefix);
  }

  // Build the none value encoder.
  final Encoder<void> noneEncoder;
  final int? noneEncoderFixedSize;
  if (noneValue is ZeroesNoneValue) {
    assertIsFixedSize(item);
    final itemSize = (item as FixedSizeEncoder<T>).fixedSize;
    noneEncoderFixedSize = itemSize;
    noneEncoder = fixEncoderSize(getUnitEncoder(), itemSize);
  } else if (noneValue is ConstantNoneValue) {
    noneEncoderFixedSize = noneValue.bytes.length;
    noneEncoder = getConstantEncoder(noneValue.bytes);
  } else {
    noneEncoderFixedSize = 0;
    noneEncoder = getUnitEncoder();
  }

  // Calculate sizes.
  final prefixFixedSize = getFixedSize(prefixEncoder);
  final itemFixedSize = getFixedSize(item);

  // Determine if this is a fixed-size or variable-size encoder.
  // Fixed if: all components are fixed AND both branches have the same size.
  final int? totalFixedSize;
  if (prefixFixedSize != null &&
      itemFixedSize != null &&
      noneEncoderFixedSize == itemFixedSize) {
    totalFixedSize = prefixFixedSize + itemFixedSize;
  } else {
    totalFixedSize = null;
  }

  int writeImpl(T? value, Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    if (value == null) {
      offset = prefixEncoder.write(false, bytes, offset);
      offset = noneEncoder.write(null, bytes, offset);
    } else {
      offset = prefixEncoder.write(true, bytes, offset);
      offset = item.write(value, bytes, offset);
    }
    return offset;
  }

  if (totalFixedSize != null) {
    return FixedSizeEncoder<T?>(fixedSize: totalFixedSize, write: writeImpl);
  }

  return VariableSizeEncoder<T?>(
    getSizeFromValue: (T? value) {
      if (value == null) {
        return getEncodedSize(false, prefixEncoder) +
            getEncodedSize(null, noneEncoder);
      }
      return getEncodedSize(true, prefixEncoder) + getEncodedSize(value, item);
    },
    write: writeImpl,
  );
}

/// Returns a decoder for optional (nullable) values.
///
/// By default, a `u8` boolean prefix is used (0 = `null`, 1 = present).
Decoder<T?> getNullableDecoder<T>(
  Decoder<T> item, {
  Decoder<num>? prefix,
  bool hasPrefix = true,
  NoneValue noneValue = const OmitNoneValue(),
}) {
  // Build the prefix decoder.
  final Decoder<bool> prefixDecoder;
  if (!hasPrefix) {
    prefixDecoder = transformDecoder<void, bool>(
      getUnitDecoder(),
      (_, __, ___) => false,
    );
  } else {
    prefixDecoder = getBooleanDecoder(size: prefix);
  }

  // Build the none value decoder.
  final Decoder<void> noneDecoder;
  final int? noneFixedSize;
  if (noneValue is ZeroesNoneValue) {
    assertIsFixedSize(item);
    final size = (item as FixedSizeDecoder<T>).fixedSize;
    noneFixedSize = size;
    noneDecoder = fixDecoderSize(getUnitDecoder(), size);
  } else if (noneValue is ConstantNoneValue) {
    noneFixedSize = noneValue.bytes.length;
    noneDecoder = getConstantDecoder(noneValue.bytes);
  } else {
    noneFixedSize = 0;
    noneDecoder = getUnitDecoder();
  }

  // Calculate sizes.
  final prefixFixedSize = getFixedSize(prefixDecoder);
  final itemFixedSize = getFixedSize(item);

  final int? totalFixedSize;
  if (prefixFixedSize != null &&
      itemFixedSize != null &&
      noneFixedSize == itemFixedSize) {
    totalFixedSize = prefixFixedSize + itemFixedSize;
  } else {
    totalFixedSize = null;
  }

  (T?, int) readImpl(Uint8List bytes, int currentOffset) {
    var offset = currentOffset;
    final bool isPresent;
    if (!hasPrefix && noneValue is OmitNoneValue) {
      isPresent = offset < bytes.length;
    } else if (!hasPrefix && noneValue is! OmitNoneValue) {
      final Uint8List zeroValue;
      if (noneValue is ZeroesNoneValue) {
        zeroValue = Uint8List(noneFixedSize!);
      } else {
        zeroValue = (noneValue as ConstantNoneValue).bytes;
      }
      isPresent = !containsBytes(bytes, zeroValue, offset);
    } else {
      final (boolValue, newOffset) = prefixDecoder.read(bytes, offset);
      isPresent = boolValue;
      offset = newOffset;
    }

    if (!isPresent) {
      final (_, newOffset) = noneDecoder.read(bytes, offset);
      return (null, newOffset);
    }

    final (value, newOffset) = item.read(bytes, offset);
    return (value, newOffset);
  }

  if (totalFixedSize != null) {
    return FixedSizeDecoder<T?>(fixedSize: totalFixedSize, read: readImpl);
  }

  return VariableSizeDecoder<T?>(read: readImpl);
}

/// Returns a codec for encoding and decoding optional (nullable) values.
///
/// By default, a `u8` boolean prefix is used (0 = `null`, 1 = present).
Codec<T?, T?> getNullableCodec<T>(
  Codec<T, T> item, {
  Codec<num, num>? prefix,
  bool hasPrefix = true,
  NoneValue noneValue = const OmitNoneValue(),
}) {
  return combineCodec(
    getNullableEncoder<T>(
      encoderFromCodec(item),
      prefix: prefix != null ? encoderFromCodec(prefix) : null,
      hasPrefix: hasPrefix,
      noneValue: noneValue,
    ),
    getNullableDecoder<T>(
      decoderFromCodec(item),
      prefix: prefix != null ? decoderFromCodec(prefix) : null,
      hasPrefix: hasPrefix,
      noneValue: noneValue,
    ),
  );
}
