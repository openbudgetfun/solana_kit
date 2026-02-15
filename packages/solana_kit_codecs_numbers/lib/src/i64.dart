import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// The minimum signed 64-bit value: -(2^63).
final BigInt _i64Min = -BigInt.parse('9223372036854775808');

/// The maximum signed 64-bit value: 2^63 - 1.
final BigInt _i64Max = BigInt.parse('9223372036854775807');

/// Creates a [FixedSizeEncoder] for signed 64-bit integers (i64).
///
/// Encodes a [BigInt] value as 8 bytes using two's complement representation.
/// The value must be in the range [-(2^63), 2^63 - 1]. Defaults to
/// little-endian byte order.
FixedSizeEncoder<BigInt> getI64Encoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<BigInt>(
    fixedSize: 8,
    write: (value, bytes, offset) {
      assertBigIntIsBetweenForCodec('i64', _i64Min, _i64Max, value);
      writeBigIntSigned(bytes, offset, 8, value, endian);
      return offset + 8;
    },
  );
}

/// Creates a [FixedSizeDecoder] for signed 64-bit integers (i64).
///
/// Decodes 8 bytes as a [BigInt] in the range [-(2^63), 2^63 - 1] using
/// two's complement representation. Defaults to little-endian byte order.
FixedSizeDecoder<BigInt> getI64Decoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<BigInt>(
    fixedSize: 8,
    read: (bytes, offset) {
      return (readBigIntSigned(bytes, offset, 8, endian), offset + 8);
    },
  );
}

/// Creates a [FixedSizeCodec] for signed 64-bit integers (i64).
///
/// Combines [getI64Encoder] and [getI64Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<BigInt, BigInt> getI64Codec([NumberCodecConfig? config]) =>
    combineCodec(getI64Encoder(config), getI64Decoder(config))
        as FixedSizeCodec<BigInt, BigInt>;
