import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

// ---------------------------------------------------------------------------
// Encoder
// ---------------------------------------------------------------------------

/// An object that can encode a value of type [T] into a [Uint8List].
///
/// An `Encoder` is either a [FixedSizeEncoder] (all encoded values share the
/// same byte length) or a [VariableSizeEncoder] (encoded byte length depends
/// on the value).
sealed class Encoder<T> {
  /// Encode [value] into a new [Uint8List].
  Uint8List encode(T value);

  /// Write the encoded [value] into [bytes] starting at [offset].
  ///
  /// Returns the offset of the next byte after the encoded value.
  int write(T value, Uint8List bytes, int offset);
}

/// A fixed-size encoder where every encoded value occupies exactly
/// [fixedSize] bytes.
final class FixedSizeEncoder<T> extends Encoder<T> {
  /// Creates a fixed-size encoder with the given [fixedSize] and [write]
  /// callback.
  FixedSizeEncoder({
    required this.fixedSize,
    required int Function(T value, Uint8List bytes, int offset) write,
  }) : _write = write;

  /// The fixed number of bytes produced by this encoder.
  final int fixedSize;

  final int Function(T value, Uint8List bytes, int offset) _write;

  @override
  Uint8List encode(T value) {
    final bytes = Uint8List(fixedSize);
    _write(value, bytes, 0);
    return bytes;
  }

  @override
  int write(T value, Uint8List bytes, int offset) =>
      _write(value, bytes, offset);
}

/// A variable-size encoder whose byte length depends on the value being
/// encoded.
final class VariableSizeEncoder<T> extends Encoder<T> {
  /// Creates a variable-size encoder.
  VariableSizeEncoder({
    required int Function(T value) getSizeFromValue,
    required int Function(T value, Uint8List bytes, int offset) write,
    this.maxSize,
  }) : _getSizeFromValue = getSizeFromValue,
       _write = write;

  final int Function(T value) _getSizeFromValue;
  final int Function(T value, Uint8List bytes, int offset) _write;

  /// The maximum possible size of an encoded value in bytes, if known.
  final int? maxSize;

  /// Returns the encoded byte size for the given [value].
  int getSizeFromValue(T value) => _getSizeFromValue(value);

  @override
  Uint8List encode(T value) {
    final size = _getSizeFromValue(value);
    final bytes = Uint8List(size);
    _write(value, bytes, 0);
    return bytes;
  }

  @override
  int write(T value, Uint8List bytes, int offset) =>
      _write(value, bytes, offset);
}

// ---------------------------------------------------------------------------
// Decoder
// ---------------------------------------------------------------------------

/// An object that can decode a [Uint8List] into a value of type [T].
///
/// A `Decoder` is either a [FixedSizeDecoder] (always reads a fixed number of
/// bytes) or a [VariableSizeDecoder] (byte length varies).
sealed class Decoder<T> {
  /// Decode a value from [bytes], optionally starting at [offset].
  T decode(Uint8List bytes, [int offset = 0]);

  /// Read a value from [bytes] starting at [offset].
  ///
  /// Returns a record of the decoded value and the offset of the next byte
  /// after the decoded value.
  (T value, int offset) read(Uint8List bytes, int offset);
}

/// A fixed-size decoder that always reads exactly [fixedSize] bytes.
final class FixedSizeDecoder<T> extends Decoder<T> {
  /// Creates a fixed-size decoder with the given [fixedSize] and [read]
  /// callback.
  FixedSizeDecoder({
    required this.fixedSize,
    required (T value, int offset) Function(Uint8List bytes, int offset) read,
  }) : _read = read;

  /// The fixed number of bytes consumed by this decoder.
  final int fixedSize;

  final (T value, int offset) Function(Uint8List bytes, int offset) _read;

  @override
  T decode(Uint8List bytes, [int offset = 0]) => _read(bytes, offset).$1;

  @override
  (T, int) read(Uint8List bytes, int offset) => _read(bytes, offset);
}

/// A variable-size decoder whose byte consumption depends on the data.
final class VariableSizeDecoder<T> extends Decoder<T> {
  /// Creates a variable-size decoder.
  VariableSizeDecoder({
    required (T value, int offset) Function(Uint8List bytes, int offset) read,
    this.maxSize,
  }) : _read = read;

  final (T value, int offset) Function(Uint8List bytes, int offset) _read;

  /// The maximum possible size of an encoded value in bytes, if known.
  final int? maxSize;

  @override
  T decode(Uint8List bytes, [int offset = 0]) => _read(bytes, offset).$1;

  @override
  (T, int) read(Uint8List bytes, int offset) => _read(bytes, offset);
}

// ---------------------------------------------------------------------------
// Codec
// ---------------------------------------------------------------------------

/// An object that can both encode and decode values.
///
/// A `Codec` is either a [FixedSizeCodec] or a [VariableSizeCodec].
///
/// The type parameter `TFrom` is the type accepted for encoding (may be
/// looser), while `TTo` is the type returned when decoding.
sealed class Codec<TFrom, TTo> {
  /// Encode [value] into a new [Uint8List].
  Uint8List encode(TFrom value);

