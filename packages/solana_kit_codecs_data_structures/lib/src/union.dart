import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

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
    getSizeFromValue: (Object? variant) {
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
