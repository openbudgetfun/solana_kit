import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

const String _alphabet = '0123456789abcdef';

/// Returns an encoder for base-16 (hexadecimal) strings.
///
/// This encoder serializes strings using a base-16 encoding scheme.
/// The output consists of bytes representing the hexadecimal values of the
/// input string.
///
/// For more details, see [getBase16Codec].
VariableSizeEncoder<String> getBase16Encoder() {
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) => (value.length / 2).ceil(),
    write: (value, bytes, offset) {
      final len = value.length;
      final al = len ~/ 2;

      if (len == 0) return offset;

      if (len == 1) {
        final n = _charCodeToBase16(value.codeUnitAt(0));
        if (n == -1) {
          throw SolanaError(SolanaErrorCode.codecsInvalidStringForBase, {
            'alphabet': _alphabet,
            'base': 16,
            'value': value,
          });
        }
        bytes[offset] = n;
        return 1 + offset;
      }

      final hexBytes = Uint8List(al);
      var j = 0;
      for (var i = 0; i < al; i++) {
        final c1 = value.codeUnitAt(j++);
        final c2 = value.codeUnitAt(j++);

        final n1 = _charCodeToBase16(c1);
        final n2 = _charCodeToBase16(c2);
        if (n1 == -1 || n2 == -1) {
          throw SolanaError(SolanaErrorCode.codecsInvalidStringForBase, {
            'alphabet': _alphabet,
            'base': 16,
            'value': value,
          });
        }
        hexBytes[i] = (n1 << 4) | n2;
      }

      bytes.setAll(offset, hexBytes);
      return hexBytes.length + offset;
    },
  );
}

/// Returns a decoder for base-16 (hexadecimal) strings.
///
/// This decoder deserializes base-16 encoded strings from a byte array.
///
/// For more details, see [getBase16Codec].
VariableSizeDecoder<String> getBase16Decoder() {
  return VariableSizeDecoder<String>(
    read: (bytes, offset) {
      final slice = bytes.sublist(offset);
      final value = slice
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      return (value, bytes.length);
    },
  );
}

/// Returns a codec for encoding and decoding base-16 (hexadecimal) strings.
///
/// This codec serializes strings using a base-16 encoding scheme. The
/// output consists of bytes representing the hexadecimal values of the input
/// string.
VariableSizeCodec<String, String> getBase16Codec() {
  return combineCodec(getBase16Encoder(), getBase16Decoder())
      as VariableSizeCodec<String, String>;
}

/// Convert a character code to its base-16 value, or -1 if invalid.
int _charCodeToBase16(int char) {
  // 0-9
  if (char >= 48 && char <= 57) return char - 48;
  // A-F
  if (char >= 65 && char <= 70) return char - 55;
  // a-f
  if (char >= 97 && char <= 102) return char - 87;
  return -1;
}
