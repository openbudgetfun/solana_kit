import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';

/// Creates a [FixedSizeEncoder] for a numeric type using [ByteData] operations.
///
/// The [name] is used in error messages.
/// The [size] is the number of bytes the encoder produces.
/// The [set] callback writes a numeric value into a [ByteData] view.
/// The optional [range] constrains accepted values.
/// The optional [config] controls endianness (defaults to little-endian).
FixedSizeEncoder<num> numberEncoderFactory({
  required String name,
  required int size,
  required void Function(ByteData data, int offset, num value, Endian endian)
  set,
  NumberCodecConfig? config,
  (num min, num max)? range,
}) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<num>(
    fixedSize: size,
    write: (value, bytes, offset) {
      if (range != null) {
        assertNumberIsBetweenForCodec(name, range.$1, range.$2, value);
      }
      final byteData = bytes.buffer.asByteData(bytes.offsetInBytes);
      set(byteData, offset, value, endian);
      return offset + size;
    },
  );
}

/// Creates a [FixedSizeDecoder] for a numeric type using [ByteData] operations.
///
/// The [name] is used in error messages.
/// The [size] is the number of bytes the decoder consumes.
/// The [get] callback reads a numeric value from a [ByteData] view.
/// The optional [config] controls endianness (defaults to little-endian).
FixedSizeDecoder<int> numberDecoderFactory({
  required String name,
  required int size,
  required int Function(ByteData data, int offset, Endian endian) get,
  NumberCodecConfig? config,
}) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<int>(
    fixedSize: size,
    read: (bytes, offset) {
      final byteData = bytes.buffer.asByteData(bytes.offsetInBytes);
      return (get(byteData, offset, endian), offset + size);
    },
  );
}

/// Creates a [FixedSizeDecoder] for a floating-point type using [ByteData]
/// operations.
///
/// The [name] is used in error messages.
/// The [size] is the number of bytes the decoder consumes.
/// The [get] callback reads a double value from a [ByteData] view.
/// The optional [config] controls endianness (defaults to little-endian).
FixedSizeDecoder<double> floatDecoderFactory({
  required String name,
  required int size,
  required double Function(ByteData data, int offset, Endian endian) get,
  NumberCodecConfig? config,
}) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<double>(
    fixedSize: size,
    read: (bytes, offset) {
      final byteData = bytes.buffer.asByteData(bytes.offsetInBytes);
      return (get(byteData, offset, endian), offset + size);
    },
  );
}

// ---------------------------------------------------------------------------
// BigInt helpers for 64-bit and 128-bit codecs
// ---------------------------------------------------------------------------

final BigInt _bigIntMask8 = BigInt.from(0xff);

/// Writes an unsigned [BigInt] value to [bytes] starting at [offset],
/// using [size] bytes in the given [endian] byte order.
void writeBigIntUnsigned(
  Uint8List bytes,
  int offset,
  int size,
  BigInt value,
  Endian endian,
) {
  var remaining = value;
  if (endian == Endian.little) {
    for (var i = 0; i < size; i++) {
      bytes[offset + i] = (remaining & _bigIntMask8).toInt();
      remaining >>= 8;
    }
  } else {
    for (var i = size - 1; i >= 0; i--) {
      bytes[offset + i] = (remaining & _bigIntMask8).toInt();
      remaining >>= 8;
    }
  }
}

/// Reads an unsigned [BigInt] value from [bytes] starting at [offset],
/// using [size] bytes in the given [endian] byte order.
BigInt readBigIntUnsigned(
  Uint8List bytes,
  int offset,
  int size,
  Endian endian,
) {
  var result = BigInt.zero;
  if (endian == Endian.little) {
    for (var i = size - 1; i >= 0; i--) {
      result = (result << 8) | BigInt.from(bytes[offset + i]);
    }
  } else {
    for (var i = 0; i < size; i++) {
      result = (result << 8) | BigInt.from(bytes[offset + i]);
    }
  }
  return result;
}

/// Reads a signed [BigInt] value from [bytes] starting at [offset],
/// using [size] bytes in the given [endian] byte order.
///
/// Uses two's complement representation.
BigInt readBigIntSigned(Uint8List bytes, int offset, int size, Endian endian) {
  final unsigned = readBigIntUnsigned(bytes, offset, size, endian);
  final maxPositive = BigInt.one << (size * 8 - 1);
  if (unsigned >= maxPositive) {
    return unsigned - (BigInt.one << (size * 8));
  }
  return unsigned;
}

/// Writes a signed [BigInt] value to [bytes] starting at [offset],
/// using [size] bytes in the given [endian] byte order.
///
/// Uses two's complement representation for negative values.
void writeBigIntSigned(
  Uint8List bytes,
  int offset,
  int size,
  BigInt value,
  Endian endian,
) {
  final unsigned = value < BigInt.zero
      ? value + (BigInt.one << (size * 8))
      : value;
  writeBigIntUnsigned(bytes, offset, size, unsigned, endian);
}
