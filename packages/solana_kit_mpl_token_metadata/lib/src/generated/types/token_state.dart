// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum TokenState {
  unlocked,
  locked,
  listed,
}

Encoder<TokenState> getTokenStateEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (TokenState value) => value.index,
  );
}

Decoder<TokenState> getTokenStateDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => TokenState.values[value],
  );
}

Codec<TokenState, TokenState> getTokenStateCodec() {
  return combineCodec(getTokenStateEncoder(), getTokenStateDecoder());
}
