// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum TokenStandard {
  nonFungible,
  fungibleAsset,
  fungible,
  nonFungibleEdition,
  programmableNonFungible,
  programmableNonFungibleEdition,
}

Encoder<TokenStandard> getTokenStandardEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (TokenStandard value) => value.index,
  );
}

Decoder<TokenStandard> getTokenStandardDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => TokenStandard.values[value],
  );
}

Codec<TokenStandard, TokenStandard> getTokenStandardCodec() {
  return combineCodec(getTokenStandardEncoder(), getTokenStandardDecoder());
}
