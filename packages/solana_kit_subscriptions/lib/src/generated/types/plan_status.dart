// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum PlanStatus {
  sunset,
  active,
}

Encoder<PlanStatus> getPlanStatusEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (PlanStatus value) => value.index,
  );
}

Decoder<PlanStatus> getPlanStatusDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => PlanStatus.values[value],
  );
}

Codec<PlanStatus, PlanStatus> getPlanStatusCodec() {
  return combineCodec(getPlanStatusEncoder(), getPlanStatusDecoder());
}
