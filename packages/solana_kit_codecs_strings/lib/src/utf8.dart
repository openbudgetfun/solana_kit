import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/src/null_characters.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Controls how UTF-8 decoders handle decoded null (`\u0000`) characters.
enum Utf8NullCharacterMode {
  /// Preserves `@solana/kit` compatibility by stripping decoded null characters.
  compatibilityStrip,

  /// Preserves decoded null characters in the returned Dart string.
  preserve,

  /// Rejects decoded strings that contain null characters.
  reject,
}

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
/// By default, decoded null characters are stripped to preserve
/// `@solana/kit` compatibility. Prefer [Utf8NullCharacterMode.reject] for
/// stricter Dart-first decoding when silent data loss would be risky.
///
/// For more details, see [getUtf8Codec].
VariableSizeDecoder<String> getUtf8Decoder({
  Utf8NullCharacterMode nullCharacterMode =
      Utf8NullCharacterMode.compatibilityStrip,
}) {
  return VariableSizeDecoder<String>(
    read: (bytes, offset) {
      final slice = bytes.sublist(offset);
      final decoded = convert.utf8.decode(slice);
      final value = _applyUtf8NullCharacterMode(
        decoded,
        nullCharacterMode: nullCharacterMode,
        byteLength: slice.length,
      );
      return (value, bytes.length);
    },
  );
}

/// Returns a decoder for UTF-8 strings that rejects decoded null characters.
VariableSizeDecoder<String> getStrictUtf8Decoder() {
  return getUtf8Decoder(nullCharacterMode: Utf8NullCharacterMode.reject);
}

/// Returns a codec for encoding and decoding UTF-8 strings.
///
/// This codec serializes strings using UTF-8 encoding. The encoded output
/// contains as many bytes as needed to represent the string.
///
/// By default, decoded null characters are stripped to preserve
/// `@solana/kit` compatibility. Prefer [Utf8NullCharacterMode.reject] for
/// stricter Dart-first decoding when silent data loss would be risky.
VariableSizeCodec<String, String> getUtf8Codec({
  Utf8NullCharacterMode nullCharacterMode =
      Utf8NullCharacterMode.compatibilityStrip,
}) {
  return combineCodec(
        getUtf8Encoder(),
        getUtf8Decoder(nullCharacterMode: nullCharacterMode),
      )
      as VariableSizeCodec<String, String>;
}

/// Returns a codec for encoding and decoding UTF-8 strings that rejects
/// decoded null characters.
VariableSizeCodec<String, String> getStrictUtf8Codec() {
  return getUtf8Codec(nullCharacterMode: Utf8NullCharacterMode.reject);
}

String _applyUtf8NullCharacterMode(
  String value, {
  required Utf8NullCharacterMode nullCharacterMode,
  required int byteLength,
}) {
  switch (nullCharacterMode) {
    case Utf8NullCharacterMode.compatibilityStrip:
      return removeNullCharacters(value);
    case Utf8NullCharacterMode.preserve:
      return value;
    case Utf8NullCharacterMode.reject:
      if (value.contains('\u0000')) {
        throw SolanaError(
          SolanaErrorCode.codecsStringContainsNullCharacters,
          {
            'encoding': 'utf8',
            'byteLength': byteLength,
            'nullCharacterMode': nullCharacterMode.name,
          },
        );
      }
      return value;
  }
}
