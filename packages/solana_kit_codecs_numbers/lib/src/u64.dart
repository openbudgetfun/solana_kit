import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// The maximum unsigned 64-bit value: 2^64 - 1.
final BigInt _u64Max = BigInt.parse('18446744073709551615');

/// Creates a [FixedSizeEncoder] for unsigned 64-bit integers (u64).
///
/// Encodes a [BigInt] value as 8 bytes. The value must be in the range
/// [0, 2^64 - 1]. Defaults to little-endian byte order.
FixedSizeEncoder<BigInt> getU64Encoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeEncoder<BigInt>(
    fixedSize: 8,
    write: (value, bytes, offset) {
      assertBigIntIsBetweenForCodec('u64', BigInt.zero, _u64Max, value);
      writeBigIntUnsigned(bytes, offset, 8, value, endian);
      return offset + 8;
    },
  );
}

/// Creates a [FixedSizeDecoder] for unsigned 64-bit integers (u64).
///
/// Decodes 8 bytes as a [BigInt] in the range [0, 2^64 - 1]. Defaults to
/// little-endian byte order.
FixedSizeDecoder<BigInt> getU64Decoder([NumberCodecConfig? config]) {
  final endian = config?.endian ?? Endian.little;
  return FixedSizeDecoder<BigInt>(
    fixedSize: 8,
    read: (bytes, offset) {
      return (readBigIntUnsigned(bytes, offset, 8, endian), offset + 8);
    },
  );
}

/// Creates a [FixedSizeCodec] for unsigned 64-bit integers (u64).
///
/// Combines [getU64Encoder] and [getU64Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<BigInt, BigInt> getU64Codec([NumberCodecConfig? config]) =>
    combineCodec(getU64Encoder(config), getU64Decoder(config))
        as FixedSizeCodec<BigInt, BigInt>;
