// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum StakeAuthorize { staker, withdrawer }

Encoder<StakeAuthorize> getStakeAuthorizeEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (StakeAuthorize value) => value.index,
  );
}

Decoder<StakeAuthorize> getStakeAuthorizeDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => StakeAuthorize.values[value],
  );
}

Codec<StakeAuthorize, StakeAuthorize> getStakeAuthorizeCodec() {
  return combineCodec(getStakeAuthorizeEncoder(), getStakeAuthorizeDecoder());
}
