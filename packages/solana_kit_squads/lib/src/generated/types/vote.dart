// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum Vote {
  approve,
  reject,
  cancel,
}

Encoder<Vote> getVoteEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (Vote value) => value.index,
  );
}

Decoder<Vote> getVoteDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => Vote.values[value],
  );
}

Codec<Vote, Vote> getVoteCodec() {
  return combineCodec(getVoteEncoder(), getVoteDecoder());
}
