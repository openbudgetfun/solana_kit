import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Combines an [Encoder] and a [Decoder] into a [Codec].
///
/// The encoder and decoder must be compatible in terms of size:
/// - If both are fixed-size, they must have the same `fixedSize`.
/// - If both are variable-size, their `maxSize` values must match.
/// - Mixing fixed-size and variable-size throws a [SolanaError].
Codec<TFrom, TTo> combineCodec<TFrom, TTo>(
  Encoder<TFrom> encoder,
  Decoder<TTo> decoder,
) {
  final encoderIsFixed = isFixedSize(encoder);
  final decoderIsFixed = isFixedSize(decoder);

  if (encoderIsFixed != decoderIsFixed) {
    throw SolanaError(
      SolanaErrorCode.codecsEncoderDecoderSizeCompatibilityMismatch,
    );
  }

  if (encoderIsFixed && decoderIsFixed) {
    final enc = encoder as FixedSizeEncoder<TFrom>;
    final dec = decoder as FixedSizeDecoder<TTo>;
    if (enc.fixedSize != dec.fixedSize) {
      throw SolanaError(
        SolanaErrorCode.codecsEncoderDecoderFixedSizeMismatch,
        {
          'decoderFixedSize': dec.fixedSize,
          'encoderFixedSize': enc.fixedSize,
        },
      );
    }
    return FixedSizeCodec<TFrom, TTo>(
      fixedSize: enc.fixedSize,
      write: encoder.write,
      read: decoder.read,
    );
  }

  // Both are variable-size.
  final enc = encoder as VariableSizeEncoder<TFrom>;
  final dec = decoder as VariableSizeDecoder<TTo>;
  if (enc.maxSize != dec.maxSize) {
    throw SolanaError(
      SolanaErrorCode.codecsEncoderDecoderMaxSizeMismatch,
      {
        'decoderMaxSize': dec.maxSize,
        'encoderMaxSize': enc.maxSize,
      },
    );
  }

  return VariableSizeCodec<TFrom, TTo>(
    getSizeFromValue: enc.getSizeFromValue,
    write: encoder.write,
    read: decoder.read,
    maxSize: enc.maxSize,
  );
}
