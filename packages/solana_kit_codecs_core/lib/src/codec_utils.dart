import 'package:solana_kit_codecs_core/src/codec.dart';

/// Extracts an [Encoder] view from a [Codec].
///
/// This is useful because [Codec] does not extend [Encoder] in Dart (since
/// Dart does not support multiple inheritance of sealed classes). Many
/// composition utilities accept an [Encoder] so this bridge is needed.
Encoder<T> encoderFromCodec<T>(Codec<T, Object?> codec) {
  return switch (codec) {
    FixedSizeCodec<T, Object?>() => FixedSizeEncoder<T>(
      fixedSize: codec.fixedSize,
      write: codec.write,
    ),
    VariableSizeCodec<T, Object?>() => VariableSizeEncoder<T>(
      getSizeFromValue: codec.getSizeFromValue,
      write: codec.write,
      maxSize: codec.maxSize,
    ),
  };
}

/// Extracts a [Decoder] view from a [Codec].
///
/// This is useful because [Codec] does not extend [Decoder] in Dart.
Decoder<T> decoderFromCodec<T>(Codec<Object?, T> codec) {
  return switch (codec) {
    FixedSizeCodec<Object?, T>() => FixedSizeDecoder<T>(
      fixedSize: codec.fixedSize,
      read: codec.read,
    ),
    VariableSizeCodec<Object?, T>() => VariableSizeDecoder<T>(
      read: codec.read,
      maxSize: codec.maxSize,
    ),
  };
}
