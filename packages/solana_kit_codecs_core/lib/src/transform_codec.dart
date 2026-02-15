import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';

/// Transforms an encoder by mapping its input values.
///
/// Takes an existing `Encoder<TOldFrom>` and returns an `Encoder<TNewFrom>`,
/// converting values of type `TNewFrom` into `TOldFrom` before encoding via
/// the [unmap] function.
Encoder<TNewFrom> transformEncoder<TOldFrom, TNewFrom>(
  Encoder<TOldFrom> encoder,
  TOldFrom Function(TNewFrom value) unmap,
) {
  return switch (encoder) {
    FixedSizeEncoder<TOldFrom>() => FixedSizeEncoder<TNewFrom>(
        fixedSize: encoder.fixedSize,
        write: (value, bytes, offset) =>
            encoder.write(unmap(value), bytes, offset),
      ),
    VariableSizeEncoder<TOldFrom>() => VariableSizeEncoder<TNewFrom>(
        getSizeFromValue: (value) => encoder.getSizeFromValue(unmap(value)),
        write: (value, bytes, offset) =>
            encoder.write(unmap(value), bytes, offset),
        maxSize: encoder.maxSize,
      ),
  };
}

/// Transforms a decoder by mapping its output values.
///
/// Takes an existing `Decoder<TOldTo>` and returns a `Decoder<TNewTo>`,
/// converting decoded values of type `TOldTo` into `TNewTo` via the [map]
/// function.
Decoder<TNewTo> transformDecoder<TOldTo, TNewTo>(
  Decoder<TOldTo> decoder,
  TNewTo Function(TOldTo value, Uint8List bytes, int offset) map,
) {
  return switch (decoder) {
    FixedSizeDecoder<TOldTo>() => FixedSizeDecoder<TNewTo>(
        fixedSize: decoder.fixedSize,
        read: (bytes, offset) {
          final (value, newOffset) = decoder.read(bytes, offset);
          return (map(value, bytes, offset), newOffset);
        },
      ),
    VariableSizeDecoder<TOldTo>() => VariableSizeDecoder<TNewTo>(
        read: (bytes, offset) {
          final (value, newOffset) = decoder.read(bytes, offset);
          return (map(value, bytes, offset), newOffset);
        },
        maxSize: decoder.maxSize,
      ),
  };
}

/// Transforms a codec by mapping its input and output values.
///
/// The [unmap] function converts `TNewFrom` to `TOldFrom` before encoding.
/// The optional [map] function converts `TOldTo` to `TNewTo` after decoding.
/// If [map] is not provided, the decoded type is cast directly.
Codec<TNewFrom, TNewTo> transformCodec<TOldFrom, TNewFrom, TOldTo, TNewTo>(
  Codec<TOldFrom, TOldTo> codec,
  TOldFrom Function(TNewFrom value) unmap, [
  TNewTo Function(TOldTo value, Uint8List bytes, int offset)? map,
]) {
  final transformedEncoder = transformEncoder<TOldFrom, TNewFrom>(
    encoderFromCodec(codec),
    unmap,
  );

  if (map != null) {
    final transformedDecoder = transformDecoder<TOldTo, TNewTo>(
      decoderFromCodec(codec),
      map,
    );
    return _combineEncoderDecoder(transformedEncoder, transformedDecoder);
  }

  // When no map function is given, the decode output type stays the same.
  return switch (codec) {
    FixedSizeCodec<TOldFrom, TOldTo>() => FixedSizeCodec<TNewFrom, TNewTo>(
        fixedSize: codec.fixedSize,
        write: transformedEncoder.write,
        read: (bytes, offset) {
          final (value, newOffset) = codec.read(bytes, offset);
          return (value as TNewTo, newOffset);
        },
      ),
    VariableSizeCodec<TOldFrom, TOldTo>() =>
      VariableSizeCodec<TNewFrom, TNewTo>(
        getSizeFromValue:
            (transformedEncoder as VariableSizeEncoder<TNewFrom>)
                .getSizeFromValue,
        write: transformedEncoder.write,
        read: (bytes, offset) {
          final (value, newOffset) = codec.read(bytes, offset);
          return (value as TNewTo, newOffset);
        },
        maxSize: codec.maxSize,
      ),
  };
}

Codec<TFrom, TTo> _combineEncoderDecoder<TFrom, TTo>(
  Encoder<TFrom> encoder,
  Decoder<TTo> decoder,
) {
  return switch (encoder) {
    FixedSizeEncoder<TFrom>() => FixedSizeCodec<TFrom, TTo>(
        fixedSize: encoder.fixedSize,
        write: encoder.write,
        read: decoder.read,
      ),
    VariableSizeEncoder<TFrom>() => VariableSizeCodec<TFrom, TTo>(
        getSizeFromValue: encoder.getSizeFromValue,
        write: encoder.write,
        read: decoder.read,
        maxSize: encoder.maxSize,
      ),
  };
}
