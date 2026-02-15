import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/common.dart';
import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for 64-bit IEEE 754 floating-point numbers
/// (f64).
///
/// Encodes a [num] value as 8 bytes. No range validation is performed.
/// Defaults to little-endian byte order.
FixedSizeEncoder<num> getF64Encoder([NumberCodecConfig? config]) =>
    numberEncoderFactory(
      name: 'f64',
      size: 8,
      set: (data, offset, value, endian) =>
          data.setFloat64(offset, value.toDouble(), endian),
      config: config,
    );

/// Creates a [FixedSizeDecoder] for 64-bit IEEE 754 floating-point numbers
/// (f64).
///
/// Decodes 8 bytes as a [double]. Defaults to little-endian byte order.
FixedSizeDecoder<double> getF64Decoder([NumberCodecConfig? config]) =>
    floatDecoderFactory(
      name: 'f64',
      size: 8,
      get: (data, offset, endian) => data.getFloat64(offset, endian),
      config: config,
    );

/// Creates a [FixedSizeCodec] for 64-bit IEEE 754 floating-point numbers
/// (f64).
///
/// Combines [getF64Encoder] and [getF64Decoder]. Defaults to little-endian
/// byte order.
FixedSizeCodec<num, double> getF64Codec([NumberCodecConfig? config]) =>
    combineCodec(getF64Encoder(config), getF64Decoder(config))
        as FixedSizeCodec<num, double>;
