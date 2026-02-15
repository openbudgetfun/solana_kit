import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for 32-bit IEEE 754 floating-point numbers
/// (f32).
///
/// Encodes a [num] value as 4 bytes. No range validation is performed.
/// Defaults to little-endian byte order.
FixedSizeEncoder<num> getF32Encoder([NumberCodecConfig? config]) =>
    numberEncoderFactory(
      name: 'f32',
      size: 4,
      set: (data, offset, value, endian) =>
          data.setFloat32(offset, value.toDouble(), endian),
      config: config,
    );

/// Creates a [FixedSizeDecoder] for 32-bit IEEE 754 floating-point numbers
/// (f32).
///
/// Decodes 4 bytes as a [double]. Defaults to little-endian byte order.
FixedSizeDecoder<double> getF32Decoder([NumberCodecConfig? config]) =>
    floatDecoderFactory(
      name: 'f32',
      size: 4,
      get: (data, offset, endian) => data.getFloat32(offset, endian),
      config: config,
    );

/// Creates a [FixedSizeCodec] for 32-bit IEEE 754 floating-point numbers
/// (f32).
///
/// Combines [getF32Encoder] and [getF32Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<num, double> getF32Codec([NumberCodecConfig? config]) =>
    combineCodec(getF32Encoder(config), getF32Decoder(config))
        as FixedSizeCodec<num, double>;
