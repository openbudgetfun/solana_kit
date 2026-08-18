import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/assertions.dart';
import 'package:solana_kit_codecs_core/src/bytes.dart';
import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Creates a fixed-size encoder from a given [encoder].
///
/// The resulting encoder always produces exactly [fixedBytes] bytes.
/// If smaller, it is padded with trailing zeroes.
///
/// By default, values larger than [fixedBytes] are truncated for compatibility
/// with `@solana/codecs-core`. Set [allowTruncation] to `false` for
/// fixed-capacity fields where an oversized value must be rejected instead.
/// The error is thrown before any bytes are written to the destination buffer.
FixedSizeEncoder<TFrom> fixEncoderSize<TFrom>(
  Encoder<TFrom> encoder,
  int fixedBytes, {
  bool allowTruncation = true,
}) {
  return FixedSizeEncoder<TFrom>(
    fixedSize: fixedBytes,
    write: (value, bytes, offset) {
      // Use encode() to contain the encoder within its own bounds.
      final variableByteArray = encoder.encode(value);
      final Uint8List fixedByteArray;

      if (variableByteArray.length > fixedBytes && !allowTruncation) {
        throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
          'codecDescription': 'fixEncoderSize',
          'expected': fixedBytes,
          'bytesLength': variableByteArray.length,
        });
      }

      if (variableByteArray.length > fixedBytes) {
        fixedByteArray = variableByteArray.sublist(0, fixedBytes);
      } else {
        fixedByteArray = variableByteArray;
      }
      bytes.setAll(offset, fixedByteArray);
      return offset + fixedBytes;
    },
  );
}

/// Creates a fixed-size decoder from a given [decoder].
///
/// The resulting decoder always reads exactly [fixedBytes] bytes from
/// the input.
FixedSizeDecoder<TTo> fixDecoderSize<TTo>(
  Decoder<TTo> decoder,
  int fixedBytes,
) {
  return FixedSizeDecoder<TTo>(
    fixedSize: fixedBytes,
    read: (bytes, offset) {
      assertByteArrayHasEnoughBytesForCodec(
        'fixCodecSize',
        fixedBytes,
        bytes,
        offset,
      );
      // Slice the byte array to the fixed size if necessary.
      Uint8List sliced;
      if (offset > 0 || bytes.length > fixedBytes) {
        sliced = bytes.sublist(offset, offset + fixedBytes);
      } else {
        sliced = bytes;
      }
      // If the nested decoder is fixed-size, pad and truncate accordingly.
      if (decoder case FixedSizeDecoder<TTo>(:final fixedSize)) {
        sliced = fixBytes(sliced, fixedSize);
      }
      // Decode the value using the nested decoder.
      final (value, _) = decoder.read(sliced, 0);
      return (value, offset + fixedBytes);
    },
  );
}

/// Creates a fixed-size codec from a given [codec].
///
/// Both encoding and decoding operate on exactly [fixedBytes] bytes.
/// Set [allowTruncation] to `false` to reject encoded values larger than the
/// fixed capacity instead of silently truncating them.
FixedSizeCodec<TFrom, TTo> fixCodecSize<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  int fixedBytes, {
  bool allowTruncation = true,
}) {
  return combineCodec(
        fixEncoderSize(
          encoderFromCodec(codec),
          fixedBytes,
          allowTruncation: allowTruncation,
        ),
        fixDecoderSize(decoderFromCodec(codec), fixedBytes),
      )
      as FixedSizeCodec<TFrom, TTo>;
}
