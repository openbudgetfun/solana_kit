// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum HolderDelegateRole {
  printDelegate,
}

Encoder<HolderDelegateRole> getHolderDelegateRoleEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (HolderDelegateRole value) => value.index,
  );
}

Decoder<HolderDelegateRole> getHolderDelegateRoleDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) =>
        HolderDelegateRole.values[value],
  );
}

Codec<HolderDelegateRole, HolderDelegateRole> getHolderDelegateRoleCodec() {
  return combineCodec(
    getHolderDelegateRoleEncoder(),
    getHolderDelegateRoleDecoder(),
  );
}
