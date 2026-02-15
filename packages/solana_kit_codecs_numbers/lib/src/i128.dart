import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// The minimum signed 128-bit value: -(2^127).
final BigInt _i128Min = -BigInt.parse('170141183460469231731687303715884105728');

/// The maximum signed 128-bit value: 2^127 - 1.
final BigInt _i128Max = BigInt.parse('170141183460469231731687303715884105727');

/// Creates a [FixedSizeEncoder] for signed 128-bit integers (i128).
///
/// Encodes a [BigInt] value as 16 bytes using two's complement
/// representation. The value must be in the range [-(2^127), 2^127 - 1].
/// Defaults to little-endian byte order.
FixedSizeEncoder<BigInt> getI128Encoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<BigInt>(
    fixedSize: 16,
    write: (value, bytes, offset) {
      assertBigIntIsBetweenForCodec('i128', _i128Min, _i128Max, value);
      writeBigIntSigned(bytes, offset, 16, value, endian);
      return offset + 16;
    },
  );
}

/// Creates a [FixedSizeDecoder] for signed 128-bit integers (i128).
///
/// Decodes 16 bytes as a [BigInt] in the range [-(2^127), 2^127 - 1] using
/// two's complement representation. Defaults to little-endian byte order.
FixedSizeDecoder<BigInt> getI128Decoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<BigInt>(
    fixedSize: 16,
    read: (bytes, offset) {
      return (readBigIntSigned(bytes, offset, 16, endian), offset + 16);
    },
  );
}

/// Creates a [FixedSizeCodec] for signed 128-bit integers (i128).
///
/// Combines [getI128Encoder] and [getI128Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<BigInt, BigInt> getI128Codec([NumberCodecConfig? config]) =>
    combineCodec(getI128Encoder(config), getI128Decoder(config))
        as FixedSizeCodec<BigInt, BigInt>;
