import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// The minimum signed 256-bit value: -(2^255).
final BigInt _i256Min = -(BigInt.one << 255);

/// The maximum signed 256-bit value: 2^255 - 1.
final BigInt _i256Max = (BigInt.one << 255) - BigInt.one;

/// Creates a [FixedSizeEncoder] for signed 256-bit integers (i256).
///
/// Encodes a [BigInt] value as 32 bytes using two's complement
/// representation. The value must be in the range [-(2^255), 2^255 - 1].
/// Defaults to little-endian byte order.
FixedSizeEncoder<BigInt> getI256Encoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<BigInt>(
    fixedSize: 32,
    write: (value, bytes, offset) {
      assertBigIntIsBetweenForCodec('i256', _i256Min, _i256Max, value);
      writeBigIntSigned(bytes, offset, 32, value, endian);
      return offset + 32;
    },
  );
}

/// Creates a [FixedSizeDecoder] for signed 256-bit integers (i256).
///
/// Decodes 32 bytes as a [BigInt] in the range [-(2^255), 2^255 - 1] using
/// two's complement representation. Defaults to little-endian byte order.
FixedSizeDecoder<BigInt> getI256Decoder([NumberCodecConfig? config]) {
  return bigIntDecoderFactory(
    name: 'i256',
    size: 32,
    unsigned: false,
    config: config,
  );
}

/// Creates a [FixedSizeCodec] for signed 256-bit integers (i256).
///
/// Combines [getI256Encoder] and [getI256Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<BigInt, BigInt> getI256Codec([NumberCodecConfig? config]) =>
    combineCodec(getI256Encoder(config), getI256Decoder(config))
        as FixedSizeCodec<BigInt, BigInt>;
