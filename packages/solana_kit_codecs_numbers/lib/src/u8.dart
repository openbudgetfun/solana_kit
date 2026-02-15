import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_numbers/src/utils.dart';

/// Creates a [FixedSizeEncoder] for unsigned 8-bit integers (u8).
///
/// Encodes a [num] value as a single byte. The value must be in the range
/// [0, 255].
FixedSizeEncoder<num> getU8Encoder() => numberEncoderFactory(
  name: 'u8',
  size: 1,
  set: (data, offset, value, _) => data.setUint8(offset, value.toInt()),
  range: (0, 255),
);

/// Creates a [FixedSizeDecoder] for unsigned 8-bit integers (u8).
///
/// Decodes a single byte as an [int] in the range [0, 255].
FixedSizeDecoder<int> getU8Decoder() => numberDecoderFactory(
  name: 'u8',
  size: 1,
  get: (data, offset, _) => data.getUint8(offset),
);

/// Creates a [FixedSizeCodec] for unsigned 8-bit integers (u8).
///
/// Combines [getU8Encoder] and [getU8Decoder].
FixedSizeCodec<num, int> getU8Codec() =>
    combineCodec(getU8Encoder(), getU8Decoder()) as FixedSizeCodec<num, int>;
