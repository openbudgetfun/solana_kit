// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum AccountState {
  uninitialized,
  initialized,
  frozen,
}

Encoder<AccountState> getAccountStateEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (AccountState value) => value.index,
  );
}

Decoder<AccountState> getAccountStateDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => AccountState.values[value],
  );
}

Codec<AccountState, AccountState> getAccountStateCodec() {
  return combineCodec(getAccountStateEncoder(), getAccountStateDecoder());
}
