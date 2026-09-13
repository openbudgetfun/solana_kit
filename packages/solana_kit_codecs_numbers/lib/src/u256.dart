import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// The maximum unsigned 256-bit value: 2^256 - 1.
final BigInt _u256Max = (BigInt.one << 256) - BigInt.one;

/// Creates a [FixedSizeEncoder] for unsigned 256-bit integers (u256).
///
/// Encodes a [BigInt] value as 32 bytes. The value must be in the range
/// [0, 2^256 - 1]. Defaults to little-endian byte order.
FixedSizeEncoder<BigInt> getU256Encoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<BigInt>(
    fixedSize: 32,
    write: (value, bytes, offset) {
      assertBigIntIsBetweenForCodec('u256', BigInt.zero, _u256Max, value);
      writeBigIntUnsigned(bytes, offset, 32, value, endian);
      return offset + 32;
    },
  );
}

/// Creates a [FixedSizeDecoder] for unsigned 256-bit integers (u256).
///
/// Decodes 32 bytes as a [BigInt] in the range [0, 2^256 - 1]. Defaults to
/// little-endian byte order.
FixedSizeDecoder<BigInt> getU256Decoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<BigInt>(
    fixedSize: 32,
    read: (bytes, offset) {
      return (readBigIntUnsigned(bytes, offset, 32, endian), offset + 32);
    },
  );
}

/// Creates a [FixedSizeCodec] for unsigned 256-bit integers (u256).
///
/// Combines [getU256Encoder] and [getU256Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<BigInt, BigInt> getU256Codec([NumberCodecConfig? config]) =>
    combineCodec(getU256Encoder(config), getU256Decoder(config))
        as FixedSizeCodec<BigInt, BigInt>;
