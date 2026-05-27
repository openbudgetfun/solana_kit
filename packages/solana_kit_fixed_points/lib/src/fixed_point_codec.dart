import 'dart:typed_data';

import 'package:solana_kit_fixed_points/src/binary_fixed_point.dart';
import 'package:solana_kit_fixed_points/src/decimal_fixed_point.dart';

/// Byte order used by fixed-point codecs.
enum FixedPointEndian {
  /// Least-significant byte first.
  little,

  /// Most-significant byte first.
  big,
}

/// Fixed-size encoder for fixed-point values.
final class FixedPointEncoder<T> {
  /// Creates an encoder with [fixedSize] bytes and a [write] function.
  const FixedPointEncoder({required this.fixedSize, required this.write});

  /// The encoded size in bytes.
  final int fixedSize;

  /// Writes a value into a byte buffer and returns the next offset.
  final int Function(T value, Uint8List buffer, int offset) write;

  /// Encodes [value] into a new byte buffer.
  Uint8List encode(T value) {
    final buffer = Uint8List(fixedSize);
    write(value, buffer, 0);
    return buffer;
  }
}

/// Fixed-size decoder for fixed-point values.
final class FixedPointDecoder<T> {
  /// Creates a decoder with [fixedSize] bytes and a [read] function.
  const FixedPointDecoder({required this.fixedSize, required this.read});

  /// The encoded size in bytes.
  final int fixedSize;

  /// Reads a value and the next offset from a byte buffer.
  final (T, int) Function(Uint8List buffer, int offset) read;

  /// Decodes [buffer] from the beginning.
  T decode(Uint8List buffer) => read(buffer, 0).$1;
}

/// Fixed-size codec for fixed-point values.
final class FixedPointCodec<T> {
  /// Creates a codec from an [encoder] and [decoder].
  const FixedPointCodec({required this.encoder, required this.decoder});

  /// The encoder half of this codec.
  final FixedPointEncoder<T> encoder;

  /// The decoder half of this codec.
  final FixedPointDecoder<T> decoder;

  /// The encoded size in bytes.
  int get fixedSize => encoder.fixedSize;

  /// Encodes [value] into a new byte buffer.
  Uint8List encode(T value) => encoder.encode(value);

  /// Decodes [buffer] from the beginning.
  T decode(Uint8List buffer) => decoder.decode(buffer);
}

/// Returns an encoder for [DecimalFixedPoint] values with the given shape.
FixedPointEncoder<DecimalFixedPoint> getDecimalFixedPointEncoder(
  FixedPointSignedness signedness,
  int totalBits,
  int decimals, {
  FixedPointEndian endian = FixedPointEndian.little,
}) {
  _assertValidByteAlignedShape(totalBits);
  if (decimals < 0) throw RangeError.range(decimals, 0, null, 'decimals');
  final byteSize = totalBits ~/ 8;
  return FixedPointEncoder(
    fixedSize: byteSize,
    write: (value, buffer, offset) {
      _assertDecimalShape(value, signedness, totalBits, decimals);
      _writeRawBigInt(value.raw, buffer, offset, byteSize, signedness, endian);
      return offset + byteSize;
    },
  );
}

/// Returns a decoder for [DecimalFixedPoint] values with the given shape.
FixedPointDecoder<DecimalFixedPoint> getDecimalFixedPointDecoder(
  FixedPointSignedness signedness,
  int totalBits,
  int decimals, {
  FixedPointEndian endian = FixedPointEndian.little,
}) {
  _assertValidByteAlignedShape(totalBits);
  if (decimals < 0) throw RangeError.range(decimals, 0, null, 'decimals');
  final byteSize = totalBits ~/ 8;
  return FixedPointDecoder(
    fixedSize: byteSize,
    read: (buffer, offset) {
      _assertReadable(buffer, offset, byteSize);
      final raw = _readRawBigInt(buffer, offset, byteSize, signedness, endian);
      return (
        DecimalFixedPoint(
          raw: raw,
          decimals: decimals,
          signedness: signedness,
          totalBits: totalBits,
        ),
        offset + byteSize,
      );
    },
  );
}

/// Returns a codec for [DecimalFixedPoint] values with the given shape.
FixedPointCodec<DecimalFixedPoint> getDecimalFixedPointCodec(
  FixedPointSignedness signedness,
  int totalBits,
  int decimals, {
  FixedPointEndian endian = FixedPointEndian.little,
}) {
  return FixedPointCodec(
    encoder: getDecimalFixedPointEncoder(
      signedness,
      totalBits,
      decimals,
      endian: endian,
    ),
    decoder: getDecimalFixedPointDecoder(
      signedness,
      totalBits,
      decimals,
      endian: endian,
    ),
  );
}

/// Returns an encoder for [BinaryFixedPoint] values with the given shape.
FixedPointEncoder<BinaryFixedPoint> getBinaryFixedPointEncoder(
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits, {
  FixedPointEndian endian = FixedPointEndian.little,
}) {
  _assertValidByteAlignedShape(totalBits);
  _assertValidFractionalBits(fractionalBits, totalBits);
  final byteSize = totalBits ~/ 8;
  return FixedPointEncoder(
    fixedSize: byteSize,
    write: (value, buffer, offset) {
      _assertBinaryShape(value, signedness, totalBits, fractionalBits);
      _writeRawBigInt(value.raw, buffer, offset, byteSize, signedness, endian);
      return offset + byteSize;
    },
  );
}

