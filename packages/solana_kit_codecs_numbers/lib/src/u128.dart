import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// The maximum unsigned 128-bit value: 2^128 - 1.
final BigInt _u128Max = BigInt.parse('340282366920938463463374607431768211455');

/// Creates a [FixedSizeEncoder] for unsigned 128-bit integers (u128).
///
/// Encodes a [BigInt] value as 16 bytes. The value must be in the range
/// [0, 2^128 - 1]. Defaults to little-endian byte order.
FixedSizeEncoder<BigInt> getU128Encoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<BigInt>(
    fixedSize: 16,
    write: (value, bytes, offset) {
      assertBigIntIsBetweenForCodec('u128', BigInt.zero, _u128Max, value);
      writeBigIntUnsigned(bytes, offset, 16, value, endian);
      return offset + 16;
    },
  );
}

/// Creates a [FixedSizeDecoder] for unsigned 128-bit integers (u128).
///
/// Decodes 16 bytes as a [BigInt] in the range [0, 2^128 - 1]. Defaults to
/// little-endian byte order.
FixedSizeDecoder<BigInt> getU128Decoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<BigInt>(
    fixedSize: 16,
    read: (bytes, offset) {
      return (readBigIntUnsigned(bytes, offset, 16, endian), offset + 16);
    },
  );
}

/// Creates a [FixedSizeCodec] for unsigned 128-bit integers (u128).
///
/// Combines [getU128Encoder] and [getU128Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<BigInt, BigInt> getU128Codec([NumberCodecConfig? config]) =>
    combineCodec(getU128Encoder(config), getU128Decoder(config))
        as FixedSizeCodec<BigInt, BigInt>;
