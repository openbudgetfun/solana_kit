import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A typed two-variant union value.
///
/// Use [Union2Variant0] and [Union2Variant1] to create values.
sealed class Union2<T0, T1> {
  /// Creates a [Union2] value.
  const Union2();

  /// The zero-based variant index.
  int get index;
}

/// Variant 0 for [Union2].
final class Union2Variant0<T0, T1> extends Union2<T0, T1> {
  /// Creates a [Union2Variant0].
  const Union2Variant0(this.value);

  /// The typed variant value.
  final T0 value;

  @override
  int get index => 0;
}

/// Variant 1 for [Union2].
final class Union2Variant1<T0, T1> extends Union2<T0, T1> {
  /// Creates a [Union2Variant1].
  const Union2Variant1(this.value);

  /// The typed variant value.
  final T1 value;

  @override
  int get index => 1;
}

/// A typed three-variant union value.
///
/// Use [Union3Variant0], [Union3Variant1], and [Union3Variant2] to create
/// values.
sealed class Union3<T0, T1, T2> {
  /// Creates a [Union3] value.
  const Union3();

  /// The zero-based variant index.
  int get index;
}

/// Variant 0 for [Union3].
final class Union3Variant0<T0, T1, T2> extends Union3<T0, T1, T2> {
  /// Creates a [Union3Variant0].
  const Union3Variant0(this.value);

  /// The typed variant value.
  final T0 value;

  @override
  int get index => 0;
}

/// Variant 1 for [Union3].
final class Union3Variant1<T0, T1, T2> extends Union3<T0, T1, T2> {
  /// Creates a [Union3Variant1].
  const Union3Variant1(this.value);

  /// The typed variant value.
  final T1 value;

  @override
  int get index => 1;
}

/// Variant 2 for [Union3].
final class Union3Variant2<T0, T1, T2> extends Union3<T0, T1, T2> {
  /// Creates a [Union3Variant2].
  const Union3Variant2(this.value);

  /// The typed variant value.
  final T2 value;

  @override
  int get index => 2;
}

