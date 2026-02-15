import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

const String _alphabet =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

/// Returns an encoder for base-64 strings.
///
/// This encoder serializes strings using a base-64 encoding scheme,
/// commonly used for data encoding in URLs, cryptographic keys, and
/// binary-to-text encoding.
///
/// For more details, see [getBase64Codec].
VariableSizeEncoder<String> getBase64Encoder() {
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) => _decodeBase64Tolerant(value).length,
    write: (value, bytes, offset) {
      final decoded = _decodeBase64Tolerant(value);
      bytes.setAll(offset, decoded);
      return offset + decoded.length;
    },
  );
}

/// Returns a decoder for base-64 strings.
///
/// This decoder deserializes base-64 encoded strings from a byte array.
///
/// For more details, see [getBase64Codec].
VariableSizeDecoder<String> getBase64Decoder() {
  return VariableSizeDecoder<String>(
    read: (bytes, offset) {
      final slice = bytes.sublist(offset);
      final value = convert.base64.encode(slice);
      return (value, bytes.length);
    },
  );
}

/// Returns a codec for encoding and decoding base-64 strings.
///
/// This codec serializes strings using a base-64 encoding scheme,
/// commonly used for data encoding in URLs, cryptographic keys, and
/// binary-to-text encoding.
VariableSizeCodec<String, String> getBase64Codec() {
  return combineCodec(getBase64Encoder(), getBase64Decoder())
      as VariableSizeCodec<String, String>;
}

/// Decodes a base-64 string tolerantly, similar to Node.js Buffer behavior.
///
/// This handles missing padding and incomplete trailing characters gracefully.
/// A single trailing character that cannot form a complete byte is dropped.
Uint8List _decodeBase64Tolerant(String value) {
  // Validate the string contains only base64 characters (ignoring padding).
  final stripped = value.replaceAll('=', '');
  for (var i = 0; i < stripped.length; i++) {
    if (!_alphabet.contains(stripped[i])) {
      throw SolanaError(SolanaErrorCode.codecsInvalidStringForBase, {
        'alphabet': _alphabet,
        'base': 64,
        'value': value,
      });
    }
  }

  if (stripped.isEmpty) return Uint8List(0);

  // In base64, each char is 6 bits. We need at least 2 chars (12 bits) to
  // form 1 byte (8 bits). A single trailing char (6 bits) is dropped.
  // This matches Node.js Buffer.from(value, 'base64') behavior.
  final remainder = stripped.length % 4;

  // If remainder is 1, that's only 6 bits - not enough for a byte.
  // Drop the last character to form valid base64.
  final effectiveChars = remainder == 1
      ? stripped.substring(0, stripped.length - 1)
      : stripped;

  if (effectiveChars.isEmpty) return Uint8List(0);

  // Pad to multiple of 4.
  final padded = effectiveChars.length % 4 == 0
      ? effectiveChars
      : effectiveChars.padRight(
          effectiveChars.length + (4 - effectiveChars.length % 4),
          '=',
        );

  try {
    return Uint8List.fromList(convert.base64.decode(padded));
  } on Object {
    throw SolanaError(SolanaErrorCode.codecsInvalidStringForBase, {
      'alphabet': _alphabet,
      'base': 64,
      'value': value,
    });
  }
}
