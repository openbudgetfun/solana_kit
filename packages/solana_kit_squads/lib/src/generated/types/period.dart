// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum Period {
  oneTime,
  day,
  week,
  month,
}

Encoder<Period> getPeriodEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (Period value) => value.index,
  );
}

Decoder<Period> getPeriodDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => Period.values[value],
  );
}

Codec<Period, Period> getPeriodCodec() {
  return combineCodec(getPeriodEncoder(), getPeriodDecoder());
}
