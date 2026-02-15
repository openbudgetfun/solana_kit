import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// Returns an encoder for `void` values.
///
/// This encoder writes nothing to the byte array and has a fixed size of
/// 0 bytes. It is useful when working with structures that require a no-op
/// encoder, such as empty variants in discriminated unions.
FixedSizeEncoder<void> getUnitEncoder() {
  return FixedSizeEncoder<void>(
    fixedSize: 0,
    write: (_, Uint8List bytes, int offset) => offset,
  );
}

/// Returns a decoder for `void` values.
///
/// This decoder always returns `null` and has a fixed size of 0 bytes.
FixedSizeDecoder<void> getUnitDecoder() {
  return FixedSizeDecoder<void>(
    fixedSize: 0,
    read: (Uint8List bytes, int offset) => (null, offset),
  );
}

/// Returns a codec for `void` values.
///
/// This codec does nothing when encoding or decoding and has a fixed size of
/// 0 bytes.
FixedSizeCodec<void, void> getUnitCodec() {
  return combineCodec(getUnitEncoder(), getUnitDecoder())
      as FixedSizeCodec<void, void>;
}
