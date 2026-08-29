// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum TokenDelegateRole {
  sale,
  transfer,
  utility,
  staking,
  standard,
  lockedTransfer,
  migration,
}

Encoder<TokenDelegateRole> getTokenDelegateRoleEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (TokenDelegateRole value) => value.index,
  );
}

Decoder<TokenDelegateRole> getTokenDelegateRoleDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => TokenDelegateRole.values[value],
  );
}

Codec<TokenDelegateRole, TokenDelegateRole> getTokenDelegateRoleCodec() {
  return combineCodec(
    getTokenDelegateRoleEncoder(),
    getTokenDelegateRoleDecoder(),
  );
}
