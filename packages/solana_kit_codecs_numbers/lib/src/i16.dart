import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for signed 16-bit integers (i16).
///
/// Encodes an [int] value as 2 bytes. The value must be in the range
/// [-32768, 32767]. Defaults to little-endian byte order.
FixedSizeEncoder<int> getI16Encoder([NumberCodecConfig? config]) =>
    numberEncoderFactory<int>(
      name: 'i16',
      size: 2,
      set: (data, offset, value, endian) =>
          data.setInt16(offset, value, endian),
      config: config,
      range: (-32768, 32767),
    );

/// Creates a [FixedSizeDecoder] for signed 16-bit integers (i16).
///
/// Decodes 2 bytes as an [int] in the range [-32768, 32767]. Defaults to
/// little-endian byte order.
FixedSizeDecoder<int> getI16Decoder([NumberCodecConfig? config]) =>
    numberDecoderFactory(
      name: 'i16',
      size: 2,
      get: (data, offset, endian) => data.getInt16(offset, endian),
      config: config,
    );

/// Creates a [FixedSizeCodec] for signed 16-bit integers (i16).
///
/// Combines [getI16Encoder] and [getI16Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<int, int> getI16Codec([NumberCodecConfig? config]) =>
    combineCodec(getI16Encoder(config), getI16Decoder(config))
        as FixedSizeCodec<int, int>;
