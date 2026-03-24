import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A pattern entry for [getPatternMatchEncoder]: a predicate and an encoder.
typedef PatternMatchEncoderEntry<TFrom> = (
  bool Function(TFrom value) predicate,
  Encoder<TFrom> encoder,
);

/// A pattern entry for [getPatternMatchDecoder]: a byte predicate and a
/// decoder.
typedef PatternMatchDecoderEntry<TTo> = (
  bool Function(Uint8List bytes) predicate,
  Decoder<TTo> decoder,
);

/// A pattern entry for [getPatternMatchCodec]: a value predicate, a byte
/// predicate, and a codec.
typedef PatternMatchCodecEntry<TFrom, TTo> = (
  bool Function(TFrom value) valuePredicate,
  bool Function(Uint8List bytes) bytesPredicate,
  Codec<TFrom, TTo> codec,
);

/// Returns an encoder that selects which variant encoder to use based on
/// pattern matching.
///
/// This encoder evaluates the value against a series of predicate functions in
/// order, and uses the first matching encoder to encode the value.
///
/// ```dart
/// final encoder = getPatternMatchEncoder<int>([
///   ((n) => n < 256, getU8Encoder()),
///   ((n) => n < 65536, getU16Encoder()),
///   ((n) => true, getU32Encoder()),
/// ]);
///
/// encoder.encode(42);     // encoded as u8
/// encoder.encode(1000);   // encoded as u16
/// encoder.encode(100000); // encoded as u32
/// ```
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsInvalidPatternMatchValue] if the value does not
/// match any of the specified patterns.
///
/// See also: [getPatternMatchDecoder], [getPatternMatchCodec].
Encoder<TFrom> getPatternMatchEncoder<TFrom>(
  List<PatternMatchEncoderEntry<TFrom>> patterns,
) {
  int getIndexFromValue(Object? value) {
    final index = patterns.indexWhere((p) => p.$1(value as TFrom));
    if (index == -1) {
      throw SolanaError(SolanaErrorCode.codecsInvalidPatternMatchValue);
    }
    return index;
  }

  final variants =
      patterns.map((p) => p.$2 as Encoder<Object?>).toList();
  final fixedSize = _getFixedSize(variants);

  int writeImpl(TFrom value, Uint8List bytes, int offset) {
    final index = getIndexFromValue(value);
    return variants[index].write(value, bytes, offset);
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<TFrom>(fixedSize: fixedSize, write: writeImpl);
  }

  final maxSize = _getMaxSize(variants);
  return VariableSizeEncoder<TFrom>(
    getSizeFromValue: (value) {
      final index = getIndexFromValue(value);
      return getEncodedSize(value, variants[index]);
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder that selects which variant decoder to use based on
/// pattern matching.
///
/// This decoder evaluates the byte array against a series of predicate
/// functions in order, and uses the first matching decoder to decode the value.
///
/// ```dart
/// final decoder = getPatternMatchDecoder<int>([
///   ((bytes) => bytes.length == 1, getU8Decoder()),
///   ((bytes) => bytes.length == 2, getU16Decoder()),
///   ((bytes) => bytes.length <= 4, getU32Decoder()),
/// ]);
///
/// decoder.decode(Uint8List.fromList([0x2a]));            // 42 as u8
/// decoder.decode(Uint8List.fromList([0xe8, 0x03]));      // 1000 as u16
/// decoder.decode(Uint8List.fromList([0xa0, 0x86, 0x01, 0x00])); // 100000 as u32
/// ```
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsInvalidPatternMatchBytes] if the byte array does not
/// match any of the specified patterns.
///
/// See also: [getPatternMatchEncoder], [getPatternMatchCodec].
Decoder<TTo> getPatternMatchDecoder<TTo>(
  List<PatternMatchDecoderEntry<TTo>> patterns,
) {
  int getIndexFromBytes(Uint8List bytes, int offset) {
    final index = patterns.indexWhere((p) => p.$1(bytes));
    if (index == -1) {
      throw SolanaError(
        SolanaErrorCode.codecsInvalidPatternMatchBytes,
        {'bytes': bytes},
      );
    }
    return index;
  }

  final variants =
      patterns.map((p) => p.$2 as Decoder<Object?>).toList();
  final fixedSize = _getFixedSize(variants);

  (TTo, int) readImpl(Uint8List bytes, int offset) {
    final index = getIndexFromBytes(bytes, offset);
    final (value, newOffset) = variants[index].read(bytes, offset);
    return (value as TTo, newOffset);
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<TTo>(fixedSize: fixedSize, read: readImpl);
  }

  final maxSize = _getMaxSize(variants);
  return VariableSizeDecoder<TTo>(read: readImpl, maxSize: maxSize);
}

/// Returns a codec that selects which variant codec to use based on pattern
/// matching.
///
/// This codec evaluates values and byte arrays against a series of predicate
/// functions in order, using the first matching codec for encoding or decoding.
///
/// ```dart
/// final codec = getPatternMatchCodec<int, int>([
///   ((n) => n < 256, (bytes) => bytes.length == 1, getU8Codec()),
///   ((n) => n < 65536, (bytes) => bytes.length == 2, getU16Codec()),
///   ((n) => true, (bytes) => bytes.length <= 4, getU32Codec()),
/// ]);
///
/// final bytes1 = codec.encode(42);     // encoded as u8
/// final value1 = codec.decode(bytes1); // decoded as u8
/// ```
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsInvalidPatternMatchValue] if a value being encoded
/// does not match any of the specified patterns.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsInvalidPatternMatchBytes] if a byte array being
/// decoded does not match any of the specified patterns.
///
/// See also: [getPatternMatchEncoder], [getPatternMatchDecoder].
Codec<TFrom, TTo> getPatternMatchCodec<TFrom, TTo>(
  List<PatternMatchCodecEntry<TFrom, TTo>> patterns,
) {
  return combineCodec(
    getPatternMatchEncoder<TFrom>(
      patterns.map((p) => (p.$1, encoderFromCodec(p.$3))).toList(),
    ),
    getPatternMatchDecoder<TTo>(
      patterns.map((p) => (p.$2, decoderFromCodec(p.$3))).toList(),
    ),
  );
}

/// Returns the fixed size if all items share the same fixed size, otherwise
/// `null`.
int? _getFixedSize(List<Object> items) {
  int? result;
  for (final item in items) {
    final int itemSize;
    if (item case FixedSizeEncoder(:final fixedSize)) {
      itemSize = fixedSize;
    } else if (item case FixedSizeDecoder(:final fixedSize)) {
      itemSize = fixedSize;
    } else {
      return null;
    }
    if (result == null) {
      result = itemSize;
    } else if (result != itemSize) {
      return null;
    }
  }
  return result;
}

/// Returns the maximum size across all items, or `null` if any lack a max
/// size.
int? _getMaxSize(List<Object> items) {
  var result = 0;
  for (final item in items) {
    if (item case FixedSizeEncoder(:final fixedSize)) {
      if (fixedSize > result) result = fixedSize;
    } else if (item case FixedSizeDecoder(:final fixedSize)) {
      if (fixedSize > result) result = fixedSize;
    } else if (item case VariableSizeEncoder(:final maxSize)) {
      if (maxSize == null) return null;
      if (maxSize > result) result = maxSize;
    } else if (item case VariableSizeDecoder(:final maxSize)) {
      if (maxSize == null) return null;
      if (maxSize > result) result = maxSize;
    } else {
      return null;
    }
  }
  return result;
}