  /// Write the encoded [value] into [bytes] starting at [offset].
  ///
  /// Returns the offset of the next byte after the encoded value.
  int write(TFrom value, Uint8List bytes, int offset);

  /// Decode a value from [bytes], optionally starting at [offset].
  TTo decode(Uint8List bytes, [int offset = 0]);

  /// Read a value from [bytes] starting at [offset].
  ///
  /// Returns a record of the decoded value and the offset of the next byte.
  (TTo value, int offset) read(Uint8List bytes, int offset);
}

/// A fixed-size codec where encoding always produces [fixedSize] bytes and
/// decoding always consumes [fixedSize] bytes.
final class FixedSizeCodec<TFrom, TTo> extends Codec<TFrom, TTo> {
  /// Creates a fixed-size codec.
  FixedSizeCodec({
    required this.fixedSize,
    required int Function(TFrom value, Uint8List bytes, int offset) write,
    required (TTo value, int offset) Function(Uint8List bytes, int offset) read,
  }) : _write = write,
       _read = read;

  /// The fixed number of bytes used by this codec.
  final int fixedSize;

  final int Function(TFrom value, Uint8List bytes, int offset) _write;
  final (TTo value, int offset) Function(Uint8List bytes, int offset) _read;

  @override
  Uint8List encode(TFrom value) {
    final bytes = Uint8List(fixedSize);
    _write(value, bytes, 0);
    return bytes;
  }

  @override
  int write(TFrom value, Uint8List bytes, int offset) =>
      _write(value, bytes, offset);

  @override
  TTo decode(Uint8List bytes, [int offset = 0]) => _read(bytes, offset).$1;

  @override
  (TTo, int) read(Uint8List bytes, int offset) => _read(bytes, offset);
}

/// A variable-size codec whose byte size depends on the value being
/// encoded/decoded.
final class VariableSizeCodec<TFrom, TTo> extends Codec<TFrom, TTo> {
  /// Creates a variable-size codec.
  VariableSizeCodec({
    required int Function(TFrom value) getSizeFromValue,
    required int Function(TFrom value, Uint8List bytes, int offset) write,
    required (TTo value, int offset) Function(Uint8List bytes, int offset) read,
    this.maxSize,
  }) : _getSizeFromValue = getSizeFromValue,
       _write = write,
       _read = read;

  final int Function(TFrom value) _getSizeFromValue;
  final int Function(TFrom value, Uint8List bytes, int offset) _write;
  final (TTo value, int offset) Function(Uint8List bytes, int offset) _read;

  /// The maximum possible size of an encoded value in bytes, if known.
  final int? maxSize;

  /// Returns the encoded byte size for the given [value].
  int getSizeFromValue(TFrom value) => _getSizeFromValue(value);

  @override
  Uint8List encode(TFrom value) {
    final size = _getSizeFromValue(value);
    final bytes = Uint8List(size);
    _write(value, bytes, 0);
    return bytes;
  }

  @override
  int write(TFrom value, Uint8List bytes, int offset) =>
      _write(value, bytes, offset);

  @override
  TTo decode(Uint8List bytes, [int offset = 0]) => _read(bytes, offset).$1;

  @override
  (TTo, int) read(Uint8List bytes, int offset) => _read(bytes, offset);
}

// ---------------------------------------------------------------------------
// Utility functions
// ---------------------------------------------------------------------------

/// Gets the encoded size of [value] using the provided [encoder].
///
/// If the encoder is fixed-size, returns its `fixedSize`.
/// If the encoder is variable-size, delegates to `getSizeFromValue`.
int getEncodedSize<T>(T value, Encoder<T> encoder) {
  return switch (encoder) {
    FixedSizeEncoder<T>(:final fixedSize) => fixedSize,
    VariableSizeEncoder<T>() => encoder.getSizeFromValue(value),
  };
}

// ---------------------------------------------------------------------------
// Type checks
// ---------------------------------------------------------------------------

/// Returns `true` if the given encoder, decoder, or codec is fixed-size.
bool isFixedSize(Object? object) {
  return object is FixedSizeEncoder ||
      object is FixedSizeDecoder ||
      object is FixedSizeCodec;
}

/// Returns `true` if the given encoder, decoder, or codec is variable-size.
bool isVariableSize(Object? object) => !isFixedSize(object);

/// Asserts that the given [object] is fixed-size.
///
/// Throws a [SolanaError] with code
/// `SolanaErrorCode.codecsExpectedFixedLength` if it is not.
void assertIsFixedSize(Object? object) {
  if (!isFixedSize(object)) {
    throw SolanaError(SolanaErrorCode.codecsExpectedFixedLength);
  }
}

/// Asserts that the given [object] is variable-size.
///
/// Throws a [SolanaError] with code
/// `SolanaErrorCode.codecsExpectedVariableLength` if it is not.
void assertIsVariableSize(Object? object) {
  if (!isVariableSize(object)) {
    throw SolanaError(SolanaErrorCode.codecsExpectedVariableLength);
  }
}
