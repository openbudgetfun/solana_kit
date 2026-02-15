import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Represents an integer value denominated in Lamports (ie. 1e-9 SOL).
///
/// It is represented as a [BigInt] in client code and a `u64` in server code.
extension type const Lamports(BigInt value) implements Object {}

/// Largest possible value to be represented by a u64.
final BigInt _maxU64Value = BigInt.parse('18446744073709551615'); // 2^64 - 1

/// Memoized U64 encoder/decoder instances.
FixedSizeEncoder<BigInt>? _memoizedU64Encoder;
FixedSizeDecoder<BigInt>? _memoizedU64Decoder;

FixedSizeEncoder<BigInt> _getMemoizedU64Encoder() {
  return _memoizedU64Encoder ??= getU64Encoder();
}

FixedSizeDecoder<BigInt> _getMemoizedU64Decoder() {
  return _memoizedU64Decoder ??= getU64Decoder();
}

/// Returns `true` if [putativeLamports] is within the valid range for
/// [Lamports] (0 to 2^64-1).
bool isLamports(BigInt putativeLamports) {
  return putativeLamports >= BigInt.zero && putativeLamports <= _maxU64Value;
}

/// Asserts that [putativeLamports] is a valid number of [Lamports].
///
/// Throws a [SolanaError] with code [SolanaErrorCode.lamportsOutOfRange] if
/// the value is negative or exceeds the u64 maximum.
void assertIsLamports(BigInt putativeLamports) {
  if (putativeLamports < BigInt.zero || putativeLamports > _maxU64Value) {
    throw SolanaError(SolanaErrorCode.lamportsOutOfRange);
  }
}

/// Combines asserting that a [BigInt] is a possible number of [Lamports]
/// with coercing it to the [Lamports] type. It's best used with untrusted
/// input.
Lamports lamports(BigInt putativeLamports) {
  assertIsLamports(putativeLamports);
  return Lamports(putativeLamports);
}

/// Returns a fixed-size encoder that encodes a 64-bit [Lamports] value to
/// 8 bytes in little endian order.
FixedSizeEncoder<Lamports> getDefaultLamportsEncoder() {
  return _lamportsEncoderForBigInt(_getMemoizedU64Encoder())
      as FixedSizeEncoder<Lamports>;
}

/// Returns an encoder that encodes a [Lamports] value to a byte array using
/// the provided [innerEncoder].
///
/// The inner encoder determines how the numeric value is encoded. It can be
/// an encoder for [BigInt] (e.g. u64) or [num] (e.g. u8, u16).
Encoder<Lamports> getLamportsEncoder(Encoder<Object?> innerEncoder) {
  if (innerEncoder is Encoder<BigInt>) {
    return _lamportsEncoderForBigInt(innerEncoder);
  }
  return _lamportsEncoderForNum(innerEncoder as Encoder<num>);
}

Encoder<Lamports> _lamportsEncoderForBigInt(Encoder<BigInt> innerEncoder) {
  return transformEncoder<BigInt, Lamports>(innerEncoder, (l) => l.value);
}

Encoder<Lamports> _lamportsEncoderForNum(Encoder<num> innerEncoder) {
  return switch (innerEncoder) {
    FixedSizeEncoder<num>() => FixedSizeEncoder<Lamports>(
      fixedSize: innerEncoder.fixedSize,
      write: (value, bytes, offset) =>
          innerEncoder.write(value.value.toInt(), bytes, offset),
    ),
    VariableSizeEncoder<num>() => VariableSizeEncoder<Lamports>(
      getSizeFromValue: (value) =>
          innerEncoder.getSizeFromValue(value.value.toInt()),
      write: (value, bytes, offset) =>
          innerEncoder.write(value.value.toInt(), bytes, offset),
      maxSize: innerEncoder.maxSize,
    ),
  };
}

/// Returns a fixed-size decoder that decodes a byte array representing a
/// 64-bit little endian number to a [Lamports] value.
FixedSizeDecoder<Lamports> getDefaultLamportsDecoder() {
  return _lamportsDecoderForBigInt(_getMemoizedU64Decoder())
      as FixedSizeDecoder<Lamports>;
}

/// Returns a decoder that converts an array of bytes representing a number
/// to a [Lamports] value using the provided [innerDecoder].
///
/// The inner decoder determines how many bits are used to decode the numeric
/// value. It can be a decoder for [BigInt] (e.g. u64) or [int] (e.g. u8,
/// u16).
Decoder<Lamports> getLamportsDecoder(Decoder<Object?> innerDecoder) {
  if (innerDecoder is Decoder<BigInt>) {
    return _lamportsDecoderForBigInt(innerDecoder);
  }
  return _lamportsDecoderForInt(innerDecoder as Decoder<int>);
}

