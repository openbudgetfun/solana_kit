import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for unsigned 32-bit integers (u32).
///
/// Encodes a [num] value as 4 bytes. The value must be in the range
/// [0, 4294967295]. Defaults to little-endian byte order.
FixedSizeEncoder<num> getU32Encoder([NumberCodecConfig? config]) =>
    numberEncoderFactory(
      name: 'u32',
      size: 4,
      set: (data, offset, value, endian) =>
          data.setUint32(offset, value.toInt(), endian),
      config: config,
      range: (0, 4294967295),
    );

/// Creates a [FixedSizeDecoder] for unsigned 32-bit integers (u32).
///
/// Decodes 4 bytes as an [int] in the range [0, 4294967295]. Defaults to
/// little-endian byte order.
FixedSizeDecoder<int> getU32Decoder([NumberCodecConfig? config]) =>
    numberDecoderFactory(
      name: 'u32',
      size: 4,
      get: (data, offset, endian) => data.getUint32(offset, endian),
      config: config,
    );

/// Creates a [FixedSizeCodec] for unsigned 32-bit integers (u32).
///
/// Combines [getU32Encoder] and [getU32Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<num, int> getU32Codec([NumberCodecConfig? config]) =>
    combineCodec(getU32Encoder(config), getU32Decoder(config))
        as FixedSizeCodec<num, int>;
