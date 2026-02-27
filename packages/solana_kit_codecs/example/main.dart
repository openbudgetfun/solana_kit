// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_codecs/solana_kit_codecs.dart';

void main() {
  final codec = getArrayCodec(getU8Codec());

  final encoded = codec.encode([1, 2, 3]);
  final decoded = codec.decode(encoded);

  print('Encoded bytes: $encoded');
  print('Decoded array: $decoded');
}