Decoder<Lamports> _lamportsDecoderForBigInt(Decoder<BigInt> innerDecoder) {
  return transformDecoder<BigInt, Lamports>(
    innerDecoder,
    (value, bytes, offset) => lamports(value),
  );
}

Decoder<Lamports> _lamportsDecoderForInt(Decoder<int> innerDecoder) {
  return switch (innerDecoder) {
    FixedSizeDecoder<int>() => FixedSizeDecoder<Lamports>(
      fixedSize: innerDecoder.fixedSize,
      read: (Uint8List bytes, int offset) {
        final (value, newOffset) = innerDecoder.read(bytes, offset);
        return (lamports(BigInt.from(value)), newOffset);
      },
    ),
    VariableSizeDecoder<int>() => VariableSizeDecoder<Lamports>(
      read: (Uint8List bytes, int offset) {
        final (value, newOffset) = innerDecoder.read(bytes, offset);
        return (lamports(BigInt.from(value)), newOffset);
      },
      maxSize: innerDecoder.maxSize,
    ),
  };
}

/// Returns a fixed-size codec that encodes from or decodes to a 64-bit
/// [Lamports] value.
FixedSizeCodec<Lamports, Lamports> getDefaultLamportsCodec() {
  return combineCodec(getDefaultLamportsEncoder(), getDefaultLamportsDecoder())
      as FixedSizeCodec<Lamports, Lamports>;
}

/// Returns a codec that encodes from or decodes to a [Lamports] value using
/// the provided [innerCodec].
///
/// The inner codec can be for [BigInt] (e.g. u64) or [num]/[int] (e.g. u8,
/// u16).
Codec<Lamports, Lamports> getLamportsCodec(Object innerCodec) {
  if (innerCodec is Codec<BigInt, BigInt>) {
    return _lamportsCodecForBigInt(innerCodec);
  }
  // For num/int codecs (u8, u16, u32, etc.)
  final codec = innerCodec as Codec<num, int>;
  return _lamportsCodecForNum(codec);
}

Codec<Lamports, Lamports> _lamportsCodecForBigInt(
  Codec<BigInt, BigInt> innerCodec,
) {
  return switch (innerCodec) {
    FixedSizeCodec<BigInt, BigInt>() => FixedSizeCodec<Lamports, Lamports>(
      fixedSize: innerCodec.fixedSize,
      write: (value, bytes, offset) =>
          innerCodec.write(value.value, bytes, offset),
      read: (Uint8List bytes, int offset) {
        final (value, newOffset) = innerCodec.read(bytes, offset);
        return (lamports(value), newOffset);
      },
    ),
    VariableSizeCodec<BigInt, BigInt>() =>
      VariableSizeCodec<Lamports, Lamports>(
        getSizeFromValue: (value) => innerCodec.getSizeFromValue(value.value),
        write: (value, bytes, offset) =>
            innerCodec.write(value.value, bytes, offset),
        read: (Uint8List bytes, int offset) {
          final (value, newOffset) = innerCodec.read(bytes, offset);
          return (lamports(value), newOffset);
        },
        maxSize: innerCodec.maxSize,
      ),
  };
}

Codec<Lamports, Lamports> _lamportsCodecForNum(Codec<num, int> innerCodec) {
  return switch (innerCodec) {
    FixedSizeCodec<num, int>() => FixedSizeCodec<Lamports, Lamports>(
      fixedSize: innerCodec.fixedSize,
      write: (value, bytes, offset) =>
          innerCodec.write(value.value.toInt(), bytes, offset),
      read: (Uint8List bytes, int offset) {
        final (value, newOffset) = innerCodec.read(bytes, offset);
        return (lamports(BigInt.from(value)), newOffset);
      },
    ),
    VariableSizeCodec<num, int>() => VariableSizeCodec<Lamports, Lamports>(
      getSizeFromValue: (value) =>
          innerCodec.getSizeFromValue(value.value.toInt()),
      write: (value, bytes, offset) =>
          innerCodec.write(value.value.toInt(), bytes, offset),
      read: (Uint8List bytes, int offset) {
        final (value, newOffset) = innerCodec.read(bytes, offset);
        return (lamports(BigInt.from(value)), newOffset);
      },
      maxSize: innerCodec.maxSize,
    ),
  };
}
