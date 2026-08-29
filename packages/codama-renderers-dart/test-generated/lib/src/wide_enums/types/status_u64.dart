// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum StatusU64 {
  inactive,
  active,
}

Encoder<StatusU64> getStatusU64Encoder() {
  return transformEncoder(
    getU64Encoder(),
    (StatusU64 value) => BigInt.from(value.index),
  );
}

Decoder<StatusU64> getStatusU64Decoder() {
  return transformDecoder(
    getU64Decoder(),
    (BigInt value, Uint8List bytes, int offset) {
      if (value.isNegative || value >= BigInt.from(StatusU64.values.length)) {
        throw RangeError('Invalid StatusU64 discriminator: ' + value.toString());
      }
      return StatusU64.values[value.toInt()];
    },
  );
}

Codec<StatusU64, StatusU64> getStatusU64Codec() {
  return combineCodec(getStatusU64Encoder(), getStatusU64Decoder());
}
