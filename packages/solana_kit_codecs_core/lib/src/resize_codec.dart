import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Updates the size of a given [encoder] using a [resize] function.
///
/// For fixed-size encoders, the `fixedSize` is updated.
/// For variable-size encoders, the `getSizeFromValue` is updated.
///
/// Throws a [SolanaError] if the new size is negative.
Encoder<T> resizeEncoder<T>(
  Encoder<T> encoder,
  int Function(int size) resize,
) {
  return switch (encoder) {
    FixedSizeEncoder<T>() => () {
        final newFixedSize = resize(encoder.fixedSize);
        if (newFixedSize < 0) {
          throw SolanaError(
            SolanaErrorCode.codecsExpectedPositiveByteLength,
            {
              'bytesLength': newFixedSize,
              'codecDescription': 'resizeEncoder',
            },
          );
        }
        return FixedSizeEncoder<T>(
          fixedSize: newFixedSize,
          write: encoder.write,
        );
      }(),
    VariableSizeEncoder<T>() => VariableSizeEncoder<T>(
        getSizeFromValue: (value) {
          final newSize = resize(encoder.getSizeFromValue(value));
          if (newSize < 0) {
            throw SolanaError(
              SolanaErrorCode.codecsExpectedPositiveByteLength,
              {
                'bytesLength': newSize,
                'codecDescription': 'resizeEncoder',
              },
            );
          }
          return newSize;
        },
        write: encoder.write,
        maxSize: encoder.maxSize,
      ),
  };
}

/// Updates the size of a given [decoder] using a [resize] function.
///
/// For fixed-size decoders, the `fixedSize` is updated.
/// Variable-size decoders are returned unchanged since their size is
/// determined dynamically.
///
/// Throws a [SolanaError] if the new size is negative.
Decoder<T> resizeDecoder<T>(
  Decoder<T> decoder,
  int Function(int size) resize,
) {
  return switch (decoder) {
    FixedSizeDecoder<T>() => () {
        final newFixedSize = resize(decoder.fixedSize);
        if (newFixedSize < 0) {
          throw SolanaError(
            SolanaErrorCode.codecsExpectedPositiveByteLength,
            {
              'bytesLength': newFixedSize,
              'codecDescription': 'resizeDecoder',
            },
          );
        }
        return FixedSizeDecoder<T>(
          fixedSize: newFixedSize,
          read: decoder.read,
        );
      }(),
    VariableSizeDecoder<T>() => decoder,
  };
}

/// Updates the size of a given [codec] using a [resize] function.
///
/// For fixed-size codecs, both the encoder and decoder sizes are updated.
/// For variable-size codecs, only the encoder size is updated.
///
/// Throws a [SolanaError] if the new size is negative.
Codec<TFrom, TTo> resizeCodec<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  int Function(int size) resize,
) {
  return combineCodec(
    resizeEncoder(encoderFromCodec(codec), resize),
    resizeDecoder(decoderFromCodec(codec), resize),
  );
}