/// Returns an encoder for union types.
///
/// This encoder serializes values by selecting the correct variant encoder
/// based on the [getIndexFromValue] function.
///
/// Unlike other codecs, this encoder does not store the variant index.
/// It is the user's responsibility to manage discriminators separately.
Encoder<Object?> getUnionEncoder(
  List<Encoder<Object?>> variants,
  int Function(Object? value) getIndexFromValue,
) {
  final fixedSize = _getUnionFixedSize(variants);

  int writeImpl(Object? variant, Uint8List bytes, int offset) {
    final index = getIndexFromValue(variant);
    _assertValidVariantIndex(variants, index);
    return variants[index].write(variant, bytes, offset);
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<Object?>(fixedSize: fixedSize, write: writeImpl);
  }

  final maxSize = _getUnionMaxSize(variants);

  return VariableSizeEncoder<Object?>(
    getSizeFromValue: (variant) {
      final index = getIndexFromValue(variant);
      _assertValidVariantIndex(variants, index);
      return getEncodedSize(variant, variants[index]);
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder for union types.
///
/// This decoder deserializes values by selecting the correct variant decoder
/// based on the [getIndexFromBytes] function.
Decoder<Object?> getUnionDecoder(
  List<Decoder<Object?>> variants,
  int Function(Uint8List bytes, int offset) getIndexFromBytes,
) {
  final fixedSize = _getUnionFixedSize(variants);

  (Object?, int) readImpl(Uint8List bytes, int offset) {
    final index = getIndexFromBytes(bytes, offset);
    _assertValidVariantIndex(variants, index);
    return variants[index].read(bytes, offset);
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<Object?>(fixedSize: fixedSize, read: readImpl);
  }

  final maxSize = _getUnionMaxSize(variants);
  return VariableSizeDecoder<Object?>(read: readImpl, maxSize: maxSize);
}

/// Returns a codec for encoding and decoding union types.
///
/// This codec serializes and deserializes union values by selecting the
/// correct variant based on the provided index functions.
Codec<Object?, Object?> getUnionCodec(
  List<Codec<Object?, Object?>> variants,
  int Function(Object? value) getIndexFromValue,
  int Function(Uint8List bytes, int offset) getIndexFromBytes,
) {
  return combineCodec(
    getUnionEncoder(variants.map(encoderFromCodec).toList(), getIndexFromValue),
    getUnionDecoder(variants.map(decoderFromCodec).toList(), getIndexFromBytes),
  );
}

/// Returns an encoder for a two-variant typed union.
///
/// This helper improves type inference compared to [getUnionEncoder] by
/// requiring explicitly-typed [Union2] values at encode time.
Encoder<Union2<T0, T1>> getUnion2Encoder<T0, T1>(
  Encoder<T0> variant0,
  Encoder<T1> variant1,
) {
  final variants = <Object>[variant0, variant1];
  final fixedSize = _getUnionFixedSize(variants);

  int writeImpl(Union2<T0, T1> variant, Uint8List bytes, int offset) {
    return switch (variant) {
      Union2Variant0<T0, T1>(:final value) => variant0.write(
        value,
        bytes,
        offset,
      ),
      Union2Variant1<T0, T1>(:final value) => variant1.write(
        value,
        bytes,
        offset,
      ),
    };
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<Union2<T0, T1>>(
      fixedSize: fixedSize,
      write: writeImpl,
    );
  }

  final maxSize = _getUnionMaxSize(variants);

  return VariableSizeEncoder<Union2<T0, T1>>(
    getSizeFromValue: (variant) {
      return switch (variant) {
        Union2Variant0<T0, T1>(:final value) => getEncodedSize(value, variant0),
        Union2Variant1<T0, T1>(:final value) => getEncodedSize(value, variant1),
      };
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder for a two-variant typed union.
Decoder<Union2<T0, T1>> getUnion2Decoder<T0, T1>(
  Decoder<T0> variant0,
  Decoder<T1> variant1,
  int Function(Uint8List bytes, int offset) getIndexFromBytes,
) {
  final variants = <Object>[variant0, variant1];
  final fixedSize = _getUnionFixedSize(variants);

  (Union2<T0, T1>, int) readImpl(Uint8List bytes, int offset) {
    final index = getIndexFromBytes(bytes, offset);
    _assertValidVariantIndex(variants, index);

    return switch (index) {
      0 => () {
        final (value, nextOffset) = variant0.read(bytes, offset);
        return (Union2Variant0<T0, T1>(value), nextOffset);
      }(),
      1 => () {
        final (value, nextOffset) = variant1.read(bytes, offset);
        return (Union2Variant1<T0, T1>(value), nextOffset);
      }(),
      _ => throw StateError('Unreachable variant index: $index'),
    };
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<Union2<T0, T1>>(
      fixedSize: fixedSize,
      read: readImpl,
    );
  }

  final maxSize = _getUnionMaxSize(variants);
  return VariableSizeDecoder<Union2<T0, T1>>(read: readImpl, maxSize: maxSize);
}

/// Returns a codec for a two-variant typed union.
Codec<Union2<T0From, T1From>, Union2<T0To, T1To>>
getUnion2Codec<T0From, T0To, T1From, T1To>(
  Codec<T0From, T0To> variant0,
  Codec<T1From, T1To> variant1,
  int Function(Uint8List bytes, int offset) getIndexFromBytes,
) {
  return combineCodec(
    getUnion2Encoder<T0From, T1From>(
      encoderFromCodec(variant0),
      encoderFromCodec(variant1),
    ),
    getUnion2Decoder<T0To, T1To>(
      decoderFromCodec(variant0),
      decoderFromCodec(variant1),
      getIndexFromBytes,
    ),
  );
}

/// Returns an encoder for a three-variant typed union.
Encoder<Union3<T0, T1, T2>> getUnion3Encoder<T0, T1, T2>(
  Encoder<T0> variant0,
  Encoder<T1> variant1,
  Encoder<T2> variant2,
) {
  final variants = <Object>[variant0, variant1, variant2];
  final fixedSize = _getUnionFixedSize(variants);

  int writeImpl(Union3<T0, T1, T2> variant, Uint8List bytes, int offset) {
    return switch (variant) {
      Union3Variant0<T0, T1, T2>(:final value) => variant0.write(
        value,
        bytes,
        offset,
      ),
      Union3Variant1<T0, T1, T2>(:final value) => variant1.write(
        value,
        bytes,
        offset,
      ),
      Union3Variant2<T0, T1, T2>(:final value) => variant2.write(
        value,
        bytes,
        offset,
      ),
    };
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<Union3<T0, T1, T2>>(
      fixedSize: fixedSize,
      write: writeImpl,
    );
  }

  final maxSize = _getUnionMaxSize(variants);

  return VariableSizeEncoder<Union3<T0, T1, T2>>(
    getSizeFromValue: (variant) {
      return switch (variant) {
        Union3Variant0<T0, T1, T2>(:final value) => getEncodedSize(
          value,
          variant0,
        ),
        Union3Variant1<T0, T1, T2>(:final value) => getEncodedSize(
          value,
          variant1,
        ),
        Union3Variant2<T0, T1, T2>(:final value) => getEncodedSize(
          value,
          variant2,
        ),
      };
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder for a three-variant typed union.
Decoder<Union3<T0, T1, T2>> getUnion3Decoder<T0, T1, T2>(
  Decoder<T0> variant0,
  Decoder<T1> variant1,
  Decoder<T2> variant2,
  int Function(Uint8List bytes, int offset) getIndexFromBytes,
) {
  final variants = <Object>[variant0, variant1, variant2];
  final fixedSize = _getUnionFixedSize(variants);

  (Union3<T0, T1, T2>, int) readImpl(Uint8List bytes, int offset) {
    final index = getIndexFromBytes(bytes, offset);
    _assertValidVariantIndex(variants, index);

    return switch (index) {
      0 => () {
        final (value, nextOffset) = variant0.read(bytes, offset);
        return (Union3Variant0<T0, T1, T2>(value), nextOffset);
      }(),
      1 => () {
        final (value, nextOffset) = variant1.read(bytes, offset);
        return (Union3Variant1<T0, T1, T2>(value), nextOffset);
      }(),
      2 => () {
        final (value, nextOffset) = variant2.read(bytes, offset);
        return (Union3Variant2<T0, T1, T2>(value), nextOffset);
      }(),
      _ => throw StateError('Unreachable variant index: $index'),
    };
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<Union3<T0, T1, T2>>(
      fixedSize: fixedSize,
      read: readImpl,
    );
  }

  final maxSize = _getUnionMaxSize(variants);
  return VariableSizeDecoder<Union3<T0, T1, T2>>(
    read: readImpl,
    maxSize: maxSize,
  );
}

/// Returns a codec for a three-variant typed union.
Codec<Union3<T0From, T1From, T2From>, Union3<T0To, T1To, T2To>>
getUnion3Codec<T0From, T0To, T1From, T1To, T2From, T2To>(
  Codec<T0From, T0To> variant0,
  Codec<T1From, T1To> variant1,
  Codec<T2From, T2To> variant2,
  int Function(Uint8List bytes, int offset) getIndexFromBytes,
) {
  return combineCodec(
    getUnion3Encoder<T0From, T1From, T2From>(
      encoderFromCodec(variant0),
      encoderFromCodec(variant1),
      encoderFromCodec(variant2),
    ),
    getUnion3Decoder<T0To, T1To, T2To>(
      decoderFromCodec(variant0),
      decoderFromCodec(variant1),
      decoderFromCodec(variant2),
      getIndexFromBytes,
    ),
  );
}

void _assertValidVariantIndex(List<Object> variants, int index) {
  if (index < 0 || index >= variants.length) {
    throw SolanaError(SolanaErrorCode.codecsUnionVariantOutOfRange, {
      'maxRange': variants.length - 1,
      'minRange': 0,
      'variant': index,
    });
  }
}

int? _getUnionFixedSize(List<Object> variants) {
  if (variants.isEmpty) return 0;
  final firstSize = getFixedSize(variants[0]);
  if (firstSize == null) return null;
  for (final variant in variants) {
    final size = getFixedSize(variant);
    if (size != firstSize) return null;
  }
  return firstSize;
}

int? _getUnionMaxSize(List<Object> variants) {
  return maxCodecSizes(variants.map(getMaxSize).toList());
}
