// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

void main() {
  final asciiCodec = VariableSizeCodec<String, String>(
    getSizeFromValue: (value) => value.length,
    write: (value, bytes, offset) {
      final charCodes = value.codeUnits;
      bytes.setAll(offset, charCodes);
      return offset + charCodes.length;
    },
    read: (bytes, offset) {
      final value = String.fromCharCodes(bytes.sublist(offset));
      return (value, bytes.length);
    },
  );

  final terminatedCodec = addCodecSentinel(
    asciiCodec,
    Uint8List.fromList([0]),
  );

  final encoded = terminatedCodec.encode('HELLO');
  final decoded = terminatedCodec.decode(encoded);

  print('Encoded bytes: $encoded');
  print('Decoded value: $decoded');
}
