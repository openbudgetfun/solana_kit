import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for signed 8-bit integers (i8).
///
/// Encodes a [num] value as a single byte. The value must be in the range
/// [-128, 127].
FixedSizeEncoder<num> getI8Encoder() => numberEncoderFactory(
  name: 'i8',
  size: 1,
  set: (data, offset, value, _) => data.setInt8(offset, value.toInt()),
  range: (-128, 127),
);

/// Creates a [FixedSizeDecoder] for signed 8-bit integers (i8).
///
/// Decodes a single byte as an [int] in the range [-128, 127].
FixedSizeDecoder<int> getI8Decoder() => numberDecoderFactory(
  name: 'i8',
  size: 1,
  get: (data, offset, _) => data.getInt8(offset),
);

/// Creates a [FixedSizeCodec] for signed 8-bit integers (i8).
///
/// Combines [getI8Encoder] and [getI8Decoder].
FixedSizeCodec<num, int> getI8Codec() =>
    combineCodec(getI8Encoder(), getI8Decoder()) as FixedSizeCodec<num, int>;
