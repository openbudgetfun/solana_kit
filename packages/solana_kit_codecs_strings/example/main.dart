// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  final codec = getBase10Codec();

  final encoded = codec.encode('1024');
  final decoded = codec.decode(encoded);

  print('Encoded base10 bytes: $encoded');
  print('Decoded base10 string: $decoded');
}
