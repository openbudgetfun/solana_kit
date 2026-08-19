// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum StatusU16 {
  inactive,
  active,
}

Encoder<StatusU16> getStatusU16Encoder() {
  return transformEncoder(
    getU16Encoder(),
    (StatusU16 value) => value.index,
  );
}

Decoder<StatusU16> getStatusU16Decoder() {
  return transformDecoder(
    getU16Decoder(),
    (int value, Uint8List bytes, int offset) => StatusU16.values[value],
  );
}

Codec<StatusU16, StatusU16> getStatusU16Codec() {
  return combineCodec(getStatusU16Encoder(), getStatusU16Decoder());
}
