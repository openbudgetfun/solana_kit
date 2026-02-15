import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// Returns an encoder for raw byte arrays.
///
/// This encoder writes byte arrays exactly as provided without modification.
/// The size of the encoded byte array is determined by the length of the input.
VariableSizeEncoder<Uint8List> getBytesEncoder() {
  return VariableSizeEncoder<Uint8List>(
    getSizeFromValue: (Uint8List value) => value.length,
    write: (Uint8List value, Uint8List bytes, int offset) {
      bytes.setAll(offset, value);
      return offset + value.length;
    },
  );
}

/// Returns a decoder for raw byte arrays.
///
/// This decoder reads byte arrays exactly as provided without modification.
/// The decoded byte array extends from the provided offset to the end of
/// the input.
VariableSizeDecoder<Uint8List> getBytesDecoder() {
  return VariableSizeDecoder<Uint8List>(
    read: (Uint8List bytes, int offset) {
      final slice = bytes.sublist(offset);
      return (slice, offset + slice.length);
    },
  );
}

/// Returns a codec for encoding and decoding raw byte arrays.
///
/// This codec serializes and deserializes byte arrays without modification.
VariableSizeCodec<Uint8List, Uint8List> getBytesCodec() {
  return combineCodec(getBytesEncoder(), getBytesDecoder())
      as VariableSizeCodec<Uint8List, Uint8List>;
}
