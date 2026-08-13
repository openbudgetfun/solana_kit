// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum NonceState {
  uninitialized,
  initialized,
}

Encoder<NonceState> getNonceStateEncoder() {
  return transformEncoder(
    getU32Encoder(),
    (NonceState value) => value.index,
  );
}

Decoder<NonceState> getNonceStateDecoder() {
  return transformDecoder(
    getU32Decoder(),
    (int value, Uint8List bytes, int offset) => NonceState.values[value],
  );
}

Codec<NonceState, NonceState> getNonceStateCodec() {
  return combineCodec(getNonceStateEncoder(), getNonceStateDecoder());
}
