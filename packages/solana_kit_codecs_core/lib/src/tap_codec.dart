import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/codec.dart';

/// Observes encoded values without modifying them.
///
/// Wraps [encoder] so that [tap] runs with the value before it is encoded.
/// Throw from [tap] to abort the write, which makes this a convenient place
/// for validation guards that should apply to every encoding.
///
/// The returned encoder keeps the size characteristics of [encoder].
Encoder<T> tapEncoder<T>(Encoder<T> encoder, void Function(T value) tap) {
  return switch (encoder) {
    FixedSizeEncoder<T>(:final fixedSize) => FixedSizeEncoder<T>(
      fixedSize: fixedSize,
      write: (value, bytes, offset) {
        tap(value);
        return encoder.write(value, bytes, offset);
      },
    ),
    VariableSizeEncoder<T>() => VariableSizeEncoder<T>(
      getSizeFromValue: encoder.getSizeFromValue,
      write: (value, bytes, offset) {
        tap(value);
        return encoder.write(value, bytes, offset);
      },
      maxSize: encoder.maxSize,
    ),
  };
}

/// Observes decoded values without modifying them.
///
/// Wraps [decoder] so that [tap] runs with the decoded value after it is
/// read. Throw from [tap] to abort the read.
///
/// The returned decoder keeps the size characteristics of [decoder].
Decoder<T> tapDecoder<T>(Decoder<T> decoder, void Function(T value) tap) {
  return switch (decoder) {
    FixedSizeDecoder<T>(:final fixedSize) => FixedSizeDecoder<T>(
      fixedSize: fixedSize,
      read: (bytes, offset) {
        final (value, newOffset) = decoder.read(bytes, offset);
        tap(value);
        return (value, newOffset);
      },
    ),
    VariableSizeDecoder<T>() => VariableSizeDecoder<T>(
      read: (bytes, offset) {
        final (value, newOffset) = decoder.read(bytes, offset);
        tap(value);
        return (value, newOffset);
      },
      maxSize: decoder.maxSize,
    ),
  };
}

/// Observes both encoded and decoded values without modifying them.
///
/// Wraps [codec] so that [encodeTap] runs with the value before encoding and
/// [decodeTap] — when provided — runs with the decoded value after reading.
/// Throw from either callback to abort the operation.
///
/// The returned codec keeps the size characteristics of [codec].
Codec<TFrom, TTo> tapCodec<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  void Function(TFrom value) encodeTap, [
  void Function(TTo value)? decodeTap,
]) {
  (TTo, int) readWithDecodeTap(Uint8List bytes, int offset) {
    final (value, newOffset) = codec.read(bytes, offset);
    decodeTap?.call(value);
    return (value, newOffset);
  }

  return switch (codec) {
    FixedSizeCodec<TFrom, TTo>(:final fixedSize) => FixedSizeCodec(
      fixedSize: fixedSize,
      read: readWithDecodeTap,
      write: (value, bytes, offset) {
        encodeTap(value);
        return codec.write(value, bytes, offset);
      },
    ),
    VariableSizeCodec<TFrom, TTo>() => VariableSizeCodec(
      getSizeFromValue: codec.getSizeFromValue,
      read: readWithDecodeTap,
      write: (value, bytes, offset) {
        encodeTap(value);
        return codec.write(value, bytes, offset);
      },
      maxSize: codec.maxSize,
    ),
  };
}

/// Observes encoded bytes without modifying them.
///
/// Wraps [encoder] so that [tap] runs after the write with the destination
/// [Uint8List] and the offsets spanned by the write. Throw from [tap] to
/// abort the write.
///
/// The returned encoder keeps the size characteristics of [encoder].
Encoder<T> tapEncoderBytes<T>(
  Encoder<T> encoder,
  void Function(Uint8List bytes, int preOffset, int postOffset) tap,
) {
  return switch (encoder) {
    FixedSizeEncoder<T>(:final fixedSize) => FixedSizeEncoder<T>(
      fixedSize: fixedSize,
      write: (value, bytes, offset) {
        final postOffset = encoder.write(value, bytes, offset);
        tap(bytes, offset, postOffset);
        return postOffset;
      },
    ),
    VariableSizeEncoder<T>() => VariableSizeEncoder<T>(
      getSizeFromValue: encoder.getSizeFromValue,
      write: (value, bytes, offset) {
        final postOffset = encoder.write(value, bytes, offset);
        tap(bytes, offset, postOffset);
        return postOffset;
      },
      maxSize: encoder.maxSize,
    ),
  };
}

/// Observes the bytes a decoder is about to read.
///
/// Wraps [decoder] so that [tap] runs before the read with the source
/// [Uint8List] and the offset the read starts at. Throw from [tap] to abort
/// the read.
///
/// The returned decoder keeps the size characteristics of [decoder].
Decoder<T> tapDecoderBytes<T>(
  Decoder<T> decoder,
  void Function(Uint8List bytes, int offset) tap,
) {
  return switch (decoder) {
    FixedSizeDecoder<T>(:final fixedSize) => FixedSizeDecoder<T>(
      fixedSize: fixedSize,
      read: (bytes, offset) {
        tap(bytes, offset);
        return decoder.read(bytes, offset);
      },
    ),
    VariableSizeDecoder<T>() => VariableSizeDecoder<T>(
      read: (bytes, offset) {
        tap(bytes, offset);
        return decoder.read(bytes, offset);
      },
      maxSize: decoder.maxSize,
    ),
  };
}

/// Observes the bytes an encoder writes and a decoder reads.
///
/// Wraps [codec] so that [encodeTap] runs after the write with the offsets
/// spanned by it, and [decodeTap] — when provided — runs before the read.
/// Throw from either callback to abort the operation.
///
/// The returned codec keeps the size characteristics of [codec].
Codec<TFrom, TTo> tapCodecBytes<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  void Function(Uint8List bytes, int preOffset, int postOffset) encodeTap, [
  void Function(Uint8List bytes, int offset)? decodeTap,
]) {
  (TTo, int) readWithDecodeTap(Uint8List bytes, int offset) {
    decodeTap?.call(bytes, offset);
    return codec.read(bytes, offset);
  }

  return switch (codec) {
    FixedSizeCodec<TFrom, TTo>(:final fixedSize) => FixedSizeCodec(
      fixedSize: fixedSize,
      read: readWithDecodeTap,
      write: (value, bytes, offset) {
        final postOffset = codec.write(value, bytes, offset);
        encodeTap(bytes, offset, postOffset);
        return postOffset;
      },
    ),
    VariableSizeCodec<TFrom, TTo>() => VariableSizeCodec(
      getSizeFromValue: codec.getSizeFromValue,
      read: readWithDecodeTap,
      write: (value, bytes, offset) {
        final postOffset = codec.write(value, bytes, offset);
        encodeTap(bytes, offset, postOffset);
        return postOffset;
      },
      maxSize: codec.maxSize,
    ),
  };
}
