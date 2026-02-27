// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final fixedCodec = getArrayCodec(
    getU8Codec(),
    size: const FixedArraySize(3),
  );

  final encoded = fixedCodec.encode([10, 20, 30]);
  final decoded = fixedCodec.decode(encoded);

  print('Fixed-size encoded bytes: $encoded');
  print('Fixed-size decoded array: $decoded');
}
