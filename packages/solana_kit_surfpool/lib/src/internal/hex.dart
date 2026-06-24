import 'dart:typed_data';

const _hexDigits = '0123456789abcdef';

/// Converts [bytes] to a lowercase hexadecimal string.
String bytesToHex(Uint8List bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer
      ..write(_hexDigits[(byte >> 4) & 0x0f])
      ..write(_hexDigits[byte & 0x0f]);
  }
  return buffer.toString();
}
