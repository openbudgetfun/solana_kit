import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Creates a [Decoder] that asserts the bytes provided to `decode` or `read`
/// are fully consumed by the inner [decoder].
///
/// Throws a [SolanaError] if the byte array is not entirely consumed.
Decoder<T> createDecoderThatConsumesEntireByteArray<T>(Decoder<T> decoder) {
  return switch (decoder) {
    FixedSizeDecoder<T>() => FixedSizeDecoder<T>(
      fixedSize: decoder.fixedSize,
      read: (bytes, offset) {
        final (value, newOffset) = decoder.read(bytes, offset);
        if (bytes.length > newOffset) {
          throw SolanaError(
            SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
            {
              'expectedLength': newOffset,
              'numExcessBytes': bytes.length - newOffset,
            },
          );
        }
        return (value, newOffset);
      },
    ),
    VariableSizeDecoder<T>() => VariableSizeDecoder<T>(
      read: (bytes, offset) {
        final (value, newOffset) = decoder.read(bytes, offset);
        if (bytes.length > newOffset) {
          throw SolanaError(
            SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray,
            {
              'expectedLength': newOffset,
              'numExcessBytes': bytes.length - newOffset,
            },
          );
        }
        return (value, newOffset);
      },
      maxSize: decoder.maxSize,
    ),
  };
}
