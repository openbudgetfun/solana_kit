import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/bytes.dart';
import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/codec_utils.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Creates an encoder that writes a [sentinel] byte sequence after the
/// encoded value.
///
/// This is useful to delimit the encoded value when being read by a decoder.
///
/// Throws a [SolanaError] if the encoded bytes contain the sentinel.
Encoder<TFrom> addEncoderSentinel<TFrom>(
  Encoder<TFrom> encoder,
  Uint8List sentinel,
) {
  int writeImpl(TFrom value, Uint8List bytes, int currentOffset) {
    // Use encode() to contain the encoder within its own bounds.
    final encoderBytes = encoder.encode(value);
    if (_findSentinelIndex(encoderBytes, sentinel) >= 0) {
      throw SolanaError(
        SolanaErrorCode.codecsEncodedBytesMustNotIncludeSentinel,
        {
          'encodedBytes': encoderBytes,
          'hexEncodedBytes': _hexBytes(encoderBytes),
          'hexSentinel': _hexBytes(sentinel),
          'sentinel': sentinel,
        },
      );
    }
    bytes.setAll(currentOffset, encoderBytes);
    final afterContent = currentOffset + encoderBytes.length;
    bytes.setAll(afterContent, sentinel);
    return afterContent + sentinel.length;
  }

  if (encoder case FixedSizeEncoder<TFrom>(:final fixedSize)) {
    return FixedSizeEncoder<TFrom>(
      fixedSize: fixedSize + sentinel.length,
      write: writeImpl,
    );
  }

  final enc = encoder as VariableSizeEncoder<TFrom>;
  return VariableSizeEncoder<TFrom>(
    getSizeFromValue: (value) =>
        enc.getSizeFromValue(value) + sentinel.length,
    write: writeImpl,
    maxSize: enc.maxSize != null ? enc.maxSize! + sentinel.length : null,
  );
}

/// Creates a decoder that continues reading until a given [sentinel]
/// byte sequence is found.
///
/// Throws a [SolanaError] if the sentinel is not found in the byte array.
Decoder<TTo> addDecoderSentinel<TTo>(
  Decoder<TTo> decoder,
  Uint8List sentinel,
) {
  (TTo, int) readImpl(Uint8List bytes, int currentOffset) {
    final candidateBytes =
        currentOffset == 0 ? bytes : bytes.sublist(currentOffset);
    final sentinelIndex = _findSentinelIndex(candidateBytes, sentinel);
    if (sentinelIndex == -1) {
      throw SolanaError(
        SolanaErrorCode.codecsSentinelMissingInDecodedBytes,
        {
          'decodedBytes': candidateBytes,
          'hexDecodedBytes': _hexBytes(candidateBytes),
          'hexSentinel': _hexBytes(sentinel),
          'sentinel': sentinel,
        },
      );
    }
    final preSentinelBytes = candidateBytes.sublist(0, sentinelIndex);
    // Use decode() to contain the decoder within its own bounds.
    return (
      decoder.decode(preSentinelBytes),
      currentOffset + preSentinelBytes.length + sentinel.length,
    );
  }

  if (decoder case FixedSizeDecoder<TTo>(:final fixedSize)) {
    return FixedSizeDecoder<TTo>(
      fixedSize: fixedSize + sentinel.length,
      read: readImpl,
    );
  }

  final dec = decoder as VariableSizeDecoder<TTo>;
  return VariableSizeDecoder<TTo>(
    read: readImpl,
    maxSize: dec.maxSize != null ? dec.maxSize! + sentinel.length : null,
  );
}

/// Creates a codec that writes a [sentinel] byte sequence after the encoded
/// value and, when decoding, reads until the sentinel is found.
Codec<TFrom, TTo> addCodecSentinel<TFrom, TTo>(
  Codec<TFrom, TTo> codec,
  Uint8List sentinel,
) {
  return combineCodec(
    addEncoderSentinel(encoderFromCodec(codec), sentinel),
    addDecoderSentinel(decoderFromCodec(codec), sentinel),
  );
}

/// Finds the first index in [bytes] where [sentinel] starts.
///
/// Returns -1 if not found.
int _findSentinelIndex(Uint8List bytes, Uint8List sentinel) {
  for (var i = 0; i < bytes.length; i++) {
    if (sentinel.length == 1) {
      if (bytes[i] == sentinel[0]) return i;
    } else {
      if (containsBytes(bytes, sentinel, i)) return i;
    }
  }
  return -1;
}

/// Converts [bytes] to a hex string.
String _hexBytes(Uint8List bytes) {
  return bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}
