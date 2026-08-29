// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum StatusU8 {
  inactive,
  active,
}

Encoder<StatusU8> getStatusU8Encoder() {
  return transformEncoder(
    getU8Encoder(),
    (StatusU8 value) => value.index,
  );
}

Decoder<StatusU8> getStatusU8Decoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => StatusU8.values[value],
  );
}

Codec<StatusU8, StatusU8> getStatusU8Codec() {
  return combineCodec(getStatusU8Encoder(), getStatusU8Decoder());
}
