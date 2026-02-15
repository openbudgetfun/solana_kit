import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for unsigned 16-bit integers (u16).
///
/// Encodes a [num] value as 2 bytes. The value must be in the range
/// [0, 65535]. Defaults to little-endian byte order.
FixedSizeEncoder<num> getU16Encoder([NumberCodecConfig? config]) =>
    numberEncoderFactory(
      name: 'u16',
      size: 2,
      set: (data, offset, value, endian) =>
          data.setUint16(offset, value.toInt(), endian),
      config: config,
      range: (0, 65535),
    );

/// Creates a [FixedSizeDecoder] for unsigned 16-bit integers (u16).
///
/// Decodes 2 bytes as an [int] in the range [0, 65535]. Defaults to
/// little-endian byte order.
FixedSizeDecoder<int> getU16Decoder([NumberCodecConfig? config]) =>
    numberDecoderFactory(
      name: 'u16',
      size: 2,
      get: (data, offset, endian) => data.getUint16(offset, endian),
      config: config,
    );

/// Creates a [FixedSizeCodec] for unsigned 16-bit integers (u16).
///
/// Combines [getU16Encoder] and [getU16Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<num, int> getU16Codec([NumberCodecConfig? config]) =>
    combineCodec(getU16Encoder(config), getU16Decoder(config))
        as FixedSizeCodec<num, int>;
