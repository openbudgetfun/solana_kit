// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum PoolStatus {
  uninitialized,
  active,
  paused,
  deprecated,
}

Encoder<PoolStatus> getPoolStatusEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (PoolStatus value) => value.index,
  );
}

Decoder<PoolStatus> getPoolStatusDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => PoolStatus.values[value],
  );
}

Codec<PoolStatus, PoolStatus> getPoolStatusCodec() {
  return combineCodec(getPoolStatusEncoder(), getPoolStatusDecoder());
}
