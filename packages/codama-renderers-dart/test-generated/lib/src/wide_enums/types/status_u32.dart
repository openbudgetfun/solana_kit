// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum StatusU32 {
  inactive,
  active,
}

Encoder<StatusU32> getStatusU32Encoder() {
  return transformEncoder(
    getU32Encoder(),
    (StatusU32 value) => value.index,
  );
}

Decoder<StatusU32> getStatusU32Decoder() {
  return transformDecoder(
    getU32Decoder(),
    (int value, Uint8List bytes, int offset) => StatusU32.values[value],
  );
}

Codec<StatusU32, StatusU32> getStatusU32Codec() {
  return combineCodec(getStatusU32Encoder(), getStatusU32Decoder());
}
