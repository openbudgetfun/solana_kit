// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum UseMethod {
  burn,
  multiple,
  single,
}

Encoder<UseMethod> getUseMethodEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (UseMethod value) => value.index,
  );
}

Decoder<UseMethod> getUseMethodDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => UseMethod.values[value],
  );
}

Codec<UseMethod, UseMethod> getUseMethodCodec() {
  return combineCodec(getUseMethodEncoder(), getUseMethodDecoder());
}
