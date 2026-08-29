// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum UpdateType {
  mint,
  add,
  remove,
}

Encoder<UpdateType> getUpdateTypeEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (UpdateType value) => value.index,
  );
}

Decoder<UpdateType> getUpdateTypeDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => UpdateType.values[value],
  );
}

Codec<UpdateType, UpdateType> getUpdateTypeCodec() {
  return combineCodec(getUpdateTypeEncoder(), getUpdateTypeDecoder());
}
