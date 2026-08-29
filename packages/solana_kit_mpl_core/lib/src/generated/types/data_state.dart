// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum DataState {
  accountState,
  ledgerState,
}

Encoder<DataState> getDataStateEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (DataState value) => value.index,
  );
}

Decoder<DataState> getDataStateDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => DataState.values[value],
  );
}

Codec<DataState, DataState> getDataStateCodec() {
  return combineCodec(getDataStateEncoder(), getDataStateDecoder());
}
