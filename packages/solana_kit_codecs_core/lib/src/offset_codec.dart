import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/assertions.dart';
import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';

/// Scope provided to pre-offset and post-offset functions.
class PreOffsetScope {
  /// Creates a pre-offset scope.
  const PreOffsetScope({
    required this.bytes,
    required this.preOffset,
    required this.wrapBytes,
  });

  /// The entire byte array being encoded or decoded.
  final Uint8List bytes;

  /// The original offset prior to encode or decode.
  final int preOffset;

  /// Wraps the offset to the byte array length.
  final int Function(int offset) wrapBytes;
}

/// Extended scope for post-offset functions, which also includes
/// the new pre-offset and the original post-offset.
class PostOffsetScope extends PreOffsetScope {
  /// Creates a post-offset scope.
  const PostOffsetScope({
    required super.bytes,
    required super.preOffset,
    required super.wrapBytes,
    required this.newPreOffset,
    required this.postOffset,
  });

  /// The modified offset used to encode or decode.
  final int newPreOffset;

  /// The original offset returned by the encoder or decoder.
  final int postOffset;
}

/// A function that modifies the pre-offset before encoding or decoding.
typedef PreOffsetFunction = int Function(PreOffsetScope scope);

/// A function that modifies the post-offset after encoding or decoding.
typedef PostOffsetFunction = int Function(PostOffsetScope scope);

/// Configuration for modifying the offset of an encoder, decoder, or codec.
class OffsetConfig {
  /// Creates an offset configuration.
  const OffsetConfig({this.preOffset, this.postOffset});

  /// A function that modifies the offset before encoding or decoding.
  final PreOffsetFunction? preOffset;

  /// A function that modifies the offset after encoding or decoding.
  final PostOffsetFunction? postOffset;
}

/// Moves the offset of a given [encoder] before and/or after encoding.
///
/// The pre-offset function determines where encoding should start, while
/// the post-offset function adjusts where the next encoder should continue.
Encoder<T> offsetEncoder<T>(Encoder<T> encoder, OffsetConfig config) {
  int writeImpl(T value, Uint8List bytes, int preOffset) {
    int wrapBytesImpl(int offset) => _modulo(offset, bytes.length);

    final newPreOffset =
        config.preOffset != null
            ? config.preOffset!(
              PreOffsetScope(
                bytes: bytes,
                preOffset: preOffset,
                wrapBytes: wrapBytesImpl,
              ),
            )
            : preOffset;
    assertByteArrayOffsetIsNotOutOfRange(
      'offsetEncoder',
      newPreOffset,
      bytes.length,
    );

    final postOffset = encoder.write(value, bytes, newPreOffset);

    final newPostOffset =
        config.postOffset != null
            ? config.postOffset!(
              PostOffsetScope(
                bytes: bytes,
                preOffset: preOffset,
                wrapBytes: wrapBytesImpl,
                newPreOffset: newPreOffset,
                postOffset: postOffset,
              ),
            )
            : postOffset;
    assertByteArrayOffsetIsNotOutOfRange(
      'offsetEncoder',
      newPostOffset,
      bytes.length,
    );

    return newPostOffset;
  }

  return switch (encoder) {
    FixedSizeEncoder<T>() => FixedSizeEncoder<T>(
        fixedSize: encoder.fixedSize,
        write: writeImpl,
      ),
    VariableSizeEncoder<T>() => VariableSizeEncoder<T>(
        getSizeFromValue: encoder.getSizeFromValue,
        write: writeImpl,
        maxSize: encoder.maxSize,
      ),
  };
}

/// Moves the offset of a given [decoder] before and/or after decoding.
///
/// The pre-offset function determines where decoding should start, while
/// the post-offset function adjusts where the next decoder should continue.
Decoder<T> offsetDecoder<T>(Decoder<T> decoder, OffsetConfig config) {
  (T, int) readImpl(Uint8List bytes, int preOffset) {
    int wrapBytesImpl(int offset) => _modulo(offset, bytes.length);

    final newPreOffset =
        config.preOffset != null
            ? config.preOffset!(
              PreOffsetScope(
                bytes: bytes,
                preOffset: preOffset,
                wrapBytes: wrapBytesImpl,
              ),
            )
            : preOffset;
    assertByteArrayOffsetIsNotOutOfRange(
      'offsetDecoder',
      newPreOffset,
      bytes.length,
    );

    final (value, postOffset) = decoder.read(bytes, newPreOffset);

    final newPostOffset =
        config.postOffset != null
            ? config.postOffset!(
              PostOffsetScope(
                bytes: bytes,
                preOffset: preOffset,
                wrapBytes: wrapBytesImpl,
                newPreOffset: newPreOffset,
                postOffset: postOffset,
              ),
            )
            : postOffset;
    assertByteArrayOffsetIsNotOutOfRange(
      'offsetDecoder',
      newPostOffset,
      bytes.length,
    );

    return (value, newPostOffset);
  }

  return switch (decoder) {
    FixedSizeDecoder<T>() => FixedSizeDecoder<T>(
        fixedSize: decoder.fixedSize,
        read: readImpl,
      ),
    VariableSizeDecoder<T>() => VariableSizeDecoder<T>(
        read: readImpl,
        maxSize: decoder.maxSize,
      ),
  };
}

/// Moves the offset of a given [codec] before and/or after encoding and
/// decoding.
Codec<TFrom, TTo> offsetCodec<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  OffsetConfig config,
) {
  return combineCodec(
    offsetEncoder(encoderFromCodec(codec), config),
    offsetDecoder(decoderFromCodec(codec), config),
  );
}

/// A modulo function that handles negative dividends and zero divisors.
int _modulo(int dividend, int divisor) {
  if (divisor == 0) return 0;
  return ((dividend % divisor) + divisor) % divisor;
}
