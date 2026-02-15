import 'dart:typed_data';

import 'package:solana_kit_codecs_core/src/codec.dart';
import 'package:solana_kit_codecs_core/src/combine_codec.dart';

/// Reverses the bytes of a fixed-size encoder.
///
/// The returned encoder writes bytes in reverse order within the
/// fixed-size range.
FixedSizeEncoder<TFrom> reverseEncoder<TFrom>(
  FixedSizeEncoder<TFrom> encoder,
) {
  assertIsFixedSize(encoder);
  return FixedSizeEncoder<TFrom>(
    fixedSize: encoder.fixedSize,
    write: (value, bytes, offset) {
      final newOffset = encoder.write(value, bytes, offset);
      _copySourceToTargetInReverse(
        bytes, // source
        bytes, // target (in-place)
        offset, // sourceOffset
        offset + encoder.fixedSize, // sourceLength
      );
      return newOffset;
    },
  );
}

/// Reverses the bytes of a fixed-size decoder.
///
/// The returned decoder reverses bytes within the fixed-size range before
/// decoding.
FixedSizeDecoder<TTo> reverseDecoder<TTo>(
  FixedSizeDecoder<TTo> decoder,
) {
  assertIsFixedSize(decoder);
  return FixedSizeDecoder<TTo>(
    fixedSize: decoder.fixedSize,
    read: (bytes, offset) {
      final reversedBytes = Uint8List.fromList(bytes);
      _copySourceToTargetInReverse(
        bytes, // source
        reversedBytes, // target
        offset, // sourceOffset
        offset + decoder.fixedSize, // sourceLength
      );
      return decoder.read(reversedBytes, offset);
    },
  );
}

/// Reverses the bytes of a fixed-size codec.
///
/// Both encoding and decoding reverse bytes within the fixed-size range.
FixedSizeCodec<TFrom, TTo> reverseCodec<TFrom, TTo>(
  FixedSizeCodec<TFrom, TTo> codec,
) {
  return combineCodec(
    reverseEncoder(
      FixedSizeEncoder<TFrom>(
        fixedSize: codec.fixedSize,
        write: codec.write,
      ),
    ),
    reverseDecoder(
      FixedSizeDecoder<TTo>(fixedSize: codec.fixedSize, read: codec.read),
    ),
  ) as FixedSizeCodec<TFrom, TTo>;
}

/// Reverses bytes between [sourceStart] (inclusive) and [sourceEnd]
/// (exclusive), writing results into [target] starting at [targetOffset].
void _copySourceToTargetInReverse(
  Uint8List source,
  Uint8List target,
  int sourceStart,
  int sourceEnd, [
  int targetOffset = 0,
]) {
  var left = sourceStart;
  var right = sourceEnd;
  while (left < --right) {
    final leftValue = source[left];
    target[left + targetOffset] = source[right];
    target[right + targetOffset] = leftValue;
    left++;
  }
  if (left == right) {
    target[left + targetOffset] = source[left];
  }
}
