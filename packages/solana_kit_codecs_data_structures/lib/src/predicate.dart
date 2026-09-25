import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/src/utils.dart';

/// Returns an encoder that selects between two encoders using [predicate].
///
/// When [predicate] returns `true`, [ifTrue] is used; otherwise [ifFalse].
Encoder<TFrom> getPredicateEncoder<TFrom>(
  bool Function(TFrom value) predicate,
  Encoder<TFrom> ifTrue,
  Encoder<TFrom> ifFalse,
) {
  final trueFixedSize = getFixedSize(ifTrue);
  final falseFixedSize = getFixedSize(ifFalse);

  int writeImpl(TFrom value, Uint8List bytes, int offset) {
    final encoder = predicate(value) ? ifTrue : ifFalse;
    return encoder.write(value, bytes, offset);
  }

  if (trueFixedSize != null &&
      falseFixedSize != null &&
      trueFixedSize == falseFixedSize) {
    return FixedSizeEncoder<TFrom>(fixedSize: trueFixedSize, write: writeImpl);
  }

  final maxSize = maxCodecSizes([getMaxSize(ifTrue), getMaxSize(ifFalse)]);
  return VariableSizeEncoder<TFrom>(
    getSizeFromValue: (value) {
      final encoder = predicate(value) ? ifTrue : ifFalse;
      return getEncodedSize(value, encoder);
    },
    write: writeImpl,
    maxSize: maxSize,
  );
}

/// Returns a decoder that selects between two decoders using [predicate].
///
/// When [predicate] returns `true` for the encoded bytes, [ifTrue] is used;
/// otherwise [ifFalse].
Decoder<TTo> getPredicateDecoder<TTo>(
  bool Function(Uint8List value) predicate,
  Decoder<TTo> ifTrue,
  Decoder<TTo> ifFalse,
) {
  final trueFixedSize = getFixedSize(ifTrue);
  final falseFixedSize = getFixedSize(ifFalse);

  (TTo, int) readImpl(Uint8List bytes, int offset) {
    final decoder = predicate(bytes) ? ifTrue : ifFalse;
    return decoder.read(bytes, offset);
  }

  if (trueFixedSize != null &&
      falseFixedSize != null &&
      trueFixedSize == falseFixedSize) {
    return FixedSizeDecoder<TTo>(fixedSize: trueFixedSize, read: readImpl);
  }

  final maxSize = maxCodecSizes([getMaxSize(ifTrue), getMaxSize(ifFalse)]);
  return VariableSizeDecoder<TTo>(read: readImpl, maxSize: maxSize);
}

/// Returns a codec that selects between two codecs using predicates.
///
/// [encodePredicate] is used when encoding, and [decodePredicate] is used when
/// decoding.
Codec<TFrom, TTo> getPredicateCodec<TFrom, TTo extends TFrom>(
  bool Function(TFrom value) encodePredicate,
  bool Function(Uint8List value) decodePredicate,
  Codec<TFrom, TTo> ifTrue,
  Codec<TFrom, TTo> ifFalse,
) {
  return combineCodec(
    getPredicateEncoder<TFrom>(
      encodePredicate,
      encoderFromCodec(ifTrue),
      encoderFromCodec(ifFalse),
    ),
    getPredicateDecoder<TTo>(
      decodePredicate,
      decoderFromCodec(ifTrue),
      decoderFromCodec(ifFalse),
    ),
  );
}
