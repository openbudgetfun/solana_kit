import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

/// Configuration options for boolean codecs.
///
/// The [size] option allows customizing the number codec used for storage.
/// By default, booleans are stored as a `u8` (1 for `true`, 0 for `false`).
class BooleanCodecConfig {
  /// Creates a boolean codec configuration.
  const BooleanCodecConfig({this.size});

  /// The number codec used to store boolean values.
  ///
  /// By default, a `u8` encoder/decoder is used.
  final Object? size;
}

/// Returns an encoder for boolean values.
///
/// This encoder converts `true` into `1` and `false` into `0`.
/// The `config` option allows customizing the number encoder used for storage.
Encoder<bool> getBooleanEncoder({Encoder<num>? size}) {
  final numberEncoder = size ?? getU8Encoder();
  return transformEncoder<num, bool>(numberEncoder, (bool value) {
    return value ? 1 : 0;
  });
}

/// Returns a decoder for boolean values.
///
/// This decoder reads a number and interprets `1` as `true` and `0` as
/// `false`.
Decoder<bool> getBooleanDecoder({Decoder<num>? size}) {
  final numberDecoder = size ?? getU8Decoder();
  return transformDecoder<num, bool>(numberDecoder, (num value, _, __) {
    return value.toInt() == 1;
  });
}

/// Returns a codec for encoding and decoding boolean values.
///
/// By default, booleans are stored as a `u8` (1 for `true`, 0 for `false`).
Codec<bool, bool> getBooleanCodec({Codec<num, num>? size}) {
  final codec = size ?? getU8Codec();
  return combineCodec(
    getBooleanEncoder(size: encoderFromCodec(codec)),
    getBooleanDecoder(size: decoderFromCodec(codec)),
  );
}
