import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/tuple.dart';

/// Returns an encoder that prefixes encoded values with hidden data.
///
/// This encoder applies a list of void encoders before encoding the main
/// value. The prefixed data is encoded before the main value without being
/// exposed to the user.
Encoder<T> getHiddenPrefixEncoder<T>(
  Encoder<T> encoder,
  List<Encoder<void>> prefixedEncoders,
) {
  final allEncoders = <Encoder<Object?>>[
    ...prefixedEncoders.cast<Encoder<Object?>>(),
    encoder as Encoder<Object?>,
  ];
  final tupleEncoder = getTupleEncoder(allEncoders);
  return transformEncoder<List<Object?>, T>(tupleEncoder, (T value) {
    return <Object?>[
      ...List<Object?>.filled(prefixedEncoders.length, null),
      value,
    ];
  });
}

/// Returns a decoder that skips hidden prefixed data before decoding the
/// main value.
///
/// This decoder applies a list of void decoders before decoding the main
/// value. The prefixed data is skipped during decoding without being
/// exposed to the user.
Decoder<T> getHiddenPrefixDecoder<T>(
  Decoder<T> decoder,
  List<Decoder<void>> prefixedDecoders,
) {
  final allDecoders = <Decoder<Object?>>[
    ...prefixedDecoders.cast<Decoder<Object?>>(),
    decoder as Decoder<Object?>,
  ];
  final tupleDecoder = getTupleDecoder(allDecoders);
  return transformDecoder<List<Object?>, T>(
    tupleDecoder,
    (List<Object?> tuple, Uint8List bytes, int offset) =>
        tuple[tuple.length - 1] as T,
  );
}

/// Returns a codec that encodes and decodes values with a hidden prefix.
///
/// - **Encoding:** Prefixes the value with hidden data before encoding.
/// - **Decoding:** Skips the hidden prefix before decoding the main value.
Codec<T, T> getHiddenPrefixCodec<T>(
  Codec<T, T> codec,
  List<Codec<void, void>> prefixedCodecs,
) {
  return combineCodec(
    getHiddenPrefixEncoder<T>(
      encoderFromCodec(codec),
      prefixedCodecs.map(encoderFromCodec).toList(),
    ),
    getHiddenPrefixDecoder<T>(
      decoderFromCodec(codec),
      prefixedCodecs.map(decoderFromCodec).toList(),
    ),
  );
}
