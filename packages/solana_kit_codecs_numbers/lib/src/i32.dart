import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for signed 32-bit integers (i32).
///
/// Encodes a [num] value as 4 bytes. The value must be in the range
/// [-2147483648, 2147483647]. Defaults to little-endian byte order.
FixedSizeEncoder<num> getI32Encoder([NumberCodecConfig? config]) =>
    numberEncoderFactory(
      name: 'i32',
      size: 4,
      set: (data, offset, value, endian) =>
          data.setInt32(offset, value.toInt(), endian),
      config: config,
      range: (-2147483648, 2147483647),
    );

/// Creates a [FixedSizeDecoder] for signed 32-bit integers (i32).
///
/// Decodes 4 bytes as an [int] in the range [-2147483648, 2147483647].
/// Defaults to little-endian byte order.
FixedSizeDecoder<int> getI32Decoder([NumberCodecConfig? config]) =>
    numberDecoderFactory(
      name: 'i32',
      size: 4,
      get: (data, offset, endian) => data.getInt32(offset, endian),
      config: config,
    );

/// Creates a [FixedSizeCodec] for signed 32-bit integers (i32).
///
/// Combines [getI32Encoder] and [getI32Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<num, int> getI32Codec([NumberCodecConfig? config]) =>
    combineCodec(getI32Encoder(config), getI32Decoder(config))
        as FixedSizeCodec<num, int>;