/// Returns a decoder for [BinaryFixedPoint] values with the given shape.
FixedPointDecoder<BinaryFixedPoint> getBinaryFixedPointDecoder(
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits, {
  FixedPointEndian endian = FixedPointEndian.little,
}) {
  _assertValidByteAlignedShape(totalBits);
  _assertValidFractionalBits(fractionalBits, totalBits);
  final byteSize = totalBits ~/ 8;
  return FixedPointDecoder(
    fixedSize: byteSize,
    read: (buffer, offset) {
      _assertReadable(buffer, offset, byteSize);
      final raw = _readRawBigInt(buffer, offset, byteSize, signedness, endian);
      return (
        BinaryFixedPoint(
          raw: raw,
          fractionalBits: fractionalBits,
          signedness: signedness,
          totalBits: totalBits,
        ),
        offset + byteSize,
      );
    },
  );
}

/// Returns a codec for [BinaryFixedPoint] values with the given shape.
FixedPointCodec<BinaryFixedPoint> getBinaryFixedPointCodec(
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits, {
  FixedPointEndian endian = FixedPointEndian.little,
}) {
  return FixedPointCodec(
    encoder: getBinaryFixedPointEncoder(
      signedness,
      totalBits,
      fractionalBits,
      endian: endian,
    ),
    decoder: getBinaryFixedPointDecoder(
      signedness,
      totalBits,
      fractionalBits,
      endian: endian,
    ),
  );
}

void _assertDecimalShape(
  DecimalFixedPoint value,
  FixedPointSignedness signedness,
  int totalBits,
  int decimals,
) {
  if (value.signedness != signedness ||
      value.totalBits != totalBits ||
      value.decimals != decimals) {
    throw ArgumentError(
      'Decimal fixed-point shape does not match codec shape.',
    );
  }
}

void _assertBinaryShape(
  BinaryFixedPoint value,
  FixedPointSignedness signedness,
  int totalBits,
  int fractionalBits,
) {
  if (value.signedness != signedness ||
      value.totalBits != totalBits ||
      value.fractionalBits != fractionalBits) {
    throw ArgumentError('Binary fixed-point shape does not match codec shape.');
  }
}

void _assertValidByteAlignedShape(int totalBits) {
  if (totalBits <= 0) throw RangeError.range(totalBits, 1, null, 'totalBits');
  if (totalBits % 8 != 0) {
    throw ArgumentError.value(
      totalBits,
      'totalBits',
      'Expected a multiple of 8.',
    );
  }
}

void _assertValidFractionalBits(int fractionalBits, int totalBits) {
  if (fractionalBits < 0) {
    throw RangeError.range(fractionalBits, 0, null, 'fractionalBits');
  }
  if (fractionalBits > totalBits) {
    throw RangeError.range(fractionalBits, 0, totalBits, 'fractionalBits');
  }
}

void _assertReadable(Uint8List buffer, int offset, int byteSize) {
  if (offset < 0) throw RangeError.range(offset, 0, null, 'offset');
  if (buffer.length - offset < byteSize) {
    throw RangeError(
      'Expected at least $byteSize readable bytes at offset $offset.',
    );
  }
}

void _writeRawBigInt(
  BigInt raw,
  Uint8List buffer,
  int offset,
  int byteSize,
  FixedPointSignedness signedness,
  FixedPointEndian endian,
) {
  _assertReadable(buffer, offset, byteSize);
  var encoded = raw;
  final modulus = BigInt.one << (byteSize * 8);
  if (raw.isNegative) {
    if (signedness == FixedPointSignedness.unsigned) {
      throw RangeError('Cannot encode a negative unsigned fixed-point value.');
    }
    encoded = modulus + raw;
  }
  if (encoded < BigInt.zero || encoded >= modulus) {
    throw RangeError(
      'Raw fixed-point value $raw does not fit in $byteSize bytes.',
    );
  }

  for (var i = 0; i < byteSize; i++) {
    final byte = (encoded >> (8 * i)).toUnsigned(8).toInt();
    final index = endian == FixedPointEndian.little
        ? offset + i
        : offset + byteSize - 1 - i;
    buffer[index] = byte;
  }
}

BigInt _readRawBigInt(
  Uint8List buffer,
  int offset,
  int byteSize,
  FixedPointSignedness signedness,
  FixedPointEndian endian,
) {
  var encoded = BigInt.zero;
  for (var i = 0; i < byteSize; i++) {
    final index = endian == FixedPointEndian.little
        ? offset + i
        : offset + byteSize - 1 - i;
    encoded |= BigInt.from(buffer[index]) << (8 * i);
  }

  if (signedness == FixedPointSignedness.signed) {
    final signBit = BigInt.one << (byteSize * 8 - 1);
    if ((encoded & signBit) != BigInt.zero) {
      return encoded - (BigInt.one << (byteSize * 8));
    }
  }
  return encoded;
}
