import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// Sums a list of nullable codec sizes. Returns `null` if any size is `null`.
int? sumCodecSizes(List<int?> sizes) {
  var total = 0;
  for (final size in sizes) {
    if (size == null) return null;
    total += size;
  }
  return total;
}

/// Returns the maximum from a list of nullable codec sizes.
/// Returns `null` if any size is `null`.
int? maxCodecSizes(List<int?> sizes) {
  var result = 0;
  for (final size in sizes) {
    if (size == null) return null;
    if (size > result) result = size;
  }
  return result;
}

/// Returns the fixed size of a codec, encoder, or decoder, or `null` if it
/// is variable-size.
int? getFixedSize(Object codec) {
  if (codec is FixedSizeEncoder) return codec.fixedSize;
  if (codec is FixedSizeDecoder) return codec.fixedSize;
  if (codec is FixedSizeCodec) return codec.fixedSize;
  return null;
}

/// Returns the max size of a codec, encoder, or decoder.
/// For fixed-size objects, returns the fixed size.
/// For variable-size objects, returns `maxSize` (which may be `null`).
int? getMaxSize(Object codec) {
  if (codec is FixedSizeEncoder) return codec.fixedSize;
  if (codec is FixedSizeDecoder) return codec.fixedSize;
  if (codec is FixedSizeCodec) return codec.fixedSize;
  if (codec is VariableSizeEncoder) return codec.maxSize;
  if (codec is VariableSizeDecoder) return codec.maxSize;
  if (codec is VariableSizeCodec) return codec.maxSize;
  return null;
}
