import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/null_characters.dart';

/// Returns an encoder for UTF-8 strings.
///
/// This encoder serializes strings using UTF-8 encoding. The encoded output
/// contains as many bytes as needed to represent the string.
///
/// For more details, see [getUtf8Codec].
VariableSizeEncoder<String> getUtf8Encoder() {
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) => convert.utf8.encode(value).length,
    write: (value, bytes, offset) {
      final encoded = Uint8List.fromList(convert.utf8.encode(value));
      bytes.setAll(offset, encoded);
      return offset + encoded.length;
    },
  );
}

/// Returns a decoder for UTF-8 strings.
///
/// This decoder deserializes UTF-8 encoded strings from a byte array.
/// It reads all available bytes starting from the given offset.
///
/// For more details, see [getUtf8Codec].
VariableSizeDecoder<String> getUtf8Decoder() {
  return VariableSizeDecoder<String>(
    read: (bytes, offset) {
      final slice = bytes.sublist(offset);
      // TODO(security): removeNullCharacters silently strips null bytes from
      // decoded strings, which is data loss without notification. This matches
      // the TS SDK behavior, so changing it may break compatibility.
      final value = removeNullCharacters(convert.utf8.decode(slice));
      return (value, bytes.length);
    },
  );
}

/// Returns a codec for encoding and decoding UTF-8 strings.
///
/// This codec serializes strings using UTF-8 encoding. The encoded output
/// contains as many bytes as needed to represent the string.
VariableSizeCodec<String, String> getUtf8Codec() {
  return combineCodec(getUtf8Encoder(), getUtf8Decoder())
      as VariableSizeCodec<String, String>;
}
