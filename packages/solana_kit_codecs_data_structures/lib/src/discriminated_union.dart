import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/tuple.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Returns an encoder for discriminated unions.
///
/// This encoder serializes maps that follow the discriminated union pattern
/// by prefixing them with a numerical discriminator that represents their
/// variant.
///
/// [variants] is a list of `(discriminatorValue, encoder)` pairs.
/// [discriminator] is the property name used as the discriminator
/// (defaults to `'__kind'`).
/// [size] is the number encoder for the discriminator prefix (defaults to u8).
Encoder<Map<String, Object?>> getDiscriminatedUnionEncoder(
  List<(Object?, Encoder<Object?>)> variants, {
  String discriminator = '__kind',
  Encoder<num>? size,
}) {
  final prefix = size ?? getU8Encoder();

  final variantEncoders = variants.indexed.map((entry) {
    final (index, (_, variant)) = entry;
    return transformEncoder<List<Object?>, Map<String, Object?>>(
      getTupleEncoder([prefix as Encoder<Object?>, variant]),
      (Map<String, Object?> value) => <Object?>[index, value],
    );
  }).toList();

  int getIndex(Map<String, Object?> value) {
    final discriminatorValue = value[discriminator];
    return _getVariantDiscriminator(variants, discriminatorValue);
  }

  // Determine fixed/variable size.
  final fixedSize = _getUnionFixedSize(variantEncoders);

  int writeImpl(Map<String, Object?> value, Uint8List bytes, int offset) {
    final index = getIndex(value);
    _assertValidVariantIndex(variantEncoders, index);
    return variantEncoders[index].write(value, bytes, offset);
  }

  if (fixedSize != null) {
    return FixedSizeEncoder<Map<String, Object?>>(
      fixedSize: fixedSize,
      write: writeImpl,
    );
  }

  final maxSize = _getUnionMaxSize(variantEncoders);

  return VariableSizeEncoder<Map<String, Object?>>(
    getSizeFromValue: (Map<String, Object?> value) {
      final index = getIndex(value);
      _assertValidVariantIndex(variantEncoders, index);
      return getEncodedSize(value, variantEncoders[index]);
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder for discriminated unions.
///
/// This decoder deserializes maps that follow the discriminated union pattern
/// by reading a numerical discriminator and mapping it to the corresponding
/// variant.
///
/// [variants] is a list of `(discriminatorValue, decoder)` pairs.
/// [discriminator] is the property name used as the discriminator
/// (defaults to `'__kind'`).
/// [size] is the number decoder for the discriminator prefix (defaults to u8).
Decoder<Map<String, Object?>> getDiscriminatedUnionDecoder(
  List<(Object?, Decoder<Object?>)> variants, {
  String discriminator = '__kind',
  Decoder<num>? size,
}) {
  final prefix = size ?? getU8Decoder();

  final variantDecoders = variants.map((entry) {
    final (discriminatorValue, variant) = entry;
    return transformDecoder<List<Object?>, Map<String, Object?>>(
      getTupleDecoder([prefix as Decoder<Object?>, variant]),
      (List<Object?> tuple, Uint8List bytes, int offset) {
        final value = tuple[1];
        final result = <String, Object?>{discriminator: discriminatorValue};
        if (value is Map<String, Object?>) {
          result.addAll(value);
        }
        return result;
      },
    );
  }).toList();

  // Determine fixed/variable size.
  final fixedSize = _getUnionFixedSize(variantDecoders);

  (Map<String, Object?>, int) readImpl(Uint8List bytes, int offset) {
    final (value, _) = prefix.read(bytes, offset);
    final index = value.toInt();
    _assertValidVariantIndex(variantDecoders, index);
    return variantDecoders[index].read(bytes, offset);
  }

  if (fixedSize != null) {
    return FixedSizeDecoder<Map<String, Object?>>(
      fixedSize: fixedSize,
      read: readImpl,
    );
  }

  final maxSize = _getUnionMaxSize(variantDecoders);
  return VariableSizeDecoder<Map<String, Object?>>(
    read: readImpl,
    maxSize: maxSize,
  );
}

/// Returns a codec for encoding and decoding discriminated unions.
///
/// A discriminated union is a representation of Rust-like enums, where each
/// variant is distinguished by a discriminator field (default: `'__kind'`).
///
/// [variants] is a list of `(discriminatorValue, codec)` pairs.
Codec<Map<String, Object?>, Map<String, Object?>> getDiscriminatedUnionCodec(
  List<(Object?, Codec<Object?, Object?>)> variants, {
  String discriminator = '__kind',
  Codec<num, num>? size,
}) {
  return combineCodec(
    getDiscriminatedUnionEncoder(
      variants.map((e) => (e.$1, encoderFromCodec(e.$2))).toList(),
      discriminator: discriminator,
      size: size != null ? encoderFromCodec(size) : null,
    ),
    getDiscriminatedUnionDecoder(
      variants.map((e) => (e.$1, decoderFromCodec(e.$2))).toList(),
      discriminator: discriminator,
      size: size != null ? decoderFromCodec(size) : null,
    ),
  );
}

int _getVariantDiscriminator(
  List<(Object?, Object)> variants,
  Object? discriminatorValue,
) {
  final index = variants.indexWhere((v) => v.$1 == discriminatorValue);
  if (index < 0) {
    throw SolanaError(SolanaErrorCode.codecsInvalidDiscriminatedUnionVariant, {
      'value': discriminatorValue,
      'variants': variants.map((v) => v.$1).toList(),
    });
  }
  return index;
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
    final s = getFixedSize(variant);
    if (s != firstSize) return null;
  }
  return firstSize;
}

int? _getUnionMaxSize(List<Object> variants) {
  return maxCodecSizes(variants.map(getMaxSize).toList());
}
