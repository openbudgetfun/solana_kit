// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getF32Codec();

  final encoded = codec.encode(3.5);
  final decoded = codec.decode(encoded);

  print('Encoded float bytes: $encoded');
  print('Decoded float value: $decoded');
}
