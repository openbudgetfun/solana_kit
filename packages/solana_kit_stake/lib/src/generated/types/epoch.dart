// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

typedef Epoch = BigInt;

Encoder<Epoch> getEpochEncoder() {
  return getU64Encoder();
}

Decoder<Epoch> getEpochDecoder() {
  return getU64Decoder();
}

Codec<Epoch, Epoch> getEpochCodec() {
  return combineCodec(getEpochEncoder(), getEpochDecoder());
}
