import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/assertions.dart';
import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';

/// Stores the size of the [encoder] in bytes as a prefix using
/// the [prefix] encoder.
///
/// When both [encoder] and [prefix] are fixed-size, the result is a
/// fixed-size encoder. Otherwise, the result is variable-size.
Encoder<TFrom> addEncoderSizePrefix<TFrom>(
  Encoder<TFrom> encoder,
  Encoder<num> prefix,
) {
  int writeImpl(TFrom value, Uint8List bytes, int currentOffset) {
    // Use encode() to contain the encoder within its own bounds.
    final encoderBytes = encoder.encode(value);
    final afterPrefix = prefix.write(encoderBytes.length, bytes, currentOffset);
    bytes.setAll(afterPrefix, encoderBytes);
    return afterPrefix + encoderBytes.length;
  }

  if (prefix is FixedSizeEncoder<num> && encoder is FixedSizeEncoder<TFrom>) {
    return FixedSizeEncoder<TFrom>(
      fixedSize: prefix.fixedSize + encoder.fixedSize,
      write: writeImpl,
    );
  }

  final prefixMaxSize = switch (prefix) {
    FixedSizeEncoder<num>(:final fixedSize) => fixedSize,
    VariableSizeEncoder<num>(:final maxSize) => maxSize,
  };
  final encoderMaxSize = switch (encoder) {
    FixedSizeEncoder<TFrom>(:final fixedSize) => fixedSize,
    VariableSizeEncoder<TFrom>(:final maxSize) => maxSize,
  };
  final int? maxSize;
  if (prefixMaxSize != null && encoderMaxSize != null) {
    maxSize = prefixMaxSize + encoderMaxSize;
  } else {
    maxSize = null;
  }

  return VariableSizeEncoder<TFrom>(
    getSizeFromValue: (value) {
      final encoderSize = _getEncoderSize(value, encoder);
      return _getEncoderSize(encoderSize, prefix) + encoderSize;
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Bounds the size of the nested [decoder] by reading its encoded [prefix].
///
/// When both [decoder] and [prefix] are fixed-size, the result is a
/// fixed-size decoder. Otherwise, the result is variable-size.
Decoder<TTo> addDecoderSizePrefix<TTo>(
  Decoder<TTo> decoder,
  Decoder<num> prefix,
) {
  (TTo, int) readImpl(Uint8List bytes, int currentOffset) {
    final (bigintSize, decoderOffset) = prefix.read(bytes, currentOffset);
    final size = bigintSize.toInt();
    final contentStart = decoderOffset;
    // Slice the byte array to the contained size if necessary.
    Uint8List sliced;
    if (contentStart > 0 || bytes.length > size) {
      sliced = bytes.sublist(contentStart, contentStart + size);
    } else {
      sliced = bytes;
    }
    assertByteArrayHasEnoughBytesForCodec('addDecoderSizePrefix', size, sliced);
    // Use decode() to contain the decoder within its own bounds.
    return (decoder.decode(sliced), contentStart + size);
  }

  if (prefix is FixedSizeDecoder<num> && decoder is FixedSizeDecoder<TTo>) {
    return FixedSizeDecoder<TTo>(
      fixedSize: prefix.fixedSize + decoder.fixedSize,
      read: readImpl,
    );
  }

  final prefixMaxSize = switch (prefix) {
    FixedSizeDecoder<num>(:final fixedSize) => fixedSize,
    VariableSizeDecoder<num>(:final maxSize) => maxSize,
  };
  final decoderMaxSize = switch (decoder) {
    FixedSizeDecoder<TTo>(:final fixedSize) => fixedSize,
    VariableSizeDecoder<TTo>(:final maxSize) => maxSize,
  };
  final int? maxSize;
  if (prefixMaxSize != null && decoderMaxSize != null) {
    maxSize = prefixMaxSize + decoderMaxSize;
  } else {
    maxSize = null;
  }

  return VariableSizeDecoder<TTo>(read: readImpl, maxSize: maxSize);
}

/// Stores the byte size of [codec] as an encoded number prefix.
///
/// When encoding, the size of the encoded data is stored before the data.
/// When decoding, the size is read first to know how many bytes to read.
Codec<TFrom, TTo> addCodecSizePrefix<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  Codec<num, num> prefix,
) {
  return combineCodec(
    addEncoderSizePrefix(encoderFromCodec(codec), encoderFromCodec(prefix)),
    addDecoderSizePrefix(decoderFromCodec(codec), decoderFromCodec(prefix)),
  );
}

/// Helper to get the encoded size for a value using an encoder.
int _getEncoderSize<T>(T value, Encoder<T> encoder) {
  return switch (encoder) {
    FixedSizeEncoder<T>(:final fixedSize) => fixedSize,
    VariableSizeEncoder<T>() => encoder.getSizeFromValue(value),
  };
}
