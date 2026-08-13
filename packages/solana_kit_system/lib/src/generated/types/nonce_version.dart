// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


enum NonceVersion {
  legacy,
  current,
}

Encoder<NonceVersion> getNonceVersionEncoder() {
  return transformEncoder(
    getU32Encoder(),
    (NonceVersion value) => value.index,
  );
}

Decoder<NonceVersion> getNonceVersionDecoder() {
  return transformDecoder(
    getU32Decoder(),
    (int value, Uint8List bytes, int offset) => NonceVersion.values[value],
  );
}

Codec<NonceVersion, NonceVersion> getNonceVersionCodec() {
  return combineCodec(getNonceVersionEncoder(), getNonceVersionDecoder());
}
