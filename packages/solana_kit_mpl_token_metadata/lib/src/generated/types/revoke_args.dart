// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum RevokeArgs {
  collectionV1,
  saleV1,
  transferV1,
  dataV1,
  utilityV1,
  stakingV1,
  standardV1,
  lockedTransferV1,
  programmableConfigV1,
  migrationV1,
  authorityItemV1,
  dataItemV1,
  collectionItemV1,
  programmableConfigItemV1,
  printDelegateV1,
}

Encoder<RevokeArgs> getRevokeArgsEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (RevokeArgs value) => value.index,
  );
}

Decoder<RevokeArgs> getRevokeArgsDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => RevokeArgs.values[value],
  );
}

Codec<RevokeArgs, RevokeArgs> getRevokeArgsCodec() {
  return combineCodec(getRevokeArgsEncoder(), getRevokeArgsDecoder());
}
