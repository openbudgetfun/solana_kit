import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/tuple.dart';

/// Returns an encoder that appends hidden data after the encoded value.
///
/// This encoder applies a list of void encoders after encoding the main
/// value. The suffixed data is encoded after the main value without being
/// exposed to the user.
Encoder<T> getHiddenSuffixEncoder<T>(
  Encoder<T> encoder,
  List<Encoder<void>> suffixedEncoders,
) {
  final allEncoders = <Encoder<Object?>>[
    encoder as Encoder<Object?>,
    ...suffixedEncoders.cast<Encoder<Object?>>(),
  ];
  final tupleEncoder = getTupleEncoder(allEncoders);
  return transformEncoder<List<Object?>, T>(tupleEncoder, (T value) {
    return <Object?>[
      value,
      ...List<Object?>.filled(suffixedEncoders.length, null),
    ];
  });
}

/// Returns a decoder that skips hidden suffixed data after decoding the
/// main value.
///
/// This decoder applies a list of void decoders after decoding the main
/// value. The suffixed data is skipped during decoding without being
/// exposed to the user.
Decoder<T> getHiddenSuffixDecoder<T>(
  Decoder<T> decoder,
  List<Decoder<void>> suffixedDecoders,
) {
  final allDecoders = <Decoder<Object?>>[
    decoder as Decoder<Object?>,
    ...suffixedDecoders.cast<Decoder<Object?>>(),
  ];
  final tupleDecoder = getTupleDecoder(allDecoders);
  return transformDecoder<List<Object?>, T>(
    tupleDecoder,
    (List<Object?> tuple, Uint8List bytes, int offset) => tuple[0] as T,
  );
}

/// Returns a codec that encodes and decodes values with a hidden suffix.
///
/// - **Encoding:** Appends hidden data after encoding the main value.
/// - **Decoding:** Skips the hidden suffix after decoding the main value.
Codec<T, T> getHiddenSuffixCodec<T>(
  Codec<T, T> codec,
  List<Codec<void, void>> suffixedCodecs,
) {
  return combineCodec(
    getHiddenSuffixEncoder<T>(
      encoderFromCodec(codec),
      suffixedCodecs.map(encoderFromCodec).toList(),
    ),
    getHiddenSuffixDecoder<T>(
      decoderFromCodec(codec),
      suffixedCodecs.map(decoderFromCodec).toList(),
    ),
  );
}
